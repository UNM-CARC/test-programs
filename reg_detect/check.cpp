#include <iostream>
using namespace std;

int main(int argc, char* argv[])
{
  cout << "This processor does ";
  if(!__builtin_cpu_supports( "avx" ) )
    cout << "not ";
  cout << "support avx" << endl;
  return 0;
}
