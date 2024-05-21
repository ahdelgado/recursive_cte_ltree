# frozen_string_literal: true

module Api
  class NodesController < Api::ApiController
    def common_ancestors
      result = Node.lowest_common_ancestor(safe_params[:node_a_id], safe_params[:node_b_id])
      render json: result, status: :ok
    end

    private

    def safe_params
      params.permit(:node_a_id, :node_b_id)
    end
  end
end
