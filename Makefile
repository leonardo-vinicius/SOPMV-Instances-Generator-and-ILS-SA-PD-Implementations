CXX ?= g++
CXXFLAGS ?= -O3 -std=c++17 -Wall -Wextra -pedantic
BIN := bin
CORE := algorithms/core/instance.cpp algorithms/core/solution_validator.cpp

.PHONY: all generator greedy ils sa-pd clean

all: generator greedy ils sa-pd

$(BIN):
	mkdir -p $(BIN)

generator: $(BIN)
	$(CXX) $(CXXFLAGS) -Ialgorithms/core algorithms/generate_main.cpp algorithms/core/instance.cpp algorithms/core/sopmv_generator.cpp -o $(BIN)/sopmv-generator

greedy: $(BIN)
	$(CXX) $(CXXFLAGS) -Ialgorithms/core -Ialgorithms/greedy algorithms/greedy/main.cpp algorithms/greedy/greedy.cpp $(CORE) -o $(BIN)/sopmv-greedy

ils: $(BIN)
	$(CXX) $(CXXFLAGS) -Ialgorithms/core -Ialgorithms/greedy -Ialgorithms/ils algorithms/ils/main.cpp algorithms/ils/ils.cpp algorithms/greedy/greedy.cpp $(CORE) -o $(BIN)/sopmv-ils

sa-pd: $(BIN)
	$(CXX) $(CXXFLAGS) -Ialgorithms/core -Ialgorithms/sa_pd algorithms/sa_pd/main.cpp algorithms/sa_pd/sa_pd.cpp $(CORE) -o $(BIN)/sopmv-sa-pd

clean:
	rm -rf $(BIN)
