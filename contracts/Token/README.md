# Deploy Instructions

## ERC20.sol
## Vesting.sol 
 ### How many: (1 for each bucket, 1 for each crowdsale user)
    Constructor params: 
     beneficiary (vestor's address)
     start (future time in secs), 
     cliffDuration (secs in length from start), 
     duration (secs in length from start), 
     revokeTo(multisig wallet), 
     first month bonus percent (rest of the month payout / first month payout)
## Mint()
	ERC20.Mint(vesting contract's address, token amount)

**Plan is to mint all tokens to each vesting contract before releasing token address.
