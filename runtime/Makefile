VERILATOR ?= verilator
TOP ?= tt_um_bjarke_micro_mac
BUILD_DIR ?= obj_dir
EXECUTABLE = $(BUILD_DIR)/V$(TOP)

.PHONY: all run

all: $(EXECUTABLE)

$(EXECUTABLE): ../src/project.v main.cpp
	$(VERILATOR) --cc --exe --build \
		--top-module $(TOP) \
		--Mdir $(BUILD_DIR) \
		../src/project.v main.cpp

run: all
	$(EXECUTABLE)
