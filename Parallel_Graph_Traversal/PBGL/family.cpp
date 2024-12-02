#include <boost/graph/adjacency_list.hpp> // for customizable graphs
// Construct a graph with the vertices container as a vector

using namespace boost;

Vertex Step(Vertex current_node, Graph G) {
  double random_number = ud(gen);
  // Create two out_edge_iterators of the same type "Graph" as graph G
  graph_traits<Graph::GraphContainer>::out_edge_iterator eit, eend;

  // Select all outgoing edges from current_node
  std::tie(eit, eend) = out_edges( current_node, G);

  for( auto it = eit; it != eend; ++it) {
    //loop through all the edges and store the last seen target vertex
    Vertex target = boost::target(*it, G);
  }

  // return the last seen target vertex
  return target;
  }

enum family {Bob, Tod, Rob, Jeb, Sue, Ann, Mae, Rea, N};

int main()
{
  typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::directedS> Graph;
  // graph class is adjacency_list, vertices and edges will be stored in vectors
  // The graph will be undirected
  Graph g(8); //Create a graph sized for 8 vertices

  add_edge(Bob, Sue, g);
  add_edge(Bob, Mae, g);
  add_edge(Bob, Rob, g);
  add_edge(Sue, Ann, g);
  add_edge(Mae, Tod, g);
  add_edge(Rob, Jeb, g);
  add_edge(Rob, Rea, g);
  
 return 0;
}
