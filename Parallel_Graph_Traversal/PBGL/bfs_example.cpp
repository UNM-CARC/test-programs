#include <queue>
#include <iostream>
#include <boost/graph/visitors.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/breadth_first_search.hpp>

typedef boost::property<boost::edge_weight_t, unsigned int> EdgeWeightProperty;
typedef boost::adjacency_list<boost::setS, boost::vecS, boost::undirectedS, 
                              boost::no_property, EdgeWeightProperty> Graph;

class BFSVisitor : public boost::default_bfs_visitor {
public:    
  BFSVisitor(std::queue<Graph::vertex_descriptor>& _visited) : visited(_visited){}
  void discover_vertex(Graph::vertex_descriptor s, const Graph &g) { visited.push(s); }
  std::queue<Graph::vertex_descriptor>& visited;
};

int main() {
  Graph g;
  boost::add_edge(0,1,6,g);
  boost::add_edge(1,2,6,g);
  boost::add_edge(2,3,6,g);
  boost::add_edge(3,1,6,g);
  boost::add_edge(3,4,6,g);

  Graph::vertex_descriptor s = *(boost::vertices(g).first);
  std::queue<Graph::vertex_descriptor> q;
  BFSVisitor vis(q);
  boost::breadth_first_search(g, s, boost::visitor(vis));
  while (!vis.visited.empty()) {
    std::cout << vis.visited.front() << std::endl;
    vis.visited.pop();
  }
}
