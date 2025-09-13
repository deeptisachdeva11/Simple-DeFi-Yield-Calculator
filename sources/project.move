module MyModule::YieldCalculator {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    /// Struct representing a user's staking position
    struct StakePosition has store, key {
        staked_amount: u64,     // Amount of tokens staked
        stake_timestamp: u64,   // When the stake was created
        annual_yield_rate: u64, // Annual yield rate in basis points (e.g., 500 = 5%)
    }

    /// Function to create a staking position with specified amount and yield rate
    public fun create_stake_position(
        user: &signer, 
        stake_amount: u64, 
        annual_yield_rate: u64
    ) {
        // Withdraw tokens from user's account for staking
        let staked_coins = coin::withdraw<AptosCoin>(user, stake_amount);
        
        // For simplicity, we'll assume tokens are held in contract
        // In a real implementation, these would be deposited to a pool
        coin::deposit<AptosCoin>(signer::address_of(user), staked_coins);
        
        let stake_position = StakePosition {
            staked_amount: stake_amount,
            stake_timestamp: timestamp::now_seconds(),
            annual_yield_rate,
        };
        move_to(user, stake_position);
    }

    /// Function to calculate current yield earned on the staked position
    public fun calculate_current_yield(user_address: address): u64 acquires StakePosition {
        let stake_position = borrow_global<StakePosition>(user_address);
        let current_time = timestamp::now_seconds();
        let time_staked = current_time - stake_position.stake_timestamp;
        
        // Calculate yield: (staked_amount * annual_rate * time_in_seconds) / (365 * 24 * 3600 * 10000)
        // annual_rate is in basis points, so divide by 10000
        let seconds_per_year = 365 * 24 * 3600;
        let yield_earned = (stake_position.staked_amount * stake_position.annual_yield_rate * time_staked) 
                          / (seconds_per_year * 10000);
        
        yield_earned
    }
}