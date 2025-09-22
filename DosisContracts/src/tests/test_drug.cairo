use dosis_game::models::drug::{DrugAssert, DrugInventory, ZeroableDrugTrait};
use dosis_game::types::drug_type::{DrugType, DrugRarity, DrugState};

#[cfg(test)]
mod tests {
    use super::{DrugAssert, DrugInventory, ZeroableDrugTrait};
    use super::{DrugType, DrugRarity, DrugState};

    #[test]
    #[available_gas(20000000)]
    fn test_drug_creation() {
        let mut drug = ZeroableDrugTrait::zero();
        drug.id = 1;
        drug.name = 'Cocaine';
        drug.drug_type = DrugType::Stimulant;
        drug.rarity = DrugRarity::Rare;
        drug.state = DrugState::Refined;
        drug.purity = 85;
        drug.quantity = 1;
        drug.creation_timestamp = 1000;
        drug.recipe_id = 1;

        assert(drug.id == 1, 'Drug ID should be 1');
        assert(drug.name == 'Cocaine', 'Drug name should be Cocaine');
        assert(drug.drug_type == DrugType::Stimulant, 'Drug type should be Stimulant');
        assert(drug.rarity == DrugRarity::Rare, 'Drug rarity should be Rare');
        assert(drug.state == DrugState::Refined, 'Drug state should be Refined');
        assert(drug.purity == 85, 'Drug purity should be 85');
        assert(drug.quantity == 1, 'Drug quantity should be 1');
        assert(drug.recipe_id == 1, 'Recipe ID should be 1');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_zero_address() {
        let drug = ZeroableDrugTrait::zero();
        assert(drug.owner == starknet::contract_address_const::<0>(), 'Owner should be zero address');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_assert_exists() {
        let mut drug = ZeroableDrugTrait::zero();
        drug.id = 1;
        
        // This should not panic
        drug.assert_exists();
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_inventory_creation() {
        let mut drug_ids = ArrayTrait::new();
        drug_ids.append(1);
        drug_ids.append(2);
        drug_ids.append(3);
        
        let inventory = DrugInventory {
            player: starknet::contract_address_const::<0>(),
            drug_ids: drug_ids.span(),
            total_drugs: 3,
        };

        let drugs: Span<u32> = inventory.drug_ids;
        assert(drugs.len() == 3, 'Inventory should have 3 drugs');
        assert(inventory.total_drugs == 3, 'Total drugs should be 3');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_types() {
        let stimulant = DrugType::Stimulant;
        let depressant = DrugType::Depressant;
        let hallucinogen = DrugType::Hallucinogen;
        let opioid = DrugType::Opioid;
        let cannabis = DrugType::Cannabis;
        let synthetic = DrugType::Synthetic;

        assert(stimulant == DrugType::Stimulant, 'Stimulant should match');
        assert(depressant == DrugType::Depressant, 'Depressant should match');
        assert(hallucinogen == DrugType::Hallucinogen, 'Hallucinogen should match');
        assert(opioid == DrugType::Opioid, 'Opioid should match');
        assert(cannabis == DrugType::Cannabis, 'Cannabis should match');
        assert(synthetic == DrugType::Synthetic, 'Synthetic should match');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_rarities() {
        let common = DrugRarity::Common;
        let uncommon = DrugRarity::Uncommon;
        let rare = DrugRarity::Rare;
        let epic = DrugRarity::Epic;
        let legendary = DrugRarity::Legendary;

        assert(common == DrugRarity::Common, 'Common should match');
        assert(uncommon == DrugRarity::Uncommon, 'Uncommon should match');
        assert(rare == DrugRarity::Rare, 'Rare should match');
        assert(epic == DrugRarity::Epic, 'Epic should match');
        assert(legendary == DrugRarity::Legendary, 'Legendary should match');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_states() {
        let raw = DrugState::Raw;
        let processing = DrugState::Processing;
        let refined = DrugState::Refined;
        let pure = DrugState::Pure;
        let masterpiece = DrugState::Masterpiece;

        assert(raw == DrugState::Raw, 'Raw should match');
        assert(processing == DrugState::Processing, 'Processing should match');
        assert(refined == DrugState::Refined, 'Refined should match');
        assert(pure == DrugState::Pure, 'Pure should match');
        assert(masterpiece == DrugState::Masterpiece, 'Masterpiece should match');
    }
}
