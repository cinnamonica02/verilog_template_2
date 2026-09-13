VERILATOR ?= verilator
PYTHON ?= python
TOP ?= tt_um_bjarke_micro_mac
BUILD_DIR ?= obj_dir
EXECUTABLE = $(BUILD_DIR)/V$(TOP)
PROGRAM = program.bin

.PHONY: all run reference clean

all: $(EXECUTABLE) $(PROGRAM)

$(EXECUTABLE): ../src/project.v main.cpp
	$(VERILATOR) --cc --exe --build \
		--trace \
		--top-module $(TOP) \
		--Mdir $(BUILD_DIR) \
		../src/project.v main.cpp

$(PROGRAM): reference.py
	$(PYTHON) reference.py $(PROGRAM)

reference: $(PROGRAM)

run: all
	$(EXECUTABLE) $(PROGRAM)

clean:
	$(RM) -r $(BUILD_DIR) $(PROGRAM) mxu.vcd
