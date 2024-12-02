#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/erdos_renyi_generator.hpp>
#include <boost/random/linear_congruential.hpp>
#include <boost/graph/graphviz.hpp>
#include <ctime>            // std::time

typedef boost::adjacency_list<> Graph;
typedef boost::erdos_renyi_iterator<boost::minstd_rand, Graph> ERGen;

int main()
{
  boost::minstd_rand gen;
  gen.seed(static_cast<unsigned int>(std::time(0)));
  // Create graph with 100 nodes and edges with probability 0.25
  Graph g(ERGen(gen, 10, 0.25), ERGen(), 10);

  const char* name[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"};

  boost::write_graphviz(std::cout, g, boost::make_label_writer(name));

  return 0;
}
