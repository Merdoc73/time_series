module AnomalyDetectionService
  extend self
  def perform(type, row, size)
    if type == 'sliding_window'
      sliding_window(row, size)
    elsif type == 'fuzzy'
      fuzzy(row, size)
    end
  end

  private

  def sliding_window(row, size)
    period = calc_period(row).round(0)
    if size.nil? or size.empty?
      calc_anomaly(row, period)
    else
      calc_anomaly(row, size.to_i)
    end
  end

  def calc_period(row)
    pereodic_row = nil
    period = nil
    row_size = row.size
    avg = getRowAverage(row)
    indexed_row = row.map.with_index { |e, i| [i, e] }
    p avg
    p row
    more_than_avg = indexed_row.select { |e| (e[1] || 0).to_f > avg }
    if more_than_avg.size > row_size.to_f * 0.7
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
    if selected_groups.size >= (new_groups.size * 0.75).to_i
      pereodic_row = true
      return avg_new_groups_size
    else
      return period = row_size * 0.2
    end
  end

  def getRowAverage(row)
    row = row.map{|e| e.round(4)}
    row_average = row.sum.to_f / row.size
    row_max_diff = (row.max - row_average).abs
    row_min_diff = (row_average - row.min).abs
    proportions = row_max_diff.to_f / row_min_diff

    if proportions < 0.9
      row_clone = row
      target_size = row.size * 0.7
      while target_size < row_clone.size
        row_clone.delete_at(row_clone.index(row_clone.min))
      end
    elsif proportions > 1.1
      row_clone = row.clone
      target_size = (row.size * 0.7).to_i

      while target_size < row_clone.size
        row_clone.delete_at(row_clone.index(row_clone.min))
      end
    else
      row_clone = row
      target_size = row.size * 0.7
      while target_size < row_clone.size
        row_clone.delete_at(row_clone.index(row_clone.min))
      end

      target_size = row_clone.size * 0.7
      while target_size < row_clone.size
        row_clone.delete_at(row_clone.index(row_clone.max))
      end
    end
    row_clone.sum.to_f / row_clone.size
  end

  def calc_anomaly(row, period)
    trends = {}
    avgs = {}
    deviations = {}
    avgs_diff = {}
    dispersions = {}
    row.each_cons(period).with_index do |arr, first_index|
      arr.map! {|item| item.abs}
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
    # p min_trend
    # p trends
    # p avgs
    # p deviations
    # p avgs_diff
    p dispersions
    anomaly = {}
    [:avgs, :deviations, :avgs_diff, :dispersions].each do |type|
      avg = getRowAverage(eval(type.to_s).map{|k,v| v.to_f.round(3)}).round(4)
      p "#{type.to_s} avg = #{avg}"
      p "#{eval(type.to_s)}"
      anomaly[type] = eval(type.to_s).select{ |k,v| !v.round(3).between?(avg - avg * 0.25, avg + avg * 0.25)}
    end
    if min_trend.to_a.last <= trends.size * trend_percent
      p "trend: #{min_trend} is lower 10%"
      anomaly[:trends] = trends.select{|e| e[0] != :trend}.select{|k,v| v == min_trend.to_a.first}
      p anomaly[:trends]
    end
    if min_trend.to_a.last <= trends.size * trend_percent
      p "trend: #{min_trend} is lower 10%"
      anomaly[:trends] = trends.select{|k,v| v == min_trend.to_a.first}
      p anomaly[:trends]
    end
    all = anomaly.map{|e| e[1].keys}.select(&:present?).reduce(&:&)
    p all
    if all.size >= 0.4 * (row.size - period)
      all = []
    end
    var_table = (0..row.size-period).to_a.map.with_index do |e, index|
       ["#{e}-#{e+period}",
        trends[index],
        avgs[index],
        deviations[index],
        avgs_diff[index],
        dispersions[index],
        all.include?(index)
       ]#.zip(trends, avgs, deviations, avgs_diff, dispersions)
    end
    return { anomalies: all.each_cons(2).select{|e| e[0] + 1 == e[1]}.flatten.uniq.map{|e| "#{e}-#{e + period}"}.join(';'),
             all: anomaly.select{ |k,v| v.keys.size < row.size - period }.to_json,
             var_table: var_table}
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

  def fuzzy(row, size)
    min = row.min
    max = row.max
    interval_length = (max - min) * 0.2
    if size.nil? or size.empty?
      intervals_count = (2 * (max - min) / interval_length + 1).ceil
    else
      intervals_count = size.to_i
    end

    fuzzy_vars = getFuzzyVars(intervals_count, min, max)
    linguistic_vars = getLinguisticVars(row, fuzzy_vars)

    #нечеткие тенденции, которые встречаются реже 10%.
    grouped_linguistic = linguistic_vars.group_by { |x| x.difference }
    anomalies_indexes = []
    grouped_linguistic.keys.each do |key|
      if grouped_linguistic[key].size <= (linguistic_vars.size * 0.05)
        grouped_linguistic[key].each do |e|
          e.anomaly = true
          anomalies_indexes << e.index
        end
      end
    end

    keys = ('A'..'Z').to_a
    trend_table = []
    i = 0
    grouped_linguistic.keys.each do |key|
      elements = []
      elements << keys[i]

      if grouped_linguistic[key].first.trend == :growth
        elements << 'Рост'
      elsif grouped_linguistic[key].first.trend == :fall
        elements << 'Падение'
      else
        elements << 'Стабильность'
      end

      elements << 'R' + key.abs.to_s
      elements << grouped_linguistic[key].size
      elements << grouped_linguistic[key].size.to_s + '/' + linguistic_vars.size.to_s

      if grouped_linguistic[key].size <= (linguistic_vars.size * 0.05)
        elements << grouped_linguistic[key].map {|x| x.index } .join(', ')
      else
        elements << ''
      end

      trend_table << elements

      i += 1
    end

    #нечеткие переменные, которые встречаются реже 10%
    grouped_linguistic = linguistic_vars.group_by { |x| x.val }
    grouped_linguistic.keys.each do |key|
      if grouped_linguistic[key].size <= (linguistic_vars.size * 0.05)
        grouped_linguistic[key].each do |e|
          e.anomaly = true
          anomalies_indexes << e.index
        end
      end
    end

    i = 0
    var_table = []
    grouped_linguistic.keys.each do |key|
      elements = []
      elements << keys[i]

      elements << 'R' + i.to_s
      elements << grouped_linguistic[key].size
      elements << grouped_linguistic[key].size.to_s + '/' + linguistic_vars.size.to_s

      if grouped_linguistic[key].size <= (linguistic_vars.size * 0.05)
        elements << grouped_linguistic[key].map {|x| x.index } .join(', ')
      else
        elements << ''
      end

      var_table << elements

      i += 1
    end

    anomalies_indexes = anomalies_indexes.uniq.sort

    {anomalies_indexes: anomalies_indexes,
     trend_table: trend_table,
     var_table: var_table}
  end

  def getFuzzyVars(intervals_count, min, max)
    interval_length = (max - min) / intervals_count
    fuzzy_vars = []

    for i in 0..intervals_count-1
      interval_begin = min + interval_length * i
      interval_middle = interval_begin + interval_length / 2
      interval_end = interval_begin + interval_length
      name = i
      fuzzy = FuzzyVar.new(interval_begin, interval_middle, interval_end, name)
      fuzzy_vars << fuzzy
    end
    fuzzy_vars
  end

  def getLinguisticVars(row, fuzzy_vars)
    linguistic_vars = []
    row.each do |item|
      closest_fuzzy_var = fuzzy_vars.min_by { |x| (x.interval_middle > item ? x.interval_middle - item : item - x.interval_middle).abs }
      linguistic_vars << LinguisticVar.new(closest_fuzzy_var)
    end

    for i in 0..(linguistic_vars.size-2)
      current_val = linguistic_vars[i].val.name
      next_val = linguistic_vars[i + 1].val.name
      difference = next_val - current_val
      if difference == 0
        trend = :stability
      elsif difference > 0
        trend = :growth
      else
        trend = :fall
      end
      linguistic_vars[i].trend = trend
      linguistic_vars[i].difference = difference
      linguistic_vars[i].index = i
    end
    linguistic_vars[linguistic_vars.size - 1].difference = linguistic_vars[linguistic_vars.size - 2].difference
    linguistic_vars[linguistic_vars.size - 1].trend = linguistic_vars[linguistic_vars.size - 2].trend
    linguistic_vars[linguistic_vars.size - 1].index = linguistic_vars.size - 1

    linguistic_vars
  end

  class FuzzyVar
    def initialize(interval_begin, interval_middle, interval_end, name)
      @interval_begin = interval_begin
      @interval_middle = interval_middle
      @interval_end = interval_end
      @name = name
    end
    attr_reader :interval_begin
    attr_reader :interval_middle
    attr_reader :interval_end
    attr_reader :name
  end

  class LinguisticVar
    @difference = 0
    @trend = :stability
    @index = 0
    @anomaly = false
    def initialize(val)
      @val = val
    end
    attr_reader :val
    attr_accessor :trend
    attr_accessor :difference
    attr_accessor :index
    attr_accessor :anomaly
  end
end
