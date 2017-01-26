class Api::DeviationGraphsController < Api::ApplicationController
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
    coords = points_count.times.map do |x|
      x_val = x * 0.3
      coord = calculator.evaluate(equation, x: x_val)
      if (start_point..start_point+deviation_length-1).to_a.include? x
        coord = calculator.evaluate(deviation_equation, x: (x - start_point) * 0.3)
      end
      actual_noise = Random.new.rand(-noise..noise)
      coord = coord * (1 + actual_noise)

      [x, coord.round(5)]
    end

    blowout.times do
      x = Random.new.rand(1..points_count)
      coords[x][1] = coords[x][1] * (1 + Random.new.rand(100..300) / 100.0)
    end

    render json: { coords: coords, deviation_equation: deviation_equation, row: coords.map{|e| e[1].to_f} }
  end
end
