module AnomalyDetectionService
  extend self
  def perform(type, row)
    if type == 'sliding_window'
      sliding_window(row)
    elsif type == 'other'
      return
    end
  end

  private

  def sliding_window(row)
    period = calc_period(row).round(0)
    calc_anomaly(row, period)
  end

  def calc_period(row)
    pereodic_row = nil
    period = nil
    row_size = row.size
    avg = row.sum.to_f / row_size
    indexed_row = row.map.with_index { |e, i| [i, e] }
    more_than_avg = indexed_row.select { |e| e[1].to_f > avg }
    if more_than_avg.size > row_size.to_f * 0.6
      pereodic_row = false
      return period = row_size * 0.2
    end

    # разбивка по группам
    groups = []
    group_num = 0
    i = 0
    prev_index = nil
    while i < row_size
      if more_than_avg[i].nil?
        i += 1
        next
      end
      group_num += 1 if prev_index.present? && more_than_avg[i][0] != prev_index + 1
      groups[group_num] ||= []
      groups[group_num] << more_than_avg[i]
      prev_index = more_than_avg[i][0]
      i += 1
    end

    # объединение групп
    tmp_groups = groups
    new_groups = []
    replaces = true
    while replaces
      replaces = false
      new_groups = []
      avg_group_size = tmp_groups.map(&:size).sum.to_f / groups.size
      tmp_groups.each_cons(2).with_index do |arr, index|
        if arr[0].nil?
          new_groups << arr[1] if index == tmp_groups.size - 2
          next
        end
        if arr[1].nil?
          new_groups << arr[0]
          next
        end
        index_diff = arr[1].first[0] - arr[0].last[0]
        if index_diff < avg_group_size * 0.1 # || index_diff <= 2
          new_groups << arr[0] + arr[1]
          tmp_groups[index + 1] = nil
          replaces = true
        else
          new_groups << arr[0]
          new_groups << arr[1] if index == tmp_groups.size - 2
        end
      end
      tmp_groups = new_groups
    end

    if new_groups.size < 3
      pereodic_row = false
      return period = row_size * 0.2
    end
    avg_new_groups_size = new_groups[1..-2].map(&:size).sum.to_f / new_groups.size
    selected_groups = new_groups[1..-1].select.with_index do |e, index|
      max_diff = avg_new_groups_size + avg_new_groups_size * 0.35
      min_diff = avg_new_groups_size - avg_new_groups_size * 0.35
      diff = e[0].first - new_groups[index].last[0]
      if diff.between? min_diff, max_diff
        true
      else
        false
      end
    end
    if selected_groups.size > new_groups.size * 0.75
      pereodic_row = true
      return avg_new_groups_size
    else
      return period = row_size * 0.2
    end
  end

  def calc_anomaly(row, period)
    trends = {}
    avgs = {}
    deviations = {}
    avgs_diff = {}
    dispersions = {}
    row.each_cons(period).with_index do |arr, first_index|
      trend_arr = arr[1..-1].map.with_index do |e, index|
        diff = e - arr[index-1]
        calc_trend(diff, e)
      end
      row_diff = arr.last - arr.first
      row_trend = calc_trend(row_diff, arr.last)
      trend_arr << row_trend
      # p first_index
      # p trend_arr
      total_trend_hash = trend_arr.inject(Hash.new(0)) { |total, e| total[e] += 1; total}
      max_trend = total_trend_hash.max_by{|k,v| v}
      total_trend = max_trend[1] > arr.size * 0.5 ? max_trend[0] : :stability
      # p "total_trend: #{total_trend}"
      trends.merge!({ first_index => total_trend })

      avg = (arr.sum.to_f / arr.size).round(5)
      avgs.merge!({ first_index => avg })
      deviation = arr[1..-1].map.with_index{|e, i| (e - arr[i]).abs}.max
      deviations.merge!({ first_index => deviation })
      avg_diff = arr[1..-1].map.with_index{|e, i| e - arr[i]}.sum / arr.size
      avgs_diff.merge!({ first_index => avg_diff })
      dispersion = ((arr.inject {|sum, e| sum + e ** 2 }.to_f / arr.size) - ((arr.sum / arr.size) ** 2)).round(5)
      dispersions.merge!({ first_index => dispersion })
    end
    min_trend = trends.group_by{|k,v| v}.map {|k,v| [k, v.size]}.min_by{|e| e[1]}
    trend_percent = 0.3
    if min_trend.to_a.last <= trends.size * trend_percent
      p "trend: #{min_trend} is lower 10%"
    end
    # p min_trend
    # p trends
    # p avgs
    # p deviations
    # p avgs_diff
    p dispersions
    anomaly = {}
    [:avgs, :deviations, :avgs_diff, :dispersions].each do |type|
      avg = (eval(type.to_s).map{|k,v| v}.sum.to_f / eval(type.to_s).size).round(5)
      p "#{type.to_s} avg = #{avg}"
      anomaly[type] = eval(type.to_s).select{ |k,v| !v.between?(avg - avg * 0.25, avg + avg * 0.25)}
    end
    all = anomaly.map{|e| e[1].keys}.select(&:present?).reduce(&:&)
    p all
    return { anomalies: all.map{|e| "#{e}-#{e+period}"}.join(';'),
             all: anomaly.select{ |k,v| v.keys.size < row.size - period }.to_s}
  end

  def calc_trend(diff, element)
    if diff.abs == 0 || diff.abs < element * 0.02
      :stability
    elsif diff > 0
      :growth
    else
      :fall
    end
  end
end
