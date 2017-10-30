CC=chpl
MODULES=-M${NUMSUCH_HOME}
INCLUDES=-I$(BLAS_HOME)/include
LIBS=-L${BLAS_HOME}/lib -lblas
EXEC=yummly
DEGREE_ECDF=0.75
default: yummly

yummly: src/Yummly.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o $(EXEC) $<

run:
	#./$(EXEC) --data=$(DATA_FILE) --e=$(DEGREE_ECDF) $(OPTS) --output=$(OUTPUT_FILE)
	./$(EXEC) --data=$(DATA_FILE) $(OPTS) --output=$(OUTPUT_FILE)

lib: src/Yummly.chpl
	$(CC) --library $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o $(EXEC) $< --savec cDir
