CC=chpl
MODULES=-M${NUMSUCH_HOME}
INCLUDES=-I$(BLAS_HOME)/include
LIBS=-L${BLAS_HOME}/lib -lblas
EXEC=yummly
ECDF_THRESHOLD=0.99
default: yummly

yummly: src/Yummly.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o $(EXEC) $<

run:
	date
	./$(EXEC) $(EXECFLAGS) --data=$(DATA_FILE) $(OPTS) --output=$(OUTPUT_FILE) --inflations=$(INFLATION_FILE) --ecdf_threshold=$(ECDF_THRESHOLD)
	date

lib: src/Yummly.chpl
	$(CC) --library $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o $(EXEC) $< --savec cDir
