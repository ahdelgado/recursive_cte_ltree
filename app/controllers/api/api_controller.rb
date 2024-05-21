# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    rescue_from StandardError, with: :handle_internal_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing_error

    private

    def handle_internal_server_error(exception)
      logger.error "Internal Server Error: #{exception.message}"
      render json: { error: 'Internal Server Error' }, status: :internal_server_error
    end

    def handle_not_found_error
      render json: { error: 'Not Found' }, status: :not_found
    end

    def handle_parameter_missing_error(exception)
      render json: { error: "Parameter missing: #{exception.param}" }, status: :unprocessable_entity
    end
  end
end
