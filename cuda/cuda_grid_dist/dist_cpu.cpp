#include <math.h> //Include standard math library containing sqrt.
#include <chrono>
#include <iostream>
#include <sstream>
using namespace std::chrono;
using namespace std;

// Convenience function to format human friendly elapsed time 
#include <iomanip>
#include <optional>
#include <ostream>

template<typename T>
inline std::string format(T timeunit) {
  nanoseconds ns = duration_cast<nanoseconds>(timeunit);
  std::ostringstream os;
  bool foundNonZero  = false;
  os.fill('0');
  typedef duration<int, std::ratio<86400*365>> years;
  const auto y = duration_cast<years>(ns);
  if (y.count()) {
    foundNonZero = true;
    os << y.count() << "y:";
    ns -= y;
  }
  typedef duration<int, std::ratio<86400>> days;
  const auto d = duration_cast<days>(ns);
  if (d.count()) {
    foundNonZero = true;
    os << d.count() << "d:";
    ns -= d;
  }
  const auto h = duration_cast<hours>(ns);
  if (h.count() || foundNonZero) {
    foundNonZero = true;
    os << h.count() << "h:";
    ns -= h;
  }
  const auto m = duration_cast<minutes>(ns);
  if (m.count() || foundNonZero) {
    foundNonZero = true;
    os << m.count() << "m:";
    ns -= m;
  }
  const auto s = duration_cast<seconds>(ns);
  if (s.count() || foundNonZero) {
    foundNonZero = true;
    os << s.count() << "s:";
    ns -= s;
  }
  const auto ms = duration_cast<milliseconds>(ns);
  if (ms.count() || foundNonZero) {
    if (foundNonZero) {
      os << std::setw(3);
    }
    os << ms.count() << "ms.";
    ns -= ms;
    foundNonZero = true;
  }
  const auto us = duration_cast<microseconds>(ns);
  if (us.count() || foundNonZero) {
    if (foundNonZero) {
      os << std::setw(3);
    }
    os << us.count() << ".";
    ns -= us;
  }
  os << std::setw(3) << ns.count() << "ns" ;
  return os.str();
}


// A scaling function to convert integers 0,1,...,N-1 to evenly spaced floats 
float scale(int i, int n)
{
  return ((float)i) / (n - 1);
}
// Compute the distance between 2 points on a line.
float distance(float x1, float x2)
{
  return sqrt((x2 - x1)*(x2 - x1));
}
// main function
int main( int argc, char* argv[])
{
  int N = atoi(argv[1]);
  auto t1 = high_resolution_clock::now();
  float out[N] = {0.0};
  // Choose a reference value from which distances are measured.
  const float ref = 0.5;
  
  for (int i = 0; i < N; ++i)
    {
      float x = scale(i, N);
      out[i] = distance(x, ref);
    }
  auto t2 = high_resolution_clock::now();

  /* Getting number of milliseconds as an integer. */
  auto duration_ms = duration_cast<milliseconds>(t2 - t1);

  cout.precision(3);

  cout << "Calcuated " << float(N) <<  " Distances in Time: " << format( duration_ms ) << endl;  
  cout << "First distance: " << out[0] << endl;
  cout << "Second distance: " << out[1] << endl;
  cout << "Last distance: " << out[N-1] << endl;

  return 0;
}
