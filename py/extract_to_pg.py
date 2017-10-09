import json
#data = "../ch/test/data/train.small.json"
data = "/datasets/recipe-kaggle/train.json"
outfile = "yummly.txt"
with open(data) as f:
    test_data = json.load(f)

ofile = open(outfile, "w")

for x in test_data['recipes']:
    cuisine = x['cuisine'].encode('utf-8').strip()
    recipe = x['id']
    for i in x['ingredients']:
        #print("{c}\t{r}\t{i}".format(c=cuisine, r = recipe, i=i.encode('utf-8').strip()))
        ofile.write("{c}\t{r}\t{i}\n".format(c=cuisine, r = recipe, i=i.encode('utf-8').strip()))
