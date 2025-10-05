use dosis_game::models::recipe::{Recipe, RecipeAssert};
use dosis_game::store::StoreTrait;
use dosis_game::types::drug_type::{DrugRarity, DrugRarityHelper, DrugType, DrugTypeHelper};
use dosis_game::types::recipe::Ingredient;

#[starknet::interface]
pub trait IRecipeSystem<T> {
    fn create_recipe(
        ref self: T,
        name: felt252,
        drug_type: DrugType,
        rarity: DrugRarity,
        ingredients: Array<Ingredient>,
        difficulty: u8,
        base_experience: u16,
        success_rate: u8,
    ) -> u32;
    fn get_recipe(ref self: T, recipe_id: u32) -> Recipe;
    fn get_all_recipes(ref self: T) -> Array<u32>;
    fn activate_recipe(ref self: T, recipe_id: u32);
    fn deactivate_recipe(ref self: T, recipe_id: u32);
}

#[dojo::contract]
pub mod recipe_system {
    use starknet::get_caller_address;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use super::{
        DrugRarity, DrugRarityHelper, DrugType, DrugTypeHelper, IRecipeSystem, Ingredient, Recipe,
        RecipeAssert, StoreTrait,
    };

    #[storage]
    struct Storage {
        recipe_counter: u256,
    }

    // Constructor
    fn dojo_init(ref self: ContractState) {
        self.recipe_counter.write(1);

        // Initialize some default recipes
        initialize_default_recipes(ref self);
    }

    #[abi(embed_v0)]
    impl RecipeSystemImpl of IRecipeSystem<ContractState> {
        fn create_recipe(
            ref self: ContractState,
            name: felt252,
            drug_type: DrugType,
            rarity: DrugRarity,
            ingredients: Array<Ingredient>,
            difficulty: u8,
            base_experience: u16,
            success_rate: u8,
        ) -> u32 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let recipe_id = self.recipe_counter.read();
            self.recipe_counter.write(recipe_id + 1);

            // Validate difficulty range
            assert(
                difficulty >= dosis_game::constants::MIN_RECIPE_DIFFICULTY
                    && difficulty <= dosis_game::constants::MAX_RECIPE_DIFFICULTY,
                'Invalid difficulty range',
            );

            let recipe = Recipe {
                id: recipe_id.try_into().unwrap(),
                name,
                drug_type: DrugTypeHelper::to_felt252(drug_type),
                rarity: DrugRarityHelper::to_felt252(rarity),
                ingredient_count: ingredients.len().try_into().unwrap(),
                primary_ingredient: if ingredients.len() > 0 {
                    *ingredients.at(0).name
                } else {
                    ''
                },
                difficulty,
                base_experience,
                success_rate,
                is_active: true,
                created_by: get_caller_address().into(),
            };

            store.write_recipe(recipe);
            recipe_id.try_into().unwrap()
        }

        fn get_recipe(ref self: ContractState, recipe_id: u32) -> Recipe {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let recipe = store.read_recipe(recipe_id);
            recipe.assert_exists();
            recipe
        }

        fn get_all_recipes(ref self: ContractState) -> Array<u32> {
            let mut recipe_ids = ArrayTrait::new();
            let counter = self.recipe_counter.read();

            // Get all recipe IDs from 1 to counter
            let max_recipes: u32 = counter.try_into().unwrap_or(1000); // Cap at 1000 for safety
            let mut i: u32 = 1;
            loop {
                if i > max_recipes {
                    break;
                }
                recipe_ids.append(i);
                i += 1;
            }

            recipe_ids
        }

        fn activate_recipe(ref self: ContractState, recipe_id: u32) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let mut recipe = store.read_recipe(recipe_id);
            recipe.assert_exists();

            recipe.is_active = true;
            store.write_recipe(recipe);
        }

        fn deactivate_recipe(ref self: ContractState, recipe_id: u32) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let mut recipe = store.read_recipe(recipe_id);
            recipe.assert_exists();

            recipe.is_active = false;
            store.write_recipe(recipe);
        }
    }

    // Helper function to initialize default recipes
    fn initialize_default_recipes(ref self: ContractState) {
        let mut world = self.world(@"dosis_game");
        let mut store = StoreTrait::new(world);

        // Recipe 1: Basic Cocaine
        let mut cocaine_ingredients = ArrayTrait::new();
        cocaine_ingredients.append(Ingredient { name: 'coca_leaf', quantity: 5, purity: 90 });
        cocaine_ingredients.append(Ingredient { name: 'lime', quantity: 2, purity: 85 });

        let cocaine_recipe = Recipe {
            id: 1,
            name: 'cocaine_basic',
            drug_type: DrugTypeHelper::to_felt252(DrugType::Stimulant),
            rarity: DrugRarityHelper::to_felt252(DrugRarity::Common),
            ingredient_count: 2,
            primary_ingredient: 'coca_leaf',
            difficulty: 3,
            base_experience: 50,
            success_rate: 70,
            is_active: true,
            created_by: 'system',
        };

        // Recipe 2: Heroin
        let mut heroin_ingredients = ArrayTrait::new();
        heroin_ingredients.append(Ingredient { name: 'poppy_sap', quantity: 8, purity: 95 });
        heroin_ingredients.append(Ingredient { name: 'acetic_anhydride', quantity: 3, purity: 80 });

        let heroin_recipe = Recipe {
            id: 2,
            name: 'heroin_pure',
            drug_type: DrugTypeHelper::to_felt252(DrugType::Opioid),
            rarity: DrugRarityHelper::to_felt252(DrugRarity::Rare),
            ingredient_count: 4,
            primary_ingredient: 'poppy_sap',
            difficulty: 7,
            base_experience: 150,
            success_rate: 45,
            is_active: true,
            created_by: 'system',
        };

        // Recipe 3: LSD
        let mut lsd_ingredients = ArrayTrait::new();
        lsd_ingredients.append(Ingredient { name: 'ergot_fungus', quantity: 1, purity: 99 });
        lsd_ingredients.append(Ingredient { name: 'diethylamine', quantity: 2, purity: 95 });

        let lsd_recipe = Recipe {
            id: 3,
            name: 'lsd_tabs',
            drug_type: DrugTypeHelper::to_felt252(DrugType::Hallucinogen),
            rarity: DrugRarityHelper::to_felt252(DrugRarity::Epic),
            ingredient_count: 5,
            primary_ingredient: 'ergot_fungus',
            difficulty: 9,
            base_experience: 300,
            success_rate: 25,
            is_active: true,
            created_by: 'system',
        };

        store.write_recipe(cocaine_recipe);
        store.write_recipe(heroin_recipe);
        store.write_recipe(lsd_recipe);
    }
}
