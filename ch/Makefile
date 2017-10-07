CC=chpl
MODULES=-M${NUMSUCH_HOME}
INCLUDES=-I$(BLAS_HOME)/include
LIBS=-L${BLAS_HOME}/lib -lblas
EXEC=yummly
default: yummly

yummly: src/Yummly.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o $(EXEC) $<

run:
	./$(EXEC) --data=$(DATA_FILE) --output=$(OUTPUT_FILE)
