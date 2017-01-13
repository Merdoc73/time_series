class Api::AnomalyDetectorsController < ApplicationController
  def create
    result = AnomalyDetectionService.perform(params[:type], params[:row].split(",").map { |s| s.to_f })
    render json: result
  end
end
