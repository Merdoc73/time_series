class Api::BaseGraphsController < Api::ApplicationController
  swagger_controller :BaseGraphs, "Base Graph"

  swagger_api :create do
    summary "Создание обычного ряда на основе функции"
    param :form, :equation, :string, :required, "выражение (2*x, sin(x) и т.д.)"
    param :form, :points_count, :integer, :required, "Количество точек"
  end

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
