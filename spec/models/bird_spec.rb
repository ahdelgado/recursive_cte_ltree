# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bird, type: :model do
  describe '.birds_for_nodes' do
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

    before do
      root_node.touch
    end

    context 'when given node_ids contain nodes and their descendants' do
      it 'returns bird IDs associated with specified nodes and their descendants' do
        node_ids = [125, 4_430_546]
        birds = Bird.birds_for_nodes(node_ids)
        expect(birds.pluck(:id)).to match_array([1, 2, 3, 4])
      end
    end

    context 'when given node_ids contain only nodes without descendants' do
      it 'returns bird IDs associated with specified nodes' do
        node_ids = [2_820_230, 5_497_637]
        birds = Bird.birds_for_nodes(node_ids)
        expect(birds.pluck(:id)).to match_array([2, 4])
      end
    end

    context 'when given node_ids contain nodes that do not have associated birds' do
      it 'returns an empty result' do
        node_ids = [13]
        birds = Bird.birds_for_nodes(node_ids)
        expect(birds).to be_empty
      end
    end

    context 'when given node_ids that contain the root node' do
      it 'returns birds assopciated with all nodes in tree' do
        node_ids = [130]
        birds = Bird.birds_for_nodes(node_ids)
        expect(birds.pluck(:id)).to match_array([1, 2, 3, 4, 5])
      end
    end
  end
end
