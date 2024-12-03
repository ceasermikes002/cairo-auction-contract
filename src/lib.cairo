/// Interface representing the auction contract.
/// This interface allows modification and retrieval of auction-related information.
#[starknet::interface]
pub trait IAuctionContract<TContractState> {
    /// Start a new auction.
    fn start_auction(ref self: TContractState, nft_id: felt252, duration: felt252);
    
    /// Place a bid in the auction.
    fn place_bid(ref self: TContractState, bid_amount: felt252, bidder: felt252);
    
    /// Close the auction.
    fn close_auction(ref self: TContractState);
    
    /// Retrieve the highest bid.
    fn get_highest_bid(self: @TContractState) -> felt252;
    
    /// Retrieve the highest bidder.
    fn get_highest_bidder(self: @TContractState) -> felt252;
    
    /// Retrieve the auction end time.
    fn get_auction_end_time(self: @TContractState) -> felt252;
    
    /// Check if the auction is active.
    fn is_auction_active(self: @TContractState) -> felt252;
}

/// Simple auction contract for managing bids.
#[starknet::contract]
mod AuctionContract {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        highest_bid: felt252,
        highest_bidder: felt252,
        auction_end_time: felt252,
        auction_active: felt252,
    }

    #[abi(embed_v0)]
    impl AuctionContractImpl of super::IAuctionContract<ContractState> {
        fn start_auction(ref self: ContractState, nft_id: felt252, duration: felt252) {
            let is_active = self.auction_active.read();
            assert(is_active == 0, 'Auction is already active');
            
            let current_time = get_block_timestamp();
            self.auction_end_time.write(current_time + duration);
            self.auction_active.write(1);
            
            self.highest_bid.write(0);
            self.highest_bidder.write(0);
        }

        fn place_bid(ref self: ContractState, bid_amount: felt252, bidder: felt252) {
            let is_active = self.auction_active.read();
            assert(is_active == 1, 'Auction is not active');
            
            let current_time = get_block_timestamp();
            let end_time = self.auction_end_time.read();
            assert(current_time < end_time, 'Auction has ended');
            
            let current_highest_bid = self.highest_bid.read();
            assert(bid_amount > current_highest_bid, 'Bid must be higher than the current highest bid');
            
            self.highest_bid.write(bid_amount);
            self.highest_bidder.write(bidder);
        }

        fn close_auction(ref self: ContractState) {
            let current_time = get_block_timestamp();
            let end_time = self.auction_end_time.read();
            assert(current_time >= end_time, 'Auction is still ongoing');
            
            self.auction_active.write(0);
        }

        fn get_highest_bid(self: @ContractState) -> felt252 {
            self.highest_bid.read()
        }

        fn get_highest_bidder(self: @ContractState) -> felt252 {
            self.highest_bidder.read()
        }

        fn get_auction_end_time(self: @ContractState) -> felt252 {
            self.auction_end_time.read()
        }

        fn is_auction_active(self: @ContractState) -> felt252 {
            self.auction_active.read()
        }
    }

    // Helper function to get the current block timestamp.
    #[view]
    fn get_block_timestamp() -> felt252 {
        return block.timestamp;
    }
}
