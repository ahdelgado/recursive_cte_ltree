# Please see:
* lib/tasks/update_ltree_path.rake
* app/models/node.rb
* app/models/bird.rb
* app/controllers/api/nodes_controller.rb
* app/controllers/api/birds_controller.rb
* spec/controllers/nodes_controller_spec.rb
* spec/controllers/birds_controller_spec.rb
* spec/models/node_spec.rb
* spec/models/bird_spec.rb


## Problem Statement
We have an adjacency list that creates a tree of nodes where a child's `parent_id` = a parent's `id`.

Please make an API using PostgreSQL and Ruby on Rails

### 1. Common Ancestor
`/api/nodes/:node_a_id/common_ancestors/:node_b_id` - It should return the `root_id`, `lowest_common_ancestor_id`, and `depth` of tree of the lowest common ancestor that those two node ids share.

For example, given the data for nodes:
```
   id    | parent_id
---------+-----------
     125 |       130
     130 |          
 2820230 |       125
 4430546 |       125
 5497637 |   4430546
```

`/api/nodes/5497637/common_ancestors/2820230` should return
`{root_id: 130, lowest_common_ancestor: 125, depth: 2}`

`/api/nodes/5497637/common_ancestors/130` should return
`{root_id: 130, lowest_common_ancestor: 130, depth: 1}`

`/api/nodes/5497637/common_ancestors/4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

if there is no common node match, return nil for all fields

`/api/nodes/9/common_ancestors/4430546` should return
`{root_id: nil, lowest_common_ancestor: nil, depth: nil}`

if a==b, it should return itself

`/api/nodes/4430546/common_ancestors/4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

### 2. Birds

Another endpoint `api/birds` - The second requirement for this project involves considering a second model, birds. Nodes have_many birds and birds belong_to nodes. Our second endpoint should take a list of `node_ids` and return the ids of the birds that belong to any of those nodes or any descendant nodes.

## Common Ancestor Solution
**API Endpoint:** This application exposes an API endpoint `/api/nodes/:node_a_id/common_ancestors/:node_b_id` to find the lowest common ancestor between two nodes. The endpoint accepts two parameters `node_a_id` and `node_b_id` and returns the lowest common ancestor along with its depth and root_id.

**Hierarchical Ltree Path Maintenance:**  The `Node` model maintains a path attribute of ltree data type. This path attribute is critical for fetching the lowest common ancestor for 2 particular nodes.

**Benefits**
- Efficient LCA Calculation: Once the ltree column is maintained and updated properly, determining the LCA between two nodes becomes a fast and straightforward operation. This simplifies querying operations related to hierarchical structures. One only needs to fetch the `path` attribute of 2 nodes to see their hierarchy, including ancestors, descendants, and their LCA.

## Birds Solution

### Overview
**API Endpoint:** This application exposes an API endpoint `/api/birds` that accepts an array of node_ids and returns the ids of the birds that belong to any of those nodes or any descendant nodes.

### Named Scope: `birds_for_nodes`
The `Bird` model defines a named scope `birds_for_nodes`, which retrieves bird IDs associated with specified nodes or their descendant nodes. This scope leverages the nodes ltree path attribute and is dependant upon the data integrity of this ltree hierarchy data.
