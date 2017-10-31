module Yummly {
  use IO,
      LayoutCS,
      Random,
      Time;
  use NumSuch;

  config const output: string = "output.txt";
  config const data: string;
  config const p: real = 0.95; // random knockout probability
  config const e: real = 0.95; // degrees of ecdf > e get ignored

  record Recipe {
    var cuisine: string,
        id: int,
        ingredients: list(string);
  }
  record CookBook {
    var recipes: list(Recipe);
  }

  /*
  Takes a JSON file and loads it into an array of Recipes
   */
  proc loadTrainingData(infile: string) {
    var cookBook = new CookBook();  // discarded at the end
    var recipeList: list(Recipe);
    try {
      var f = open(infile, iomode.r);
      var r = f.reader();
      r.readf("%jt\n", cookBook);
    } catch {
      halt();
    }
    var recipeArray = for recipe in cookBook.recipes do recipe;
    return recipeArray;
  }

  proc loadGraph(recipeArray: []) {
      var idToString : [1..0] string,
          vertices: domain(1)= {1..0},
          ingDom : domain(string),
          ingredients : [vertices] string,
          ingredientIds: [vertices] int,
          t:Timer,
          edges: list((int, int));
      t.start();
      writeln("loading graph");
      for recipe in recipeArray {
        for ingredient_1 in recipe.ingredients {
          if ingredients.find(ingredient_1)(1) == false {
            vertices = {1..vertices.size+1};
            const ID = vertices.size;
            ingredients[ID] = ingredient_1;

          }
          for ingredient_2 in recipe.ingredients {
            if ingredients.find(ingredient_2)(1) == false {
              vertices = {1..vertices.size+1};
              const ID = vertices.size;
              ingredients[ID] = (ingredient_2);
            }
            var (i,j) = (ingredients.find(ingredient_1)(2), ingredients.find(ingredient_2)(2));
            if i != j {
              edges.append((i,j));
            }
          }
        }
      }
      var D: domain(2) = {1..ingredients.size, 1..ingredients.size};
      var SD: sparse subdomain(D) dmapped CS(),
          A: [SD] real;
      for e in edges {
        var i = e[1],
            j = e[2];
        if !SD.member((i,j)) {
          SD += (i, j);
          A[i,j] = 1;
        } else {
          A[i,j] += 1;
        }
      }
      t.stop();
      writeln("...time to load matrix: ", t.elapsed());
      const g = GraphUtils.buildFromSparseMatrix(A, weighted=false
        , directed=false, names=ingredients);
      return (g, ingredients, idToString, ingredientIds);
  }

  proc testIngredients(g:Graph, ingredients: [], idToString: [], cupboard: domain(string)) {
      var cupdom: sparse subdomain(g.Row.domain);
      for i in cupboard {
        cupdom += ingredients[i];
      }
      return cupdom;
  }

  proc buildCrystals(G, cookBook, ingredients, idToString, ingredientIds, ecdf) {
    const p:real = 0.75;
    var vs: domain(int) = for v in G.vs() do if ecdf(G.degree(v)) <= p then v;
    const (subG, vertMap) = G.subgraph(vs);
    writeln("Original size: ", G.vs().size, "  vs.size: ", subG.vs().size);


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
      if crystal.crystalElements.size != crystal.originalElements.size && false {
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
      crystal.id = recipe.id;
      crystals.push_back(crystal);
    }
    t2.stop();
    writeln("  ...time to build crystals: ", t2.elapsed());
    return crystals;
  }

  proc persistCrystals(crystals) {
    // Now write the results
    var ofile = try!  open(output, iomode.cw).writer();
    try! ofile.write("recipe_id\tinitial_entropy\tentropy\toriginal_elements\tcrystal_element\n");
    for crystal in crystals {
      try! ofile.write(crystal.id, "\t",
        crystal.initialEntropy, "\t",
        crystal.entropy, "\t",
        ":".join(crystal.originalElements), "\t",
        ":".join(crystal.crystalElements), "\n"
      );
    }
    try! ofile.close();
    return true;
  }

  export proc run() {
    const cookBook = loadTrainingData(data);
    const (G, ingredients, idToString, ingredientIds) = loadGraph(cookBook);
    const ecdf = new ECDF(G.degree());
    const crystals = buildCrystals(G, cookBook, ingredients, idToString, ingredientIds, ecdf);
    persistCrystals(crystals);
  }

  /*
  Provided for command-line execution.  This is useful since start_test times out.
   */
  proc main(args: [] string) {
    writeln("in main");
    run();
  }

}
