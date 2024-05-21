# frozen_string_literal: true

module Api
  class BirdsController < Api::ApiController
    def index
      node_ids = safe_params[:node_ids].map(&:to_i)
      birds = Bird.birds_for_nodes(node_ids)
      render json: { bird_ids: birds.pluck(:id) }
    end

    private

    def safe_params
      params.permit(node_ids: [])
    end
  end
end
