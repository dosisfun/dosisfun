use dosis_game::models::nft::{PlayerNFT, ZeroablePlayerNFTTrait};
use dosis_game::types::erc721::{Transfer, Approval, ApprovalForAll};
use starknet::{ContractAddress, contract_address_const};

#[test]
fn test_player_nft_creation() {
    let owner: ContractAddress = contract_address_const::<0x123>();
    
    let player_nft = PlayerNFT {
        token_id: 1,
        owner,
        character_name: 'Shadow Dealer',
        character_class: 'Dealer',
        level: 5,
        experience: 250,
        reputation: 150,
        total_drugs_created: 10,
        successful_crafts: 8,
        failed_crafts: 2,
        creation_timestamp: 1234567890,
        last_active_timestamp: 1234567890,
        is_minted: true,
        is_active: true,
    };

    assert_eq!(player_nft.token_id, 1, "Token ID should be 1");
    assert_eq!(player_nft.owner, owner, "Owner should match");
    assert_eq!(player_nft.character_name, 'Shadow Dealer', "Character name should match");
    assert_eq!(player_nft.character_class, 'Dealer', "Character class should match");
    assert_eq!(player_nft.level, 5, "Level should be 5");
    assert_eq!(player_nft.experience, 250, "Experience should be 250");
    assert_eq!(player_nft.reputation, 150, "Reputation should be 150");
    assert_eq!(player_nft.is_minted, true, "Should be minted");
    assert_eq!(player_nft.is_active, true, "Should be active");
}

#[test]
fn test_player_nft_zero_initialization() {
    let zero_player_nft: PlayerNFT = ZeroablePlayerNFTTrait::zero();
    
    assert_eq!(zero_player_nft.token_id, 0, "Zero PlayerNFT token ID should be 0");
    assert_eq!(zero_player_nft.level, 1, "Zero PlayerNFT level should be 1");
    assert_eq!(zero_player_nft.experience, 0, "Zero PlayerNFT experience should be 0");
    assert_eq!(zero_player_nft.reputation, 0, "Zero PlayerNFT reputation should be 0");
    assert_eq!(zero_player_nft.is_minted, false, "Should not be minted");
    assert_eq!(zero_player_nft.is_active, false, "Should not be active");
}

#[test]
fn test_erc721_events() {
    let from: ContractAddress = contract_address_const::<0x123>();
    let to: ContractAddress = contract_address_const::<0x456>();
    let token_id: u256 = 1;

    let transfer_event = Transfer {
        from,
        to,
        token_id,
    };

    assert_eq!(transfer_event.from, from, "From address should match");
    assert_eq!(transfer_event.to, to, "To address should match");
    assert_eq!(transfer_event.token_id, token_id, "Token ID should match");
}
