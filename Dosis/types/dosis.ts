export interface DosisNFT {
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

export interface DosisNFTResponse {
  ownedNfts: DosisNFT[];
  totalCount: number;
}

export interface DosisNFTItem {
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

export interface DosisNFTItemsResponse {
  items: DosisNFTItem[];
  pagination: {
    prev: string | null;
    next: string | null;
  };
}
