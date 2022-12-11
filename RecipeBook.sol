pragma solidity ^0.8.0;

// Recipe storage struct
struct Recipe {
    string name;
    string[] ingredients;
}

// Recipe storage contract
contract RecipeBook {
    // Array of all stored recipes
    Recipe[] public recipes;

    // Function to add a new recipe
    function addRecipe(string memory _name, string[] memory _ingredients) public {
        // Create a new recipe
        Recipe memory newRecipe = Recipe(_name, _ingredients);

        // Add the recipe to the array of recipes
        recipes.push(newRecipe);
    }

    // Function to search for recipes based on a list of ingredients
    function searchRecipes(string[] memory _ingredients) public view returns (Recipe[] memory) {
        // Create an array to store matching recipes
        Recipe[] memory matchingRecipes = new Recipe[](0);

        // Loop through all recipes
        for (uint i = 0; i < recipes.length; i++) {
            // Loop through all ingredients in the search list
            for (uint j = 0; j < _ingredients.length; j++) {
                // Check if the current ingredient is in the recipe
                if (recipes[i].ingredients.indexOf(_ingredients[j]) != -1) {
                    // If the ingredient is found, add the recipe to the matching recipes array
                    matchingRecipes.push(recipes[i]);
                    break;
                }
            }
        }

        // Return the array of matching recipes
        return matchingRecipes;
    }
}
