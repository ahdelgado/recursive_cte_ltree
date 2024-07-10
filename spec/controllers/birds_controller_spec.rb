# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BirdsController, type: :controller do
  describe 'GET birds_for_nodes' do
    let!(:root_node) { Node.create(id: 130, parent_id: 0) }
    let!(:node_125) { Node.create(id: 125, parent_id: 130) }
    let!(:node_2820230) { Node.create(id: 2_820_230, parent_id: 125) }
    let!(:node_4430546) { Node.create(id: 4_430_546, parent_id: 125) }
    let!(:node_5497637) { Node.create(id: 5_497_637, parent_id: 4_430_546) }

    let!(:bird1) { Bird.create(id: 1, node_id: 125) }
    let!(:bird2) { Bird.create(id: 2, node_id: 2_820_230) }
    let!(:bird3) { Bird.create(id: 3, node_id: 4_430_546) }
    let!(:bird4) { Bird.create(id: 4, node_id: 5_497_637) }
    let!(:bird5) { Bird.create(id: 5, node_id: 130) }

    context 'when given node_ids contain nodes and their descendants' do
      it 'returns bird IDs associated with specified nodes and their descendants' do
        get :index, params: { node_ids: [125, 4_430_546] }
        expected_response = { bird_ids: [1, 2, 3, 4] }
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    context 'when given node_ids contain only nodes without descendants' do
      it 'returns bird IDs associated with specified nodes' do
        get :index, params: { node_ids: [2_820_230, 5_497_637] }
        expected_response = { bird_ids: [2, 4] }
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    context 'when given node_ids contain nodes that do not have associated birds' do
      it 'returns an empty result' do
        get :index, params: { node_ids: [13] }
        expected_response = { bird_ids: [] }
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    context 'when given node_ids that contain the root node' do
      it 'returns birds associated with all nodes in tree' do
        get :index, params: { node_ids: [130] }
        expected_response = { bird_ids: [1, 2, 3, 4, 5] }
        expect(response.body).to eq(expected_response.to_json)
      end
    end
  end
end
