# Makefile to build hello.cpp using UPC++

# Compiler wrapper and flags
UPCXX   := upcxx
CXXFLAGS := -O3  # Or use -g for debugging

# Source and target
SRC     := hello.cpp
TARGET  := hello

# Default rule
all: $(TARGET)

$(TARGET): $(SRC)
	$(UPCXX) $(CXXFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)
