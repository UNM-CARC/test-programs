#include <boost/config.hpp>
#include <boost/version.hpp>
#include <boost/graph/graph_utility.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/property_map/property_map.hpp>
#include <boost/static_assert.hpp>

// Enable PBGL interfaces to BGL algorithms
#include <boost/graph/use_mpi.hpp>

// Communication via MPI
#include <boost/graph/distributed/mpi_process_group.hpp>

// Distributed adjacency list
#include <boost/graph/distributed/adjacency_list.hpp>

using namespace boost;
using boost::graph::distributed::mpi_process_group;
using namespace std;

// VertexProperties is the property container that will be passed into the
// templated graph object - should work for serial and parallel versions
struct VertexProperties
{
  VertexProperties(){}
  VertexProperties( std::string n )
  {
    this->name = n;
  }

  std::string name;
};

// EdgeProperties is the property container that will be passed into the
// templated graph object - should work for serial and parallel versions
struct EdgeProperties
{
  EdgeProperties(){}

  EdgeProperties(int d)
  {
    this->distance = d;
  }
  
  int distance = 0;
};

/* definition of basic boost::graph properties */
enum vertex_properties_t { vertex_properties };
enum edge_properties_t { edge_properties };

namespace boost {
  BOOST_INSTALL_PROPERTY(vertex, properties);
  BOOST_INSTALL_PROPERTY(edge, properties);
}

// Graph Class
template < typename VERTEXPROPERTIES, typename EDGEPROPERTIES >
class Graph
{
public:
  /* a distributed adjacency list */
  /* An undirected, weighted graph with distance values stored on the vertices. */
  typedef adjacency_list<vecS, distributedS<mpi_process_group, vecS>,
			 bidirectionalS, // directed graph
			 property<vertex_properties_t, VERTEXPROPERTIES>,
			 property<edge_properties_t, EDGEPROPERTIES> >
  GraphContainer;

  /* typedefs to begin normalization of Boost syntax */
  typedef typename graph_traits<GraphContainer>::vertex_descriptor Vertex;
  typedef typename graph_traits<GraphContainer>::edge_descriptor Edge;
  typedef std::pair<Edge, Edge> EdgePair;

  typedef typename graph_traits<GraphContainer>::vertex_iterator vertex_iter;
  typedef typename graph_traits<GraphContainer>::edge_iterator edge_iter;
  typedef typename graph_traits<GraphContainer>::adjacency_iterator adjacency_iter;
  typedef typename graph_traits<GraphContainer>::out_edge_iterator out_edge_iter;
  typedef typename graph_traits<GraphContainer>::degree_size_type degree_t;

  typedef std::pair<adjacency_iter, adjacency_iter> adjacency_vertex_range_t;
  typedef std::pair<out_edge_iter, out_edge_iter> out_edge_range_t;
  typedef std::pair<vertex_iter, vertex_iter> vertex_range_t;
  typedef std::pair<edge_iter, edge_iter> edge_range_t;


  /* constructors etc. */
  Graph()
  {
  }

  Graph(const Graph& g):
    graph(g.graph)
  {
  }

  virtual ~Graph()
  {
  }

  /* structure modification methods */
  void Clear()
  {
    graph.clear();
  }

  Vertex AddVertex(const VERTEXPROPERTIES& prop)
  {
    Vertex v = add_vertex(graph);
    properties(v) = prop;
    return v;
  }

  void RemoveVertex(const Vertex& v)
  {
    clear_vertex(v, graph);
    remove_vertex(v, graph);
  }

EdgePair AddEdge(const Vertex& v1, const Vertex& v2, const EDGEPROPERTIES& prop_12, const EDGEPROPERTIES& prop_21)
  {
    /* TODO: maybe one wants to check if this edge could be inserted */
    Edge addedEdge1 = add_edge(v1, v2, graph).first;
    Edge addedEdge2 = add_edge(v2, v1, graph).first;
    
    properties(addedEdge1) = prop_12;
    properties(addedEdge2) = prop_21;
    
    return EdgePair(addedEdge1, addedEdge2);
  }
  
  Edge AddDirectedEdge(const Vertex& v1, const Vertex& v2, const EDGEPROPERTIES& prop)
  {
    return add_edge(v1, v2, graph).first;
  }

  /* selectors and properties */

  adjacency_vertex_range_t getAdjacentVertices(const Vertex& v) const
  {
    return adjacent_vertices(v, graph);
  }

  int getVertexCount() const
  {
    return num_vertices(graph);
  }

  int getVertexDegree(const Vertex& v) const
  {
    return degree(v, graph);
  }
  
protected:
  GraphContainer graph;

}; // End Graph Class Definition
