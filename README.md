# Hierarchical Tree API with PostgreSQL ltree

A Ruby on Rails API demonstrating efficient tree traversal and lowest common ancestor (LCA) calculations using PostgreSQL's `ltree` extension and recursive Common Table Expressions (CTEs).

## Overview

This application provides a RESTful API for working with hierarchical tree data stored as an adjacency list. It leverages PostgreSQL's `ltree` data type to enable fast ancestor queries without expensive recursive lookups at query time.

## Features

- **Lowest Common Ancestor (LCA)** - Find the lowest common ancestor between any two nodes in O(1) database queries
- **Hierarchical Path Tracking** - Automatic maintenance of materialized paths using `ltree`
- **Descendant Queries** - Efficiently retrieve all entities belonging to a node or its descendants
- **Bulk Path Updates** - Rake task for rebuilding ltree paths using recursive CTEs

## Requirements

- Ruby 3.1.0
- Rails 7.1.x
- PostgreSQL 12+ (with `ltree` extension)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd recursive_cte_ltree
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

4. (Optional) Seed the database:
   ```bash
   bin/rails db:seed
   ```

5. If importing existing data, rebuild ltree paths:
   ```bash
   bin/rails nodes:update_ltree_path
   ```

## Database Schema

### Nodes Table
| Column    | Type    | Description                          |
|-----------|---------|--------------------------------------|
| id        | bigint  | Primary key                          |
| parent_id | integer | Reference to parent node (0 or NULL for root) |
| path      | ltree   | Materialized path from root to node  |

### Birds Table
| Column  | Type   | Description                |
|---------|--------|----------------------------|
| id      | bigint | Primary key                |
| node_id | bigint | Foreign key to nodes table |

## API Endpoints

### 1. Common Ancestor

```
GET /api/nodes/:node_a_id/common_ancestors/:node_b_id
```

Returns the lowest common ancestor shared by two nodes.

**Response Fields:**
- `root_id` - The root node of the tree containing both nodes
- `lowest_common_ancestor` - The deepest node that is an ancestor of both input nodes
- `depth` - The depth of the lowest common ancestor in the tree

**Example:**

Given the following tree structure:
```
130 (root)
 └── 125
      ├── 2820230
      └── 4430546
           └── 5497637
```

| Request | Response |
|---------|----------|
| `GET /api/nodes/5497637/common_ancestors/2820230` | `{root_id: 130, lowest_common_ancestor: 125, depth: 2}` |
| `GET /api/nodes/5497637/common_ancestors/130` | `{root_id: 130, lowest_common_ancestor: 130, depth: 1}` |
| `GET /api/nodes/5497637/common_ancestors/4430546` | `{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}` |
| `GET /api/nodes/4430546/common_ancestors/4430546` | `{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}` |
| `GET /api/nodes/9/common_ancestors/4430546` | `{root_id: null, lowest_common_ancestor: null, depth: null}` |

### 2. Birds by Nodes

```
GET /api/birds?node_ids[]=1&node_ids[]=2
```

Returns all bird IDs belonging to the specified nodes or any of their descendant nodes.

**Parameters:**
- `node_ids[]` - Array of node IDs to query

**Response:**
```json
{
  "bird_ids": [1, 2, 3, 5, 8]
}
```

## How It Works

### ltree Path Maintenance

Each node stores a `path` attribute representing the full path from the root to that node, formatted as dot-separated IDs (e.g., `130.125.4430546.5497637`).

**Automatic Updates:** The `Node` model includes a `before_save` callback that automatically computes and sets the path when a node is created or updated.

**Bulk Updates:** For existing data or after structural changes, use the rake task:
```bash
bin/rails nodes:update_ltree_path
```

This task uses a recursive CTE to traverse the entire tree and update all paths in a single efficient query.

### LCA Algorithm

The lowest common ancestor is computed by:
1. Fetching the ltree paths for both nodes in a single query
2. Splitting paths into arrays and comparing element by element
3. The last matching element is the LCA

This approach requires only **one database query** regardless of tree depth.

### Descendant Queries

The `Bird.birds_for_nodes` scope uses PostgreSQL's ltree pattern matching (`~` operator) to find all birds belonging to nodes matching the pattern `*.{node_id}.*`, which includes the node itself and all descendants.

## Running Tests

```bash
bundle exec rspec
```

Key test files:
- `spec/models/node_spec.rb` - Node model and LCA tests
- `spec/models/bird_spec.rb` - Bird model and scope tests
- `spec/controllers/nodes_controller_spec.rb` - Nodes API tests
- `spec/controllers/birds_controller_spec.rb` - Birds API tests

## Performance Considerations

- **GiST Index:** The `path` column uses a GiST index for efficient ltree operations
- **Single Query LCA:** Finding the LCA requires only one database query to fetch both paths
- **Bulk Operations:** The recursive CTE in the rake task updates all paths in a single transaction
- **Pattern Matching:** Descendant queries leverage PostgreSQL's optimized ltree pattern matching

## License

This project is available as open source under the terms of the MIT License.
