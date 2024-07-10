# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::NodesController, type: :controller do
  describe 'GET #common_ancestors' do
    let!(:root_node) { Node.create(id: 130, parent_id: 0) }
    let!(:node_125) { Node.create(id: 125, parent_id: 130) }
    let!(:node_2820230) { Node.create(id: 2_820_230, parent_id: 125) }
    let!(:node_4430546) { Node.create(id: 4_430_546, parent_id: 125) }
    let!(:node_5497637) { Node.create(id: 5_497_637, parent_id: 4_430_546) }

    context 'when nodes have a common ancestor' do
      it 'returns the correct common ancestor information' do
        get :common_ancestors, params: { node_a_id: 5_497_637, node_b_id: 2_820_230 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['root_id']).to eq(130)
        expect(JSON.parse(response.body)['lowest_common_ancestor']).to eq(125)
        expect(JSON.parse(response.body)['depth']).to eq(2)
      end
    end

    context 'when the root node is passed as one of the node parameters' do
      it 'returns the root node as the lowest common ancestor' do
        get :common_ancestors, params: { node_a_id: 5_497_637, node_b_id: 130 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['root_id']).to eq(130)
        expect(JSON.parse(response.body)['lowest_common_ancestor']).to eq(130)
        expect(JSON.parse(response.body)['depth']).to eq(1)
      end
    end

    context 'when one of the nodes provided is the lowest common ancestor' do
      it 'returns the correct lowest common ancestor' do
        get :common_ancestors, params: { node_a_id: 5_497_637, node_b_id: 4_430_546 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['root_id']).to eq(130)
        expect(JSON.parse(response.body)['lowest_common_ancestor']).to eq(4_430_546)
        expect(JSON.parse(response.body)['depth']).to eq(3)
      end
    end

    context 'when there is no common ancestor' do
      it 'returns nil for all fields' do
        get :common_ancestors, params: { node_a_id: 9, node_b_id: 4_430_546 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['root_id']).to be_nil
        expect(JSON.parse(response.body)['lowest_common_ancestor']).to be_nil
        expect(JSON.parse(response.body)['depth']).to be_nil
      end
    end

    context 'when the same node is provided for both arguments' do
      it 'returns itself as the common ancestor' do
        get :common_ancestors, params: { node_a_id: 4_430_546, node_b_id: 4_430_546 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['root_id']).to eq(130)
        expect(JSON.parse(response.body)['lowest_common_ancestor']).to eq(4_430_546)
        expect(JSON.parse(response.body)['depth']).to eq(3)
      end
    end
  end
end
