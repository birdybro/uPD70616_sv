# V60 CPU SystemVerilog Simulation Makefile

# Simulator selection
SIM ?= verilator

# Source files
RTL_DIR = rtl
TB_DIR = tb
RTL_CORE = $(RTL_DIR)/core
RTL_MEM = $(RTL_DIR)/memory

VERILOG_SOURCES = \
	$(RTL_CORE)/v60_defines.sv \
	$(RTL_CORE)/v60_regfile.sv \
	$(RTL_CORE)/v60_alu.sv \
	$(RTL_CORE)/v60_decoder.sv \
	$(RTL_CORE)/v60_cpu.sv \
	$(RTL_MEM)/v60_memory_interface.sv

TB_SOURCES = \
	$(TB_DIR)/v60_cpu_tb.sv

# Output directory
BUILD_DIR = build

# Simulation options
SIM_TIME = 10000ns

# Verilator specific
VERILATOR_FLAGS = --cc --exe --build --trace
VERILATOR_FLAGS += -Wall -Wno-fatal
VERILATOR_FLAGS += --top-module v60_cpu_tb
VERILATOR_FLAGS += -I$(RTL_CORE) -I$(RTL_MEM)

# Icarus Verilog specific
IVERILOG_FLAGS = -g2012 -Wall
IVERILOG_FLAGS += -I$(RTL_CORE) -I$(RTL_MEM)

# Default target
all: sim

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Verilator simulation
verilator: $(BUILD_DIR)
	verilator $(VERILATOR_FLAGS) \
		--Mdir $(BUILD_DIR)/verilator \
		$(VERILOG_SOURCES) $(TB_SOURCES) \
		--binary -o v60_sim

verilator-run: verilator
	$(BUILD_DIR)/verilator/v60_sim

# Icarus Verilog simulation
iverilog: $(BUILD_DIR)
	iverilog $(IVERILOG_FLAGS) \
		-o $(BUILD_DIR)/v60_sim.vvp \
		$(VERILOG_SOURCES) $(TB_SOURCES)

iverilog-run: iverilog
	vvp $(BUILD_DIR)/v60_sim.vvp
	@echo "Generated v60_cpu_tb.vcd"

# ModelSim/QuestaSim simulation
modelsim: $(BUILD_DIR)
	cd $(BUILD_DIR) && vlib work
	cd $(BUILD_DIR) && vlog -sv -work work $(addprefix ../, $(VERILOG_SOURCES) $(TB_SOURCES))
	cd $(BUILD_DIR) && vsim -do "run $(SIM_TIME); quit" -c v60_cpu_tb

# Choose simulator
ifeq ($(SIM),verilator)
sim: verilator-run
else ifeq ($(SIM),iverilog)
sim: iverilog-run
else ifeq ($(SIM),modelsim)
sim: modelsim
else
sim:
	@echo "Unknown simulator: $(SIM)"
	@echo "Use: make sim SIM=verilator|iverilog|modelsim"
endif

# View waveforms
wave: v60_cpu_tb.vcd
	gtkwave v60_cpu_tb.vcd &

# Clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f v60_cpu_tb.vcd
	rm -f *.log *.jou

# Synthesis check (using Yosys)
synth-check:
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); hierarchy -top v60_cpu; proc; opt; check"

.PHONY: all sim verilator verilator-run iverilog iverilog-run modelsim wave clean synth-check