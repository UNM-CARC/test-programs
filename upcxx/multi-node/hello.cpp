#include <upcxx/upcxx.hpp>
#include <iostream>
int main()
{
  upcxx::init();
  std::cout << "Hello from " << upcxx::rank_me() << std::endl;
  upcxx::finalize();
  return 0;
}
