# frozen_string_literal: true

module Croods
  class Controller < ActionController::API
    def index
      render json: model.order(:created_at)
    end

    def show
      render json: record
    end

    def create
      render status: :created, json: model.create!(record_params)
    end

    def update
      record.update!(record_params)
      render json: record
    end

    def destroy
      render json: record.destroy!
    end

    private

    def record
      model.find(params[:id])
    end

    def record_params
      params.require(model_name.downcase).permit!
    end

    def model_name
      self.class.to_s.titleize.split.first.singularize
    end

    def model
      model_name.constantize
    end
  end
end
