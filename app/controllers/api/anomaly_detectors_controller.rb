class Api::AnomalyDetectorsController < Api::ApplicationController

  swagger_controller :AnomalyDetectors, "Anomaly Detectors"

  swagger_api :create do
    summary "Получает результат поиска аномалий"
    param_list :form, :type, :string, :required, "type (fuzzy или sliding_window)", ['fuzzy', 'sliding_window']
    param :form, :row, :string, :required, "Values ( 1,2,3,4,5,6 )"
    param :form, :size, :integer, :optional, "Длина окна (для метода скользящего окна)"
  end

  def create
    result = AnomalyDetectionService.perform(params[:type], params[:row].split(",").map { |s| s.to_f }, params[:size])
    render json: result
  end
end
