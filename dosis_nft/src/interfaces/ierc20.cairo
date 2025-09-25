// SPDX-License-Identifier: MIT
// ERC20 interface for handling STRK payments in the NFT contract

#[starknet::interface]
pub trait IERC20<TState> {
    // View functions
    fn balance_of(self: @TState, account: starknet::ContractAddress) -> u256;
    fn allowance(self: @TState, owner: starknet::ContractAddress, spender: starknet::ContractAddress) -> u256;
    
    // External functions
    fn transfer_from(ref self: TState, sender: starknet::ContractAddress, recipient: starknet::ContractAddress, amount: u256) -> bool;
}
