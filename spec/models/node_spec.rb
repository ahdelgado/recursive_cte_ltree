# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node, type: :model do
  describe '.lowest_common_ancestor' do
    let!(:root_node) { Node.create(id: 130, parent_id: 0) }
    let!(:node_125) { Node.create(id: 125, parent_id: 130) }
    let!(:node_2820230) { Node.create(id: 2_820_230, parent_id: 125) }
    let!(:node_4430546) { Node.create(id: 4_430_546, parent_id: 125) }
    let!(:node_5497637) { Node.create(id: 5_497_637, parent_id: 4_430_546) }

    context 'when nodes have a common ancestor' do
      it 'returns the correct common ancestor information' do
        result = Node.lowest_common_ancestor(5_497_637, 2_820_230)
        expect(result[:root_id]).to eq(130)
        expect(result[:lowest_common_ancestor]).to eq(125)
        expect(result[:depth]).to eq(2)
      end
    end

    context 'when the root node is passed as one of the node parameters' do
      it 'returns the root node as the lowest common ancestor' do
        result = Node.lowest_common_ancestor(5_497_637, 130)
        expect(result[:root_id]).to eq(130)
        expect(result[:lowest_common_ancestor]).to eq(130)
        expect(result[:depth]).to eq(1)
      end
    end

    context 'when one of the nodes provided is the lowest common ancestor' do
      it 'returns the correct lowest common ancestor' do
        result = Node.lowest_common_ancestor(5_497_637, 4_430_546)
        expect(result[:root_id]).to eq(130)
        expect(result[:lowest_common_ancestor]).to eq(4_430_546)
        expect(result[:depth]).to eq(3)
      end
    end

    context 'when there is no common ancestor' do
      it 'returns nil for all fields' do
        result = Node.lowest_common_ancestor(9, 4_430_546)
        expect(result).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil })
      end
    end

    context 'when the same node is provided for both arguments' do
      it 'returns itself as the common ancestor' do
        result = Node.lowest_common_ancestor(4_430_546, 4_430_546)
        expect(result[:root_id]).to eq(130)
        expect(result[:lowest_common_ancestor]).to eq(4_430_546)
        expect(result[:depth]).to eq(3)
      end
    end
  end
end
