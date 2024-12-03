// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

// Storage variables
@storage_var
func highest_bid() -> (res: felt252) {
}

@storage_var
func highest_bidder() -> (res: felt252) {
}

@storage_var
func auction_end_time() -> (res: felt252) {
}

@storage_var
func auction_active() -> (res: felt252) {
}

// Function to start an auction
@external
func start_auction{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(nft_id: felt252, duration: felt252) {
    let (is_active) = auction_active.read();
    assert is_active == 0;

    let current_time = get_block_timestamp();
    auction_end_time.write!(current_time + duration);
    auction_active.write!(1);

    highest_bid.write!(0);
    highest_bidder.write!(0);

    return ();
}

// Function to place a bid
@external
func place_bid{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(bid_amount: felt252, bidder: felt252) {
    let (is_active) = auction_active.read();
    assert is_active == 1;

    let current_time = get_block_timestamp();
    let (end_time) = auction_end_time.read();
    assert current_time < end_time;

    let (current_highest_bid) = highest_bid.read();
    assert bid_amount > current_highest_bid;

    // Update the highest bid and bidder
    highest_bid.write!(bid_amount);
    highest_bidder.write!(bidder);

    return ();
}

// Function to close the auction
@external
func close_auction{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}() {
    let current_time = get_block_timestamp();
    let (end_time) = auction_end_time.read();
    assert current_time >= end_time;

    auction_active.write!(0);

    return ();
}

// Helper function to get the current block timestamp
@view
func get_block_timestamp() -> (res: felt252) {
    return (block.timestamp);
}

// Function to get the highest bid
@view
func get_highest_bid() -> (res: felt252) {
    let (res) = highest_bid.read();
    return (res);
}

// Function to get the highest bidder
@view
func get_highest_bidder() -> (res: felt252) {
    let (res) = highest_bidder.read();
    return (res);
}

// Function to get the auction end time
@view
func get_auction_end_time() -> (res: felt252) {
    let (res) = auction_end_time.read();
    return (res);
}

// Function to check if the auction is active
@view
func is_auction_active() -> (res: felt252) {
    let (res) = auction_active.read();
    return (res);
}
