CC=chpl
FLAGS=--fast
#NUMSUCH_HOME=/Users/buddha/github/buddha314/numsuch/src/
NUMSUCH_HOME=/home/buddha314/numsuch/src
#DATA_FILE=/datasets/recipe-kaggle/train.json
DATA_FILE=/home/buddha314/datasets/yummly/train.json
MODULES=-M$(NUMSUCH_HOME)

default: yummly

yummly: yummlyAnalysis.chpl
	$(CC) $(FLAGS) $(MODULES) -o yummlyAnalysis $<
	#$(CC) $(MODULES) -o yummlyAnalysis $<

run:
	./yummlyAnalysis --data=$(DATA_FILE)
