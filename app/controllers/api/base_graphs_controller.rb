class Api::BaseGraphsController < Api::ApplicationController
  def create
    equation = params[:equation]
    points_count = params[:points_count].to_i
    calculator = Dentaku::Calculator.new
    coords = points_count.times.map do |x|
      [x, calculator.evaluate(equation, x: x)]
    end
    render json: { coords: coords }
  end
end
