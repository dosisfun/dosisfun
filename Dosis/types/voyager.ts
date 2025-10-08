export interface VoyagerNFT {
  contract_address: string;
  token_id: string;
  name?: string;
  description?: string;
  image?: string;
  owner?: string;
  metadata?: {
    image_small?: string;
    image_large?: string;
    collection_name?: string;
    last_transfer_time?: number;
  };
}

export interface VoyagerNFTResponse {
  ownedNfts: VoyagerNFT[];
  totalCount: number;
}

export interface MintedNFTItem {
  contract_address: string;
  token_id: string;
  name: string | null;
  description: string;
  image_url: string | null;
  image_small_url: string | null;
  image_large_url: string | null;
  minted_at_timestamp: number;
  minted_by_address: string;
  minted_at_block_number: number;
  minted_at_transaction_hash: string;
}

export interface VoyagerNFTItemsResponse {
  items: MintedNFTItem[];
  pagination: {
    prev: string | null;
    next: string | null;
  };
}
