module Yummly {
  use IO,
      LayoutCS,
      Time;
  //use NumSuch only;
  use NumSuch;

  config const data: string;

  var ingredients: domain(string),
      ingredientIds: [ingredients] int;
      //D: domain (2),
      //SD: sparse subdomain(D) dmapped CS(),
      //SD: sparse subdomain(D),
      //A: [SD] real;

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
      var t:Timer;
      var edges: list((int, int));
      t.start();
      writeln("loading graph");
      for recipe in cookBook.recipes {
        for ingredient_1 in recipe.ingredients {
          if !ingredients.member(ingredient_1) {
            ingredients.add(ingredient_1);
            ingredientIds[ingredient_1] = ingredients.size;
          }
          for ingredient_2 in recipe.ingredients {
            if !ingredients.member(ingredient_2) {
              ingredients.add(ingredient_2);
              ingredientIds[ingredient_2] = ingredients.size;
            }
            if ingredientIds[ingredient_1] != ingredientIds[ingredient_2] {
              edges.append((ingredientIds[ingredient_1],ingredientIds[ingredient_2]));
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
      var g = GraphUtils.buildFromSparseMatrix(A, weighted=false, directed=false);
      return g;
  }

  proc main() {
    var cookBook = loadTrainingData();
    var g = loadGraph(cookBook);
  }
}
