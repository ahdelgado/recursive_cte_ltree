# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      render_status(404, 'Resource Not Found')
    end
  end
end
