VCS = vcs
VERDI = verdi

TARGET_DIR := $(shell pwd)/fifo  # CHECKME

# Define the source files
PROJ_DIR := $(shell pwd)
SIM_DIR := $(PROJ_DIR)/sim
UTIL_DIR := $(PROJ_DIR)/utils
SRC_DIR := $(SIM_DIR)/src

# Define the top module name
# TOP_MODULE = $(TARGET_DIR)/sync_tb
# TOP_MODULE = tb_SyncPulse
TOP_MODULE = async_fifo_tb

# Define the simulation binary
SIM_BINARY = $(SIM_DIR)/simv
SRC_FILES := $(shell find $(TARGET_DIR) $(UTIL_DIR) -name "*.v" -or -name "*.sv")
# Define the dump file
DUMP_FILE = $(SIM_DIR)/$(TOP_MODULE).fsdb

LOG_FILE = $(SIM_DIR)/sim.log
FILELIST = $(SIM_DIR)/filelist.f

$(SIM_DIR):
	mkdir -p $(SIM_DIR)  
# -p 自动创建尚不存在的路径参数

# addprefix 为每个文件名添加前缀
# Compile and simulate
all: filelist vcs sim wave

filelist: $(SIM_DIR)
	echo $(SRC_FILES) | tr ' ' '\n' > $(FILELIST)

vcs: filelist
	cd $(SIM_DIR); \
	vcs -full64 -sverilog -kdb -lca -l vcs.log -f $(SIM_DIR)/filelist.f -top $(TOP_MODULE) -LDFLAGS -Wl,--no-as-needed -debug_access+r

sim: vcs
	cd $(SIM_DIR); \
	$(SIM_BINARY) -l $(LOG_FILE)

wave: sim
	$(VERDI) --nologo -ssf $(DUMP_FILE)


clean:
	rm -rf $(SIM_DIR)

.PHONY: all compile run view_waveform clean