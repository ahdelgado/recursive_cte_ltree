# frozen_string_literal: true

class Node < ApplicationRecord
  has_many :birds
  before_save :insert_node

  def insert_node
    self.path = if parent_id.zero? || parent_id.nil?
                  id
                else
                  "#{Node.where(id: parent_id).pluck(:path).first}.#{id}"
                end
  end

  class << self
    def lowest_common_ancestor(node_a_id, node_b_id)
      # Fetch both node ltree paths in a single query
      nodes = Node.where(id: [node_a_id, node_b_id]).pluck(:id, :path)

      # Extract the ltree paths from the fetched data
      node_a_path = nodes.find { |id, _| id == node_a_id }&.second
      node_b_path = nodes.find { |id, _| id == node_b_id }&.second

      # Convert ltree paths to arrays
      node_a_path = node_a_path&.split('.')
      node_b_path = node_b_path&.split('.')

      # Return nil values for root_id, lowest_common_ancestor, and depth
      if no_common_ancestor?(node_a_path, node_b_path)
        return {
          root_id: nil,
          lowest_common_ancestor: nil,
          depth: nil
        }
      end

      # Find the lowest common ancestor and its depth
      lca = nil
      depth = 0
      i = 0
      while i < [node_a_path.length, node_b_path.length].min && node_a_path[i] == node_b_path[i]
        lca = node_a_path[i]
        depth += 1
        i += 1
      end

      # Return the result
      {
        root_id: node_a_path[0].to_i,
        lowest_common_ancestor: lca.to_i,
        depth: depth
      }
    end

    def no_common_ancestor?(node_a_path, node_b_path)
      node_a_path.nil? || node_b_path.nil? || node_a_path[0] != node_b_path[0]
    end
  end
end
