module Yummly {
  use IO,
      LayoutCS,
      Random,
      Time;
  use NumSuch;

  config const output: string = "output.txt";
  config const data: string;
  config const v: bool = false;  // boolean for verbosity
  config const p: real = 0.95; // random knockout probability

  record Recipe {
    var cuisine: string,
        id: int,
        ingredients: list(string);
  }
  record CookBook {
    var recipes: list(Recipe);
  }


  proc loadTrainingData() {
    var cookBook = new CookBook();
    try {
      var f = open(data, iomode.r);
      var r = f.reader();
      r.readf("%jt\n", cookBook);
    } catch {
      halt();
    }
    return cookBook;
  }

  proc loadGraph(cookBook: CookBook) {
      var idToString : [1..0] string,
          ingDom : domain(string),
          ingredients : [ingDom] int;
      var t:Timer;
      var edges: list((int, int));
      t.start();
      writeln("loading graph");
      for recipe in cookBook.recipes {
        for ingredient_1 in recipe.ingredients {
          if ingDom.member(ingredient_1) == false {
            idToString.push_back(ingredient_1);
            const ID = idToString.domain.last;
            ingDom.add(ingredient_1);
            ingredients[ingredient_1] = ID;
          }
          for ingredient_2 in recipe.ingredients {
            if ingDom.member(ingredient_2) == false {
              idToString.push_back(ingredient_2);
              const ID = idToString.domain.last;
              ingDom.add(ingredient_2);
              ingredients[ingredient_2] = ID;
            }

            if ingredients[ingredient_1] != ingredients[ingredient_2] {
              edges.append((ingredients[ingredient_1], ingredients[ingredient_2]));
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
      return (g, ingredients, idToString);
  }

  proc testIngredients(g:Graph, ingredients: [], idToString: [], cupboard: domain(string)) {
      var cupdom: sparse subdomain(g.Row.domain);
      for i in cupboard {
        if v {
          writeln("\tingredient ", i, " has id ", ingredients[i]);
        }
        cupdom += ingredients[i];
      }
      return cupdom;
  }

  //proc run(cupboard: domain(string)) {
  proc run() {
    var cookBook = loadTrainingData();
    var r = loadGraph(cookBook);
    const g = r[1];
    var ingredients = r[2];
    var idToString = r[3];
    if v {
      writeln("Number of ingredients: ", g.vertices);
      writeln("No, the actual number of ingredients: ", ingredients.size);
    }
    try {
      var t2: Timer;
      t2.start();
      var ofile = open(output, iomode.cw).writer();
      ofile.write("recipe_id\toriginal_size\tknockout_size\tcrystal_energy\tcrystal_size\n");
      coforall recipe in cookBook.recipes {
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
        var tdom = testIngredients(g, ingredients, idToString, cupboard);
        write("recipe id: ", recipe.id, " original size: ", recipe.ingredients.size
          , " knockout size: ", cupboard.size
        );
        if cupboard.size > 1 {
          var msb = GraphEntropy.minimalSubGraph(g, tdom);
          writeln(" crystal energy: ", msb[1]
          , " crystal size: ", msb[2].size);
          ofile.write(
            recipe.id + "\t" + recipe.ingredients.size
            + "\t" + cupboard.size
            + "\t" + msb[1] + "\t" + msb[2].size + "\n");
        } else {
          writeln(" ...skipping...");
        }
      }
      ofile.close();
      t2.stop();
      writeln("  ...time to build crystals: ", t2.elapsed());
    } catch {
      halt("cannot open output file ", output);
    }
    /*
    var tdom = testIngredients(g, ingredients, idToString, cupboard);
    writeln("IDs to test ", tdom);
    var msb = GraphEntropy.minimalSubGraph(g, tdom);
    writeln("Minimal subgraph: ", msb);
    var energy = msb[1];
    var nodes = msb[2];
    for n in nodes{
      writeln("Minimal ingredient: ", n, ": ", idToString[n]);
    }
    */
  }

  proc main() {
    writeln("in main...");
    run();
  }
}
