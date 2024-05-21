# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ApiController, type: :controller do
  controller do
    def index
      raise StandardError, 'Test error'
    end
  end

  describe 'Error Handling' do
    it 'handles internal server error' do
      get :index
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Internal Server Error' })
    end

    it 'handles not found error' do
      allow(controller).to receive(:index).and_raise(ActiveRecord::RecordNotFound)
      get :index
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Not Found' })
    end

    it 'handles parameter missing error' do
      allow(controller).to receive(:index).and_raise(ActionController::ParameterMissing.new(:param))
      get :index
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Parameter missing: param' })
    end
  end
end
