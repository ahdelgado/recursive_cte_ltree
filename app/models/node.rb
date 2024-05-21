# frozen_string_literal: true

class Node < ApplicationRecord
  has_many :birds
  after_save :update_ltree_path

  def update_ltree_path
    # Define a recursive common table expression (CTE) to generate the hierarchical ltree path for each node
    recursive_query = <<-SQL
    WITH RECURSIVE tree_path AS (
      SELECT id, parent_id, id::text AS path_ids
      FROM nodes
      WHERE parent_id IS NULL OR parent_id = 0
      UNION ALL
      SELECT nodes.id, nodes.parent_id, tree_path.path_ids || '.' || nodes.id::text
      FROM nodes
      JOIN tree_path ON nodes.parent_id = tree_path.id
    )
    UPDATE nodes
    SET path = tree_path.path_ids::ltree
    FROM tree_path
    WHERE nodes.id = tree_path.id;
    SQL

    ActiveRecord::Base.connection.execute(recursive_query)
  end

  class << self
    def lowest_common_ancestor(node_a_id, node_b_id)
      # Fetch both node ltree paths in a single query
      nodes = Node.where(id: [node_a_id, node_b_id]).pluck(:id, :path)

      # Extract the ltree paths from the fetched data
      node_a_path = nodes.find { |id, _| id == node_a_id }&.second
      node_b_path = nodes.find { |id, _| id == node_b_id }&.second

      if node_a_path.nil? || node_b_path.nil?
        # Return nil values for root_id, lowest_common_ancestor, and depth
        return {
          root_id: nil,
          lowest_common_ancestor: nil,
          depth: nil
        }
      end

      # Convert ltree paths to arrays
      node_a_path_parts = node_a_path.split('.')
      node_b_path_parts = node_b_path.split('.')

      # Find the lowest common ancestor and its depth
      lca = nil
      depth = 0
      i = 0
      while i < [node_a_path_parts.length, node_b_path_parts.length].min && node_a_path_parts[i] == node_b_path_parts[i]
        lca = node_a_path_parts[i]
        depth += 1
        i += 1
      end

      # Return the result
      {
        root_id: node_a_path_parts.first.to_i,
        lowest_common_ancestor: lca.to_i,
        depth: depth
      }
    end
  end
end
