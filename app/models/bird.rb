# frozen_string_literal: true

class Bird < ApplicationRecord
  belongs_to :node

  # Scope to find bird IDs associated with specified nodes or their descendant nodes
  scope :birds_for_nodes, lambda { |node_ids|
    all.select do |bird|
      next if bird.node.path.nil?

      (bird.node.path.split('.').map(&:to_i) & node_ids).any?
    end
  }
end
