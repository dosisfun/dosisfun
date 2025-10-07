use starknet::ContractAddress;

pub fn NAMESPACE() -> @ByteArray{
    @"dosis_game1"
}

pub fn NFT_CONTRACTS() -> ContractAddress {
    0x036d3eb9f2339402bb61cfb60ed29a5f905bf40d9a7434996e55054c328f4471.try_into().unwrap()
}
