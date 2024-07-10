# frozen_string_literal: true

class CreateNodes < ActiveRecord::Migration[6.1]
  def up
    create_table :nodes, if_not_exists: true do |t|
      t.integer :parent_id, default: 0, null: true
      t.ltree :path, null: true

      # enabled the ltree extension to use ltree-specific functionality
      enable_extension 'ltree'
    end

    add_index :nodes, :parent_id
    # This index will significantly speed up the ltree path matching queries, especially for large datasets.
    add_index :nodes, :path, using: :gist
  end

  def down
    drop_table :nodes, if_exists: true
    disable_extension 'ltree'
  end
end
