Hecho:
* mint
* comprar ingredientes
* craftear la droga
* marketplace 

Falta:
* leaderboard
* jefe

# NFT CONTRACTS 0x02232fb520090d5c76d8d84de9829eea7c34c5e6234a5a2a8b178d18e2aedbd7
Contrato Cairo

* Pausable
* Roles (ADMIN / DOSIS_CONTRACT / MINT)
* Upgradeable

Lista de personajes
Precio del mint configurable
Treasury address configurable
Lista de ingredientes
Lista de drogas

funciones principales

fn mint - rol: MINT
fn public_mint - se paga el minteo con STRK

fn mint_ingredient - rol: DOSIS_CONTRACT
fn consume_ingredient - rol: DOSIS_CONTRACT

fn mint_drug - rol: DOSIS_CONTRACT
fn consume_drug - rol: DOSIS_CONTRACT

fn lock_drug - rol: DOSIS_CONTRACT
fn unlock_drug - rol: DOSIS_CONTRACT

fn transfer_drug_ownership - rol: DOSIS_CONTRACT

fn update_character_stats - rol: DOSIS_CONTRACT

# DOSIS CONTRACTS
Contrato Dojo

2 contratos drug_crafting_system y black_market_system

# drug_crafting_system 0x03d469f506db8c193f26795b2688a453f683a39caefd2d868146391493126d7e

fn craft_drug(
    ref self: T,
    nft_token_id: u256,
    name: ByteArray,
    base_ingredients: Array<(u32, u32)>, // (id, quantity)
    drug_ingredient_ids: Array<u32>,
);

## black_market_system 0x04c61c998b9b524cc646d1cf508476e287d4f2f60395932f3368cf6278d3c75a

fn list_drug(ref self: T, nft_token_id: u256, drug_id: u32) -> u32;
fn cancel_listing(ref self: T, nft_token_id: u256, listing_id: u32);
fn buy_drug(ref self: T, buyer_nft_token_id: u256, listing_id: u32);
fn buy_ingredient(ref self: T, nft_token_id: u256, ingredient_id: u32, quantity: u32);
fn get_listing(self: @T, listing_id: u32) -> MarketListing;
fn get_active_listings(self: @T) -> Array<MarketListing>;
fn get_seller_listings(self: @T, nft_token_id: u256) -> Array<MarketListing>;


# Flujo

1. Necesito comprar un personaje `NFT - fn public_mint`
2. Necesito comprar ingredientes `black_market - buy_ingredient`. Ej: buy_ingredient(1, 100)
3. Con este ingrediente puedo crear una droga `drug_crafting - craft_drug`. Ej: craft_drug(1, fasito, [[1,50]], [])
4. Tengo una droga creada ahora la quiero listar para venderla `black_market - list_drug`. Ej: list_drug(1, 1)
5. Otro personaje me quiere comprar la droga `black_market - buy_drug`. Ej: buy_drug(2, 1)

# Aclaraciones

Como veo los stats de un personaje? `NFT - get_character_stats`
Que ingredientes tiene un personaje? `NFT - get_character_ingredients`
Que drogas tiene un personaje? `NFT - get_character_drugs`
Como veo los stats de una droga? `NFT - get_drug`
Como veo drogas listadas? `black_market - get_active_listings`
Como veo el detalle de una droga listada? `black_market - get_listing`
