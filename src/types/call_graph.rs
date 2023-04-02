
use std::collections::{HashSet, HashMap, VecDeque};

type Group = HashSet<String>;

struct GroupData {
    funcs: HashSet<String>,
    adj_list: HashSet<usize>,
    indegree: usize
}

impl GroupData {
    pub fn new() -> GroupData {
        GroupData {funcs: HashSet::new(), adj_list: HashSet::new(), indegree: 0}
    }
}

type Edge = (String, String);
type GroupEdge = (usize, usize);

/// Represents the call graph of the input, split into groups
/// based on connected components and cycles. We use this to
/// choose an order for typechecking  functions, since checking
/// polymorphic functions in the wrong order can lead to incorrect
/// inference about free types.
#[derive(Debug)]
pub struct CallGraph {
    adj_lists: HashMap<String, HashSet<String>>,
    edges: HashSet<Edge>
}

impl CallGraph {

    pub fn new() -> CallGraph {
        CallGraph {adj_lists: HashMap::new(), edges: HashSet::new()}
    }

    /// Uses Warshall's algorithm to compute the transitive closure
    /// (reachability matrix) of every vertex in the graph
    fn compute_transitive_edges(&self) -> HashSet<Edge> {
        let mut transitive_edges = self.edges.clone();
        for (intermediate, _) in &self.adj_lists {
            for (from, _) in &self.adj_lists {
                let to_intermediate: Edge = (from.clone(), intermediate.clone());
                for (to, _) in &self.adj_lists {
                    let full_jump: Edge = (from.clone(), to.clone());
                    // Skip if we already know we can do the full jump.
                    if transitive_edges.contains(&full_jump) {
                        continue;
                    }
                    // Otherwise, if we have an edge to and from the intermediate, then we can do
                    // the full jump.
                    let from_intermediate: Edge = (intermediate.clone(), to.clone());
                    if transitive_edges.contains(&to_intermediate) && transitive_edges.contains(&from_intermediate) {
                        transitive_edges.insert(full_jump);
                    }
                }
            }
        }
        transitive_edges
    }

    fn create_groups(&self, 
        transitive_edges: &HashSet<Edge>, 
        group_ids: &mut HashMap<String, usize>,
        group_data_map: &mut HashMap<usize, GroupData>
    ) {
        let mut group_id_ctr = 0;

        for (vertex, _) in &self.adj_lists {

            // Skip funcs already in a group, since it and all its group members
            // have already been added.
            if group_ids.contains_key(vertex) {
                continue;
            }


            let mut new_group = GroupData::new();
            new_group.funcs.insert(vertex.clone());
            group_ids.insert(vertex.clone(), group_id_ctr);

            // Add mutually dependent functions to our current group.
            for (other_vertex, _) in &self.adj_lists {
                let forward_edge: Edge = (vertex.clone(), other_vertex.clone());
                let backward_edge: Edge = (other_vertex.clone(), vertex.clone());
                if transitive_edges.contains(&forward_edge) && transitive_edges.contains(&backward_edge) {
                    group_ids.insert(other_vertex.clone(), group_id_ctr);
                    new_group.funcs.insert(other_vertex.clone());
                }
            }
            group_data_map.insert(group_id_ctr, new_group);
            group_id_ctr += 1;
        }
    }

    fn create_edges(&self, 
        group_ids: &mut HashMap<String, usize>,
        group_data_map: &mut HashMap<usize, GroupData>)
    {
        let mut group_edges = HashSet::new();
        
        for (vertex, other_vertices) in &self.adj_lists {
            let vertex_id = group_ids[vertex];

            for other_vertex in other_vertices {
                let other_id = group_ids[other_vertex];
                let to_other: GroupEdge = (vertex_id, other_id);
                if vertex_id == other_id || group_edges.contains(&to_other) {
                    continue;
                }
                group_edges.insert(to_other);
                group_data_map.get_mut(&vertex_id).unwrap().adj_list.insert(other_id);
                group_data_map.get_mut(&other_id).unwrap().indegree += 1
            }
        }
    }

    // Basic topological sort of each group
    fn generate_order(&self,
        _group_ids: &mut HashMap<String, usize>,
        mut group_data_map: HashMap<usize, GroupData>) -> Vec<Group>
    {
        let mut id_queue = VecDeque::new();
        let mut res = Vec::new();

        for (group_id, group_data) in &group_data_map {
            if group_data.indegree == 0 {
                id_queue.push_back(*group_id);
            }
        }

        while let Some(new_id) = id_queue.pop_front() {
            let group_data = group_data_map.remove(&new_id).unwrap();
            let out_group = group_data.funcs;

            for adjacent_group in group_data.adj_list {
                let adj_grp_ref = group_data_map.get_mut(&adjacent_group).unwrap();
                adj_grp_ref.indegree -= 1;
                if adj_grp_ref.indegree == 0 {
                    id_queue.push_back(adjacent_group);
                }
            }

            res.push(out_group)
        }
        res
    }

    pub fn compute_order(&self) -> Vec<Group> {
        let transitive_edges = self.compute_transitive_edges();
        let mut group_ids = HashMap::new();
        let mut group_data_map = HashMap::new();

        self.create_groups(&transitive_edges, &mut group_ids, &mut group_data_map);
        self.create_edges(&mut group_ids, &mut group_data_map);
        self.generate_order(&mut group_ids, group_data_map)
    }

    pub fn add_function<'a>(&'a mut self, function: &String) -> &'a mut HashSet<String> {
        self.adj_lists.entry(function.clone()).or_insert(HashSet::new())
    }

    pub fn add_edge(&mut self, from: &String, to: &String) {
        self.add_function(from).insert(to.clone());
        self.edges.insert((from.clone(), to.clone()));
    }
}