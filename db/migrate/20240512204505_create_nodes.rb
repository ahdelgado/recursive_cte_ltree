# frozen_string_literal: true

class CreateNodes < ActiveRecord::Migration[6.1]
  def up
    create_table :nodes, if_not_exists: true do |t|
      t.integer :parent_id, default: 0, null: true
      t.ltree :path, null: true

      enable_extension 'ltree'
    end

    add_index :nodes, :parent_id
  end

  def down
    remove_index :nodes, :parent_id
    drop_table :nodes, if_exists: true
    disable_extension 'ltree'
  end
end
