# frozen_string_literal: true

namespace :nodes do
  desc 'Update ltree path for all nodes'
  task update_ltree_path: :environment do
    puts 'Updating ltree path for all nodes...'

    execution_time = Benchmark.measure do
      recursive_query = <<-SQL
    WITH RECURSIVE tree_path AS (
      SELECT id, parent_id, ARRAY[id::text] AS path_array
      FROM nodes
      WHERE parent_id IS NULL OR parent_id = 0
      UNION ALL
      SELECT nodes.id, nodes.parent_id,
             tree_path.path_array || nodes.id::text
      FROM nodes
      JOIN tree_path ON nodes.parent_id = tree_path.id
      WHERE NOT nodes.id::text = ANY(tree_path.path_array)
    )
    UPDATE nodes
    SET path = CASE
               WHEN tree_path.path_array IS NOT NULL THEN array_to_string(tree_path.path_array, '.')::ltree
               ELSE NULL
               END
    FROM tree_path
    WHERE nodes.id = tree_path.id;
      SQL

      ActiveRecord::Base.connection.execute(recursive_query)
    end

    p 'Ltree path update completed successfully.'
    p "Execution time: #{execution_time.real.round(3)} seconds"
  end
end
