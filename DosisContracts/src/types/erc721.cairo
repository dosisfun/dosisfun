use starknet::ContractAddress;

/// ERC721 standard events
#[derive(Drop, starknet::Event)]
pub struct Transfer {
    #[key]
    pub from: ContractAddress,
    #[key]
    pub to: ContractAddress,
    #[key]
    pub token_id: u256,
}

#[derive(Drop, starknet::Event)]
pub struct Approval {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub approved: ContractAddress,
    #[key]
    pub token_id: u256,
}

#[derive(Drop, starknet::Event)]
pub struct ApprovalForAll {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub operator: ContractAddress,
    pub approved: bool,
}

/// ERC721 standard interface
#[starknet::interface]
pub trait IERC721<TContractState> {
    /// Returns the number of tokens in owner's account
    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
    
    /// Returns the owner of the tokenId token
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    
    /// Safely transfers tokenId token from from to to
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    
    /// Transfers tokenId token from from to to
    fn transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256
    );
    
    /// Gives permission to to to transfer tokenId token to another account
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    
    /// Returns the account approved for tokenId token
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    
    /// Sets or unsets the approval of a given operator
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    
    /// Tells if an operator is approved by a given owner
    fn is_approved_for_all(
        self: @TContractState,
        owner: ContractAddress,
        operator: ContractAddress
    ) -> bool;
    
    /// Returns the token collection name
    fn name(self: @TContractState) -> felt252;
    
    /// Returns the token collection symbol
    fn symbol(self: @TContractState) -> felt252;
    
    /// Returns the Uniform Resource Identifier (URI) for tokenId token
    fn token_uri(self: @TContractState, token_id: u256) -> felt252;
    
    /// Returns the total supply of tokens
    fn total_supply(self: @TContractState) -> u256;
    
    /// Returns a token ID owned by owner at a given index
    fn token_by_index(self: @TContractState, index: u256) -> u256;
    
    /// Returns a token ID at a given index of the tokens list of the requested owner
    fn token_of_owner_by_index(self: @TContractState, owner: ContractAddress, index: u256) -> u256;
}

/// ERC721Metadata interface
#[starknet::interface]
pub trait IERC721Metadata<TContractState> {
    /// Returns the token collection name
    fn name(self: @TContractState) -> felt252;
    
    /// Returns the token collection symbol
    fn symbol(self: @TContractState) -> felt252;
    
    /// Returns the Uniform Resource Identifier (URI) for tokenId token
    fn token_uri(self: @TContractState, token_id: u256) -> felt252;
}

/// ERC721Enumerable interface
#[starknet::interface]
pub trait IERC721Enumerable<TContractState> {
    /// Returns the total supply of tokens
    fn total_supply(self: @TContractState) -> u256;
    
    /// Returns a token ID owned by owner at a given index
    fn token_by_index(self: @TContractState, index: u256) -> u256;
    
    /// Returns a token ID at a given index of the tokens list of the requested owner
    fn token_of_owner_by_index(self: @TContractState, owner: ContractAddress, index: u256) -> u256;
}

#[cfg(test)]
mod tests {
    use super::{Transfer, Approval, ApprovalForAll};
    use starknet::{ContractAddress, contract_address_const};

    #[test]
    fn test_transfer_event() {
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

    #[test]
    fn test_approval_event() {
        let owner: ContractAddress = contract_address_const::<0x123>();
        let approved: ContractAddress = contract_address_const::<0x456>();
        let token_id: u256 = 1;

        let approval_event = Approval {
            owner,
            approved,
            token_id,
        };

        assert_eq!(approval_event.owner, owner, "Owner address should match");
        assert_eq!(approval_event.approved, approved, "Approved address should match");
        assert_eq!(approval_event.token_id, token_id, "Token ID should match");
    }

    #[test]
    fn test_approval_for_all_event() {
        let owner: ContractAddress = contract_address_const::<0x123>();
        let operator: ContractAddress = contract_address_const::<0x456>();
        let approved = true;

        let approval_for_all_event = ApprovalForAll {
            owner,
            operator,
            approved,
        };

        assert_eq!(approval_for_all_event.owner, owner, "Owner address should match");
        assert_eq!(approval_for_all_event.operator, operator, "Operator address should match");
        assert_eq!(approval_for_all_event.approved, approved, "Approved should match");
    }
}
