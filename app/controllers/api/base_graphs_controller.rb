class Api::BaseGraphsController < Api::ApplicationController
  def create
    equation = params[:equation]
    points_count = params[:points_count].to_i
    calculator = Dentaku::Calculator.new
    coords = points_count.times.map do |x|
      x_val = x * 0.3
      [x, calculator.evaluate(equation, x: x_val)]
    end
    render json: { coords: coords }
  end
end
