VERILATOR ?= verilator
PYTHON ?= python3
TOP ?= tt_um_bjarke_micro_mac
BUILD_DIR ?= obj_dir
EXECUTABLE = $(BUILD_DIR)/V$(TOP)
PROGRAM = program.bin
EXPECTED = expected.bin
TRANSFORMER_PROGRAM = transformer.bin
TRANSFORMER_EXPECTED = transformer.expected

.PHONY: all run reference transformer clean

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

$(TRANSFORMER_PROGRAM) $(TRANSFORMER_EXPECTED): tiny_transformer.py reference.py
	$(PYTHON) tiny_transformer.py $(TRANSFORMER_PROGRAM) $(TRANSFORMER_EXPECTED)

transformer: $(EXECUTABLE) $(TRANSFORMER_PROGRAM) $(TRANSFORMER_EXPECTED)
	$(EXECUTABLE) $(TRANSFORMER_PROGRAM) $(TRANSFORMER_EXPECTED)

clean:
	$(RM) -r $(BUILD_DIR) $(PROGRAM) $(EXPECTED) $(TRANSFORMER_PROGRAM) $(TRANSFORMER_EXPECTED) mxu.vcd
