class Api::AnomalyDetectorsController < ApplicationController
  def create
    result = AnomalyDetectionService.perform(params[:type], params[:row].split(",").map { |s| s.to_f }, params[:size])
    render json: result
  end
end
