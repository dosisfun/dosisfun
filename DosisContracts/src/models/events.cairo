use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: false)]
pub struct TokenMintedEvent {
    #[key]
    pub token_contract_address: ContractAddress,
    #[key]
    pub token_id: u256,
    //-----------------------
    pub recipient: ContractAddress,
    pub character_name: felt252,
    pub seed: felt252,
    pub payment_coin_address: ContractAddress,
    pub payment_amount_wei: u128,
    pub treasury_address: ContractAddress,
    pub timestamp: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: false)]
pub struct TokenBurnedEvent {
    #[key]
    pub token_contract_address: ContractAddress,
    #[key]
    pub token_id: u256,
    //-----------------------
    pub owner: ContractAddress,
    pub character_name: felt252,
    pub level: u8,
    pub experience: u16,
    pub reputation: u16,
    pub timestamp: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: false)]
pub struct PaymentReceivedEvent {
    #[key]
    pub treasury_address: ContractAddress,
    #[key]
    pub payer: ContractAddress,
    //-----------------------
    pub token_contract_address: ContractAddress,
    pub token_id: u256,
    pub coin_address: ContractAddress,
    pub amount_wei: u128,
    pub timestamp: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: false)]
pub struct PriceUpdatedEvent {
    #[key]
    pub token_contract_address: ContractAddress,
    //-----------------------
    pub old_coin_address: ContractAddress,
    pub new_coin_address: ContractAddress,
    pub old_price_wei: u128,
    pub new_price_wei: u128,
    pub updated_by: ContractAddress,
    pub timestamp: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical: false)]
pub struct MintingPausedEvent {
    #[key]
    pub token_contract_address: ContractAddress,
    //-----------------------
    pub is_paused: bool,
    pub updated_by: ContractAddress,
    pub timestamp: u64,
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_token_minted_event_creation() {
        let token_address: ContractAddress = 0x123.try_into().unwrap();
        let recipient: ContractAddress = 0x456.try_into().unwrap();
        let treasury: ContractAddress = 0x0466617918874f335728dbe0903376d1d9756137dd70e927164af4855e1ddae1.try_into().unwrap();
        let strk_address: ContractAddress = 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d.try_into().unwrap();
        
        let event = TokenMintedEvent {
            token_contract_address: token_address,
            token_id: 1,
            recipient,
            character_name: 'TestCharacter',
            seed: 0x12345,
            payment_coin_address: strk_address,
            payment_amount_wei: 5_000_000_000_000_000_000, // 5 STRK worth
            treasury_address: treasury,
            timestamp: 1000,
        };
        
        assert(event.token_contract_address == token_address, 'Token address should match');
        assert(event.token_id == 1, 'Token ID should be 1');
        assert(event.recipient == recipient, 'Recipient should match');
        assert(event.character_name == 'TestCharacter', 'Character name should match');
        assert(event.payment_amount_wei == 5_000_000_000_000_000_000, 'Payment amount should match');
    }
    
    #[test]
    fn test_token_burned_event_creation() {
        let token_address: ContractAddress = 0x123.try_into().unwrap();
        let owner: ContractAddress = 0x456.try_into().unwrap();
        
        let event = TokenBurnedEvent {
            token_contract_address: token_address,
            token_id: 1,
            owner,
            character_name: 'TestCharacter',
            level: 5,
            experience: 1000,
            reputation: 500,
            timestamp: 2000,
        };
        
        assert(event.token_contract_address == token_address, 'Token address should match');
        assert(event.token_id == 1, 'Token ID should be 1');
        assert(event.owner == owner, 'Owner should match');
        assert(event.level == 5, 'Level should be 5');
        assert(event.experience == 1000, 'Experience should be 1000');
        assert(event.reputation == 500, 'Reputation should be 500');
    }
    
    #[test]
    fn test_payment_received_event_creation() {
        let treasury: ContractAddress = 0x0466617918874f335728dbe0903376d1d9756137dd70e927164af4855e1ddae1.try_into().unwrap();
        let payer: ContractAddress = 0x456.try_into().unwrap();
        let token_address: ContractAddress = 0x123.try_into().unwrap();
        let strk_address: ContractAddress = 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d.try_into().unwrap();
        
        let event = PaymentReceivedEvent {
            treasury_address: treasury,
            payer,
            token_contract_address: token_address,
            token_id: 1,
            coin_address: strk_address,
            amount_wei: 5_000_000_000_000_000_000,
            timestamp: 1000,
        };
        
        assert(event.treasury_address == treasury, 'Treasury should match');
        assert(event.payer == payer, 'Payer should match');
        assert(event.coin_address == strk_address, 'Coin address should match');
        assert(event.amount_wei == 5_000_000_000_000_000_000, 'Amount should match');
    }
}
