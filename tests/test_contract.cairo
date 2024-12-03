#[cfg(test)]
mod tests {
    use super::*;
    use core::starknet::testing::{Contract, ContractState};

    // Helper function to create a fresh contract instance
    fn setup() -> ContractState {
        ContractState::new()
    }

    #[test]
    fn test_start_auction() {
        let mut contract = setup();

        // Start the auction with a duration of 100 blocks
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Assert auction is active
        assert_eq!(contract.is_auction_active(), 1);

        // Assert auction end time is set correctly (current time + duration)
        let current_time = get_block_timestamp();
        let expected_end_time = current_time + duration;
        assert_eq!(contract.get_auction_end_time(), expected_end_time);

        // Assert highest bid and bidder are initialized to 0
        assert_eq!(contract.get_highest_bid(), 0);
        assert_eq!(contract.get_highest_bidder(), 0);
    }

    #[test]
    fn test_place_bid() {
        let mut contract = setup();

        // Start auction
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Place a valid bid
        let bid_amount = 50;
        let bidder = 1;
        contract.place_bid(bid_amount, bidder);

        // Assert highest bid and bidder are updated correctly
        assert_eq!(contract.get_highest_bid(), bid_amount);
        assert_eq!(contract.get_highest_bidder(), bidder);
    }

    #[test]
    fn test_place_invalid_bid() {
        let mut contract = setup();

        // Start auction
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Try placing a bid lower than the current highest bid
        let bid_amount = 50;
        let bidder = 1;
        contract.place_bid(bid_amount, bidder);

        // Try placing a bid that's too low
        let invalid_bid_amount = 40;
        let invalid_bidder = 2;

        let result = std::panic::catch_unwind(|| {
            contract.place_bid(invalid_bid_amount, invalid_bidder);
        });

        // Assert that the bid was rejected (panic occurs)
        assert!(result.is_err());
    }

    #[test]
    fn test_close_auction() {
        let mut contract = setup();

        // Start auction
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Try to close the auction before it ends
        let result = std::panic::catch_unwind(|| {
            contract.close_auction();
        });

        // Assert that the auction is still ongoing and cannot be closed (panic occurs)
        assert!(result.is_err());

        // Simulate time passing (assuming `get_block_timestamp` returns increasing values)
        let current_time = get_block_timestamp();
        let auction_end_time = contract.get_auction_end_time();

        // Wait until auction ends
        while current_time < auction_end_time {
            contract = setup(); // simulate passage of time
        }

        // Now that the auction has ended, try to close it
        contract.close_auction();
        
        // Assert that the auction is now closed
        assert_eq!(contract.is_auction_active(), 0);
    }

    #[test]
    fn test_get_highest_bid() {
        let mut contract = setup();

        // Start auction
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Place bids
        let bid_amount1 = 50;
        let bidder1 = 1;
        contract.place_bid(bid_amount1, bidder1);

        let bid_amount2 = 75;
        let bidder2 = 2;
        contract.place_bid(bid_amount2, bidder2);

        // Assert the highest bid is the last one placed
        assert_eq!(contract.get_highest_bid(), bid_amount2);
        assert_eq!(contract.get_highest_bidder(), bidder2);
    }

    #[test]
    fn test_get_auction_end_time() {
        let mut contract = setup();

        // Start auction
        let nft_id = 123;
        let duration = 100;
        contract.start_auction(nft_id, duration);

        // Assert auction end time is correctly set
        let current_time = get_block_timestamp();
        let expected_end_time = current_time + duration;
        assert_eq!(contract.get_auction_end_time(), expected_end_time);
    }
}
