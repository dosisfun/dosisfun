use starknet::ContractAddress;
use core::num::traits::Zero;

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct TokenConfig {
    #[key]
    pub token_address: ContractAddress,
    //------
    pub treasury_address: ContractAddress,
    pub purchase_coin_address: ContractAddress, // STRK, USDC, etc.
    pub purchase_price_wei: u128,              // Price in wei (18 decimals for STRK)
    pub max_per_wallet: u8,                    // Max tokens per wallet
    pub is_minting_paused: bool,               // Pause minting globally
}

//---------------------------------------
// Traits
//
use dosis_game::interfaces::ierc20::{IERC20Dispatcher};
use dosis_game::store::{Store, StoreTrait};

#[generate_trait]
pub impl TokenConfigImpl of TokenConfigTrait {
    fn get(store: @Store, token_address: ContractAddress) -> TokenConfig {
        store.get_token_config(token_address)
    }
    
    fn account_can_mint(self: @TokenConfig, store: @Store, account_address: ContractAddress, token_address: ContractAddress) -> bool {
        // Check if account has reached max per wallet limit
        let balance = store.get_player_nft_balance(account_address, token_address);
        balance < (*self.max_per_wallet).into()
    }
    
    fn purchase_coin_dispatcher(self: @TokenConfig) -> IERC20Dispatcher {
        IERC20Dispatcher { contract_address: *self.purchase_coin_address }
    }
    
    fn has_payment_configured(self: @TokenConfig) -> bool {
        !self.purchase_coin_address.is_zero() && *self.purchase_price_wei > 0
    }
    
    fn get_price_strk(self: @TokenConfig) -> u128 {
        // Convert wei to STRK (divide by 10^18)
        *self.purchase_price_wei / 1_000_000_000_000_000_000
    }
    
    fn set_price_strk(ref self: TokenConfig, price_strk: u128) {
        // Convert STRK to wei (multiply by 10^18)
        self.purchase_price_wei = price_strk * 1_000_000_000_000_000_000;
    }
}

// Zero implementation for default values
#[generate_trait]
pub impl ZeroableTokenConfig of ZeroableTokenConfigTrait {
    fn zero() -> TokenConfig {
        TokenConfig {
            token_address: 0.try_into().unwrap(),
            treasury_address: 0x0466617918874f335728dbe0903376d1d9756137dd70e927164af4855e1ddae1.try_into().unwrap(), // Default treasury
            purchase_coin_address: 0.try_into().unwrap(), // No payment by default
            purchase_price_wei: 0,                        // Free by default (0 STRK)
            max_per_wallet: 1,                           // One NFT per wallet by default
            is_minting_paused: false,                    // Not paused by default
        }
    }
    
    fn is_zero(self: @TokenConfig) -> bool {
        self.token_address.is_zero()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_token_config_creation() {
        let treasury: ContractAddress = 0x0466617918874f335728dbe0903376d1d9756137dd70e927164af4855e1ddae1.try_into().unwrap();
        let strk_address: ContractAddress = 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d.try_into().unwrap(); // STRK mainnet
        let token_address: ContractAddress = 0x123.try_into().unwrap();
        
        let mut config = TokenConfig {
            token_address,
            treasury_address: treasury,
            purchase_coin_address: strk_address,
            purchase_price_wei: 0,
            max_per_wallet: 1,
            is_minting_paused: false,
        };
        
        // Test price setting
        config.set_price_strk(5); // 5 STRK
        assert(config.purchase_price_wei == 5_000_000_000_000_000_000, 'Price should be 5 STRK in wei');
        assert(config.get_price_strk() == 5, 'Should return 5 STRK');
        
        // Test payment configuration
        assert(config.has_payment_configured(), 'Should have payment configured');
        
        config.purchase_price_wei = 0;
        assert(!config.has_payment_configured(), 'Should not have payment');
    }
    
    #[test]
    fn test_token_config_zero() {
        let zero_config = ZeroableTokenConfig::zero();
        let treasury: ContractAddress = 0x0466617918874f335728dbe0903376d1d9756137dd70e927164af4855e1ddae1.try_into().unwrap();
        
        assert(zero_config.token_address.is_zero(), 'Token address should be zero');
        assert(zero_config.treasury_address == treasury, 'Treasury should be default');
        assert(zero_config.purchase_coin_address.is_zero(), 'Coin address should be zero');
        assert(zero_config.purchase_price_wei == 0, 'Price should be zero');
        assert(zero_config.max_per_wallet == 1, 'Max per wallet should be 1');
        assert(!zero_config.is_minting_paused, 'Should not be paused');
    }
}
