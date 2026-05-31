CC      ?= gcc
MPICC   ?= mpicc
CFLAGS  ?= -O3 -Wall -Wextra -std=c11 -Iinclude
LDFLAGS ?= -lm
OMPFLAGS ?= -fopenmp

BIN_DIR = bin
SRC_DIR = src

.PHONY: all serial openmp race mpi clean run-serial run-openmp benchmark

all: serial openmp

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

serial: $(BIN_DIR)/pi_serial
openmp: $(BIN_DIR)/pi_openmp
race: $(BIN_DIR)/pi_openmp_race_demo
mpi: $(BIN_DIR)/pi_mpi

$(BIN_DIR)/pi_serial: $(SRC_DIR)/pi_serial.c include/pi_common.h | $(BIN_DIR)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

$(BIN_DIR)/pi_openmp: $(SRC_DIR)/pi_openmp.c include/pi_common.h | $(BIN_DIR)
	$(CC) $(CFLAGS) $(OMPFLAGS) $< -o $@ $(LDFLAGS)

$(BIN_DIR)/pi_openmp_race_demo: $(SRC_DIR)/pi_openmp_race_demo.c include/pi_common.h | $(BIN_DIR)
	$(CC) $(CFLAGS) $(OMPFLAGS) $< -o $@ $(LDFLAGS)

$(BIN_DIR)/pi_mpi: $(SRC_DIR)/pi_mpi.c include/pi_common.h | $(BIN_DIR)
	$(MPICC) $(CFLAGS) $< -o $@ $(LDFLAGS)

run-serial: serial
	./$(BIN_DIR)/pi_serial 100000000

run-openmp: openmp
	./$(BIN_DIR)/pi_openmp 100000000 4

benchmark: all
	python3 scripts/benchmark.py 100000000 3 1,2,4,8

clean:
	rm -rf $(BIN_DIR)/*.o $(BIN_DIR)/pi_serial $(BIN_DIR)/pi_openmp $(BIN_DIR)/pi_openmp_race_demo $(BIN_DIR)/pi_mpi results/*.csv
