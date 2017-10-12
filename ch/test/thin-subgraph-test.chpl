/*
chpl -M../src -M/Users/buddha/github/buddha314/numsuch/src thin-subgraph-test.chpl
 */
use Yummly;

writeln(" ***** \n\n");

var v: bool = false;
var cookBook = loadTrainingData("data/train.small.json");
const (G, ingredients, idToString) = loadGraph(cookBook);

/*
 Build the thin sub-graph
 */
var ecdf = new ECDF(G.degree());
const p = 0.75;
var vs: domain(int) = for v in G.vs() do if ecdf(G.degree(v)) <= p then v;
writeln("Original size: ", G.vs().size, "  vs.size: ", vs.size);
var ofile = try!  open(output, iomode.cw).writer();
ofile.write("recipe_id\toriginal_size\tknockout_size\tcrystal_energy\tcrystal_size\n");

var t2: Timer;
t2.start();
//forall recipe in cookBook.recipes {
forall recipe in cookBook {
  var cupboard: domain(string);
  var rands: [1..recipe.ingredients.size] real;
  var i = 1;
  fillRandom(rands);
  for ingredient in recipe.ingredients {
    if rands[i] < p {
      cupboard += ingredient;
      i += 1;
    }
  }

  var tdom = testIngredients(G, ingredients, idToString, cupboard);
  if v {
    write("recipe id: ", recipe.id, " original size: ", recipe.ingredients.size
      , " knockout size: ", cupboard.size
    );
  }
  if cupboard.size > 1 {
    var msb = GraphEntropy.minimalSubGraph(G, tdom);
    if v {
      writeln(" crystal energy: ", msb[1]
      , " crystal size: ", msb[2].size);
    }
    ofile.write(
      recipe.id + "\t" + recipe.ingredients.size
      + "\t" + cupboard.size
      + "\t" + msb[1] + "\t" + msb[2].size + "\n");
  }
}
ofile.close();
t2.stop();
writeln("  ...time to build crystals: ", t2.elapsed());
