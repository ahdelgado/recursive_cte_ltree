# frozen_string_literal: true

class Bird < ApplicationRecord
  belongs_to :node

  scope :birds_for_nodes, lambda { |node_ids|
    joins(:node).where(build_ltree_query(node_ids))
  }

  # The query is constructed dynamically based on the number of node ids provided.
  class << self
    def build_ltree_query(node_ids)
      node_ids.map do |id|
        sanitize_sql_array(['nodes.path ~ ?', "*.#{id}.*"])
      end.join(' OR ')
    end
  end
end
