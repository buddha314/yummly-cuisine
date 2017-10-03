/*
 BHarsh's gist: https://gist.github.com/benharsh/e9b3ec6334fdd8ad06072266d50fb135 for JSON loading
 ./graphLoader --train_data_f=two_recipes.json
 */

use IO;

const test_data_f: string = "/home/buddha314/datasets/yummly/test.json";
config const train_data_f:string = "/home/buddha314/datasets/yummly/train.json";

      //train_data_f:string  = "/home/buddha314/datasets/yummly/train.json";
      //train_data_f:string  = "two_recipes.json";
      //train_data_f:string  = "single_recipe_multiline.json";
      //train_data_f:string  = "single_recipe.json";
      //train_data_f:string  = "single_recipe_array.json";

writeln("let's load some json, shall we?");

record Recipe {
  var cuisine: string,
      id: int,
      ingredients: list(string);
}

record CookBook {
  var recipes: list(Recipe);
}

var f = open(train_data_f, iomode.r);
var r = f.reader();
//var final : Recipe;
var final : CookBook;
r.readf("%jt\n", final);
//writeln(final);
