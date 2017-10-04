module Yummly {
  use IO,
      //LayoutCS,
      Time;

  config const data: string;

  var ingredients: domain(string),
      ingredientIds: [ingredients] int,
      ings = 1..0,
      D = {ings,ings},
      //SD: sparse subdomain(D) dmapped CS(),
      SD: sparse subdomain(D),
      A: [SD] real;

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
      t.start();
      writeln("loading graph");
      for recipe in cookBook.recipes {
        writeln("\t", recipe.cuisine);
        for ingredient in recipe.ingredients {
          if !ingredients.member(ingredient) {
            ings = 1..ings.last + 1;
            //writeln("D is now ", D);
            ingredients.add(ingredient);
            ingredientIds[ingredient] = ingredients.size;
          }
        }
        for ingredient_1 in recipe.ingredients {
          for ingredient_2 in recipe.ingredients {
            //writeln(D);
            SD += (ingredientIds(ingredient_1), ingredientIds(ingredient_2));
          }
        }
      }
      writeln(SD);
      t.stop();
      writeln("...time to load graph: ", t.elapsed());
  }

  proc main() {
    var cookBook = loadTrainingData();
    loadGraph(cookBook);
  }
}
