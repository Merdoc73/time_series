class Api::DeviationGraphsController < Api::ApplicationController

  swagger_controller :DeviationGraphs, "Deviation Graphs"

  swagger_api :create do
    summary "Создание ряда с аномалией"
    param :form, :equation, :string, :required, "выражение основного ряда (2*x, sin(x) и т.д.)"
    param :form, :deviation_equation, :string, :optional, "выражение для аномалии (2*x, sin(x) и т.д.)"
    param :form, :points_count, :integer, :required, "Общее количество точек"
    param :form, :noise, :integer, :optional, "Шум, в процентах"
    param :form, :blowout, :integer, :optional, "Количество выбросов"
    param :form, :deviation_length, :integer, :required, "Длина функции аномалии"
  end

  def create
    equation = params[:equation]

    deviation_equation = params[:deviation_equation]
    if deviation_equation.nil? or deviation_equation.empty?
      deviation_equation = "(#{Random.new.rand(-10..10)}*#{['sin(x)', 'cos(x)', 'tan(x)', 'atan(x)', 'log(x)', "#{Random.new.rand(-10..10)}*x"].sample})"
    end

    points_count = params[:points_count].to_i

    noise = params[:noise].to_i
    noise ||= 0
    noise = noise / 100.0

    blowout = params[:blowout].to_i
    blowout ||= 0

    deviation_length = params[:deviation_length].to_i

    calculator = Dentaku::Calculator.new
    start_point = Random.new.rand(1..(points_count - deviation_length))
    lol = 0
    coords = points_count.times.map do |x|
      x_val = x * 0.3
      coord = calculator.evaluate(equation, x: x_val)
      if (start_point..start_point+deviation_length-1).to_a.include? x
        coord = calculator.evaluate(deviation_equation, x: (x - start_point) * 0.3) + lol
      end
      actual_noise = Random.new.rand(-noise..noise)
      coord = coord * (1 + actual_noise)
      if x == start_point - 1
        lol = coord.round(5)
      end
      [x, coord.round(5)]
    end

    blowout.times do
      x = Random.new.rand(1..points_count)
      coords[x][1] = coords[x][1] * (1 + Random.new.rand(100..300) / 100.0)
    end

    render json: { coords: coords, deviation_equation: deviation_equation, row: coords.map{|e| e[1].to_f} }
  end
end
