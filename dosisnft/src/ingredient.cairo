pub const GORILLA_GLUE: u32 = 1;
pub const LEBRON_HAZE: u32 = 2;
pub const RUCU_CUCU_OG: u32 = 3;

pub fn get_ingredient_price(ingredient_id: u32) -> u256 {
    if ingredient_id == GORILLA_GLUE {
        100
    } else if ingredient_id == LEBRON_HAZE {
        150
    } else if ingredient_id == RUCU_CUCU_OG {
        200
    } else {
        0
    }
}

pub fn get_all_ingredients() -> Array<u32> {
    array![GORILLA_GLUE, LEBRON_HAZE, RUCU_CUCU_OG]
}
