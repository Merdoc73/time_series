class Api::DeviationGraphsController < Api::ApplicationController
  def create
    equation = params[:equation]
    deviation_equation = params[:deviation_equation]
    deviation_equation = "(#{Random.new.rand(-10..10)}*#{['sin(x)', 'cos(x)', 'tan(x)', 'atan(x)', 'log(x)', "#{Random.new.rand(-10..10)}*x"].sample})"
    p deviation_equation
    points_count = params[:points_count].to_i
    calculator = Dentaku::Calculator.new
    deviation_length = Random.new.rand(Range.new((points_count * 0.1).round, ((points_count * 0.5).round)))
    start_point = Random.new.rand(Range.new(1, (points_count - deviation_length)))
    coords = points_count.times.map do |x|
      coord = calculator.evaluate(equation, x: x)
      if (start_point..start_point+deviation_length).to_a.include? x
        coord = calculator.evaluate(deviation_equation, x: x)
      else
        coord = calculator.evaluate(equation, x: x)
      end
      [x, coord]
    end
    render json: { coords: coords }
  end
end
