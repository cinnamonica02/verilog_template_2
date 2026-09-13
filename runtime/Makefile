VERILATOR ?= verilator
PYTHON ?= python
TOP ?= tt_um_bjarke_micro_mac
BUILD_DIR ?= obj_dir
EXECUTABLE = $(BUILD_DIR)/V$(TOP)
PROGRAM = program.bin
EXPECTED = expected.bin

.PHONY: all run reference clean

all: $(EXECUTABLE) $(PROGRAM) $(EXPECTED)

$(EXECUTABLE): ../src/project.v main.cpp
	$(VERILATOR) --cc --exe --build \
		--trace \
		--top-module $(TOP) \
		--Mdir $(BUILD_DIR) \
		../src/project.v main.cpp

$(PROGRAM) $(EXPECTED): reference.py
	$(PYTHON) reference.py $(PROGRAM) $(EXPECTED)

reference: $(PROGRAM)

run: all
	$(EXECUTABLE) $(PROGRAM) $(EXPECTED)

clean:
	$(RM) -r $(BUILD_DIR) $(PROGRAM) $(EXPECTED) mxu.vcd
