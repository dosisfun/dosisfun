use graffiti::json::JsonImpl;
use crate::models::CharacterStats;

pub fn create_metadata(
    character_stats: CharacterStats, token_id: u256, base_uri: ByteArray,
) -> ByteArray {
    let _token_id = format!("{}", token_id);
    let _level = format!("{}", character_stats.level);
    let _experience = format!("{}", character_stats.experience);
    let _reputation = format!("{}", character_stats.reputation);
    let _total_drugs_created = format!("{}", character_stats.total_drugs_created);
    let _successful_crafts = format!("{}", character_stats.successful_crafts);
    let _failed_crafts = format!("{}", character_stats.failed_crafts);
    let _creation_timestamp = format!("{}", character_stats.creation_timestamp);
    let _last_active_timestamp = format!("{}", character_stats.last_active_timestamp);
    let _is_minted = format!("{}", character_stats.is_minted);
    let _is_active = format!("{}", character_stats.is_active);

    let mut metadata = JsonImpl::new()
        .add("name", character_stats.character_name.clone())
        .add("description", "Dosis NFT Character")
        .add("image", base_uri + _token_id + ".jpg");

    let level: ByteArray = JsonImpl::new().add("trait_type", "Level").add("value", _level).build();
    let experience: ByteArray = JsonImpl::new().add("trait_type", "Experience").add("value", _experience).build();
    let reputation: ByteArray = JsonImpl::new().add("trait_type", "Reputation").add("value", _reputation).build();
    let total_drugs_created: ByteArray = JsonImpl::new().add("trait_type", "Total Drugs Created").add("value", _total_drugs_created).build();
    let successful_crafts: ByteArray = JsonImpl::new().add("trait_type", "Successful Crafts").add("value", _successful_crafts).build();
    let failed_crafts: ByteArray = JsonImpl::new().add("trait_type", "Failed Crafts").add("value", _failed_crafts).build();
    let creation_timestamp: ByteArray = JsonImpl::new().add("trait_type", "Creation Timestamp").add("value", _creation_timestamp).build();
    let last_active_timestamp: ByteArray = JsonImpl::new().add("trait_type", "Last Active Timestamp").add("value", _last_active_timestamp).build();
    let is_minted: ByteArray = JsonImpl::new().add("trait_type", "Is Minted").add("value", _is_minted).build();
    let is_active: ByteArray = JsonImpl::new().add("trait_type", "Is Active").add("value", _is_active).build();

    let attributes = array![
        level, 
        experience, 
        reputation, 
        total_drugs_created, 
        successful_crafts, 
        failed_crafts, 
        creation_timestamp, 
        last_active_timestamp, 
        is_minted, 
        is_active
    ].span();

    let metadata = metadata.add_array("attributes", attributes).build();

    format!("data:application/json;utf8,{}", metadata)
}



