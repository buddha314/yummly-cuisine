/*
chpl -M../src -M/Users/buddha/github/buddha314/numsuch/src thin-subgraph-test.chpl
 */
use Yummly;

writeln(" ***** \n\n");

var v: bool = false;
var cookBook = loadTrainingData("data/train.small.json");
const (G, ingredients, idToString, ingredientIds) = loadGraph(cookBook);

/*
 Build the thin sub-graph
 */
var ecdf = new ECDF(G.degree());
const p = 0.75;
var vs: domain(int) = for v in G.vs() do if ecdf(G.degree(v)) <= p then v;
const (subG, vertMap) = G.subgraph(vs);
writeln("Original size: ", G.vs().size, "  vs.size: ", subG.vs().size);
//writeln(subG.names());
//writeln(G.names());
var ofile = try!  open(output, iomode.cw).writer();
ofile.write("recipe_id\toriginal_size\tknockout_size\tcrystal_energy\tcrystal_size\n");

var t2: Timer;
t2.start();
var crystals: [1..0] Crystal;
forall recipe in cookBook {
  var crystal = new Crystal();

  for ingredient in recipe.ingredients do
    if subG.names().find(ingredient)(1) then crystal.originalElements.push_back(ingredient);

  var tdom: sparse subdomain(subG.vertices);
  for ing in crystal.originalElements do
    tdom += subG.names().find(ing)(2);
  if crystal.originalElements.size > 0 {
    crystal.initialEntropy = GraphEntropy.subgraphEntropy(subG, tdom);
    var (entropy, minDom) = GraphEntropy.minimalSubGraph(subG, tdom);
    crystal.entropy = entropy;

    for v in minDom {
      crystal.crystalElements.push_back(subG.names(v));
    }
  }
  if crystal.crystalElements.size != crystal.originalElements.size{
    writeln("*** entropy: ", crystal.initialEntropy, " -> ", crystal.entropy, " (", crystal.initialEntropy-crystal.entropy, ")");
    const o = crystal.originalElements.sorted();
    // Note degree(p) returns an array, should probably fix that.
    const od = for p in o do subG.degree(p)(1);
    var odo = for z in zip(o,od) do z;
    writeln("\tcrystal.originalElements: ", odo);

    const e = crystal.crystalElements.sorted();
    const ed = for p in e do subG.degree(p)(1);
    var ede = for z in zip(e, ed) do z;
    writeln("\t crystal.crystalElements: ", ede);
    writeln();
  }


  crystals.push_back(crystal);
}
ofile.close();
t2.stop();
writeln("  ...time to build crystals: ", t2.elapsed());
