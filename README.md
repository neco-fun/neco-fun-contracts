# neco-fun-contracts

All contracts will be deployed on the BSC network.

## NecoToken.sol
#### This is NECO token contract.
1. total supply/max supply will be 1,00,000 and cannot be minted more.
2. only user can burn their own NECO token.
3. there is a lock for transfer. Once unlocked it, cannot lock again.

## NFishToken.sol
#### This is NFISH token contract.
1. transferLocked. we hope to lock the transfer function temporarily for some emergency situations.
2. mintOperationForOwnerLocked. we hope the owner cannot mint NFISH token directly after minting the first supply, so the owner should use the time lock function to mint NFISH token then.
3. lockTransferOperationForOwnerLocked. we hope there is a time lock for locking transfer function.
2. role: Minter and Burner. Minter can mint more NFISH token, and Burner can use the burnFrom() function.

## NecoNFT.sol
### This is NFT contract for the Neco Fishing game.
role: creators. only creators can create a new NFT.
Due to some default NFT tools for neco fishing need to be locked, we hope these NFTs can not be transferred to others by the safeTransferFrom() and the afeBatchTransferFrom() functions.


## NecoSaleContract.sol
#### This is a public sale/ private sale contract for NECO Token.
First we should call depositNecoToken(amount) to init its statuses. The amount should be calculated then according to the amount of whitelist.
Then user can buy NECO token in BUSD; there is a limitation for every buyer.
Claim: claim duration 30 days.
Monthly claimable 20%

## FarmingPool.sol
#### This is the farming contact for NECO token.
Some parts for dev fund, will be locked in this contract, and distributed during 180 days.
halving duration is 4 weeks.




