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

  //proc loadGraph(cookBook: CookBook) {
  proc loadGraph(recipeArray: []) {
      var idToString : [1..0] string,
          ingDom : domain(string),
          ingredients : domain(string),
          //ingredients : [ingDom] int,
          ingredientIds: [ingredients] int,
          t:Timer,
          edges: list((int, int));

      t.start();
      writeln("loading graph");
      //for recipe in cookBook.recipes {
      for recipe in recipeArray {
        for ingredient_1 in recipe.ingredients {
          //if ingDom.member(ingredient_1) == false {
          if ingredients.member(ingredient_1) == false {
            ingredients.add(ingredient_1);
            ingDom.add(ingredient_1);
            const ID = ingredients.size;
            //const ID = ingredientIds.last+1;
            ingredientIds[ingredient_1] = ID;
            //idToString.push_back(ingredient_1);
            //const ID = idToString.domain.last;
            //ingredients[ingredient_1] = ID;
          }
          for ingredient_2 in recipe.ingredients {
            //if ingDom.member(ingredient_2) == false {
            if ingredients.member(ingredient_2) == false {
              ingredients.add(ingredient_2);
              const ID = ingredients.size;
              //const ID = ingredientIds.last+1;
              ingDom.add(ingredient_2);
              ingredientIds[ingredient_2] = ID;

              /*
              idToString.push_back(ingredient_2);
              const ID = idToString.domain.last;
              ingDom.add(ingredient_2);
              ingredients[ingredient_2] = ID;
               */
            }

            if ingredientIds[ingredient_1] != ingredientIds[ingredient_2] {
              edges.append((ingredientIds[ingredient_1], ingredientIds[ingredient_2]));
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
      const g = GraphUtils.buildFromSparseMatrix(A, weighted=false, directed=false);
      return (g, ingredients, idToString, ingredientIds);
  }

  proc testIngredients(g:Graph, ingredients: [], idToString: [], cupboard: domain(string)) {
      var cupdom: sparse subdomain(g.Row.domain);
      for i in cupboard {
        cupdom += ingredients[i];
      }
      return cupdom;
  }

  //proc run(cupboard: domain(string)) {
  proc run() {
    var cookBook = loadTrainingData(data);
    const (G, ingredients, idToString) = loadGraph(cookBook);
    const ecdf = new ECDF(G.degree());

    var t2: Timer;
    t2.start();
    var ofile = try! open(output, iomode.cw).writer();
    try! ofile.write("recipe_id\toriginal_size\tknockout_size\tcrystal_energy\tcrystal_size\n");
    forall recipe in cookBook {
      var cupboard: domain(string);
      for ingredient in recipe.ingredients {
          cupboard += ingredient;
      }
      var tdom = testIngredients(G, ingredients, idToString, cupboard);

      write("recipe id: ", recipe.id, " original size: ", recipe.ingredients.size
        , " knockout size: ", cupboard.size
      );
      if cupboard.size > 1 {
        var msb = GraphEntropy.minimalSubGraph(G, tdom);
        writeln(" crystal energy: ", msb[1]
        , " crystal size: ", msb[2].size);
        try! ofile.write(
          recipe.id + "\t" + recipe.ingredients.size
          + "\t" + cupboard.size
          + "\t" + msb[1] + "\t" + msb[2].size + "\n");
      } else {
        writeln(" ...skipping...");
      }
    }
    try! ofile.close();
    t2.stop();
    if v {
      writeln("  ...time to build crystals: ", t2.elapsed());
    }
  }

  proc main() {
    writeln("in main...");
    run();
  }
}
