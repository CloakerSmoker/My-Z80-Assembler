
MAIN_FILE 		:= Z80
SOURCE_FILES 	:= $(MAIN_FILE).rlx Z80.txt

OUTPUT_DIR 		:= .
COMPILER_DIR 	:= compiler
OUTPUT_PATH	 	:= $(OUTPUT_DIR)/$(MAIN_FILE)

ifeq ($(OS),Windows_NT)
	PLATFORM_EXTENSION := exe
else
	PLATFORM_EXTENSION := elf
endif

COMPILER_PATH 	:= build/compiler.$(PLATFORM_EXTENSION)
FLAGS 		 	:= -i $(MAIN_FILE).rlx -o ../$(OUTPUT_PATH)

debug: setup
	-cd $(COMPILER_DIR); ./$(COMPILER_PATH) $(FLAGS).$(PLATFORM_EXTENSION) --debug
	chmod +x $(OUTPUT_PATH)

all: linux windows

linux: setup
	-cd $(COMPILER_DIR); ./$(COMPILER_PATH) $(FLAGS).elf --debug --elf
	chmod +x $(OUTPUT_PATH)

windows: setup
	-cd $(COMPILER_DIR); ./$(COMPILER_PATH) $(FLAGS).exe --debug --pe
	chmod +x $(OUTPUT_PATH)

setup:
	chmod +x $(COMPILER_DIR)/$(COMPILER_PATH)
	cp $(SOURCE_FILES) -u -t $(COMPILER_DIR)
