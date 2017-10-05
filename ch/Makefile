CC=chpl
MODULES=-M${NUMSUCH_HOME}
INCLUDES=-I$(BLAS_HOME)/include
LIBS=-L${BLAS_HOME}/lib -lblas
default: yummly

yummly: yummlyAnalysis.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o yummlyAnalysis $<

run:
	./yummlyAnalysis --data=$(DATA_FILE)
