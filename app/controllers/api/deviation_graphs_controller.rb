class Api::DeviationGraphsController < Api::ApplicationController
  def create
    equation = params[:equation]
    deviation_equation = params[:deviation_equation]
    points_count = params[:points_count].to_i
    calculator = Dentaku::Calculator.new
    coords = points_count.times.map do |x|
      coord = calculator.evaluate(equation, x: x)
      param = Random.new.rand(1.5)
      deviation_coord = calculator.evaluate(deviation_equation, x: param)
      [x, deviation_coord]
    end
    render json: coords
  end
end
