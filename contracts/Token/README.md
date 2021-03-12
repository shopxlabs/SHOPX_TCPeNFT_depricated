#Deploy Instructions

ERC20.sol
Vesting.sol (1 for each bucket, 1 for each crowdsale user)
    constructor params: start (future time in secs), cliff (secs in length from start), duration (secs in length from start), revokeTo(multisig wallet), first month bonus percent (rest of the month payout / bonus payout)
ERC20.Mint() -> Vesting.Address

