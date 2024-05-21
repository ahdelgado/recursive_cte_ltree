# frozen_string_literal: true

class CreateBirds < ActiveRecord::Migration[6.1]
  def up
    create_table :birds, if_not_exists: true do |t|
      t.references :node, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :birds, if_exists: true
  end
end
