# 0xY - ETH-Global NY 2023 Hackathon

0xY is an application that offers Put-Protected Term Loans. It solves two key problems with existing borrowing lending protocols: 

1) **Liquidation**. Existing protocols liquidate borrowers whenever their collateral depreciates. While this may work for a DeFi native user who is familiar with actively managing their position, this is not a good fit for a long-term HODLer who wants to minimize the amount of effort required to manage their position. 0xY addresses this by offering borrowers the ability to purchase insurance in the form of put-options that compensate for collateral depreciation. 

2) **Repayment Ambiguity**. Existing protocols offer borrower loans without a fixed maturity or repayment conditions. This has the effect of increasing risk over time for lenders. 0xY instead offers borrowers the option to pay coupons in exchange for a lower interest rate. This has the effect of decreasing the risk over the term of the loan. Furthermore, it creates cash-flow thru the lending pools which can be borrowed by other borrowers.

# Instructions 

Clone this repo by running the following command: 

Build the project by running: 

Test the project by running: 

# Deployed Addresses 

Goerli

| Contract      | Address |
| ----------- | ----------- |
| debtToken      | [0x180065E86D77e57C3E789b868f9850F6958f29CC](https://goerli.etherscan.io/address/0x180065E86D77e57C3E789b868f9850F6958f29CC)    |
| principalToken   | [0x4a6956DDc6609964312cB428a8830823AD4612D2](https://goerli.etherscan.io/address/0x4a6956DDc6609964312cB428a8830823AD4612D2)         |
| InterestRateStrategy   | [0x9BcB22bfEC666023037D9C80b8d89f91466e787b](https://goerli.etherscan.io/address/0x9BcB22bfEC666023037D9C80b8d89f91466e787b)         |
| loanFactory   | [0xBF85Db5E3C03f0b2f217Ad1EE2D483c6B2d66c4F](https://goerli.etherscan.io/address/0xBF85Db5E3C03f0b2f217Ad1EE2D483c6B2d66c4F)         |
| loanRouter   | [0xDCEC347D3B12e53EB38f3576BD721c1D4eB8B2D9](https://goerli.etherscan.io/address/0xDCEC347D3B12e53EB38f3576BD721c1D4eB8B2D9)         |
| lendingPool (WEENUS)   | [0xD96E6E786997b39F74690602e6e4B58EB869f2c8](https://goerli.etherscan.io/address/0xD96E6E786997b39F74690602e6e4B58EB869f2c8)         |
| lendingPool (XEENUS)   | [0x1AB89F6A6852761067Ea42e30c4e7044f7C1a4cb](https://goerli.etherscan.io/address/0x1AB89F6A6852761067Ea42e30c4e7044f7C1a4cb)         |


BASE-Goerli

| Contract      | Address |
| ----------- | ----------- |
| debtToken      | [0x86EfbDdB3288b6F424D04d9DA2CcE38E543C4516](https://goerli.basescan.org/address/0x86EfbDdB3288b6F424D04d9DA2CcE38E543C4516)    |
| principalToken   | [0xf90120611e2d34cdecfb526f57a18782bd0c2b6f](https://goerli.basescan.org/address/0xf90120611e2d34cdecfb526f57a18782bd0c2b6f)       |
| InterestRateStrategy   |[0xdfe5010d0AfBb0b988087C43792De3212A23318a](https://goerli.basescan.org/address/0xdfe5010d0AfBb0b988087C43792De3212A23318a)       |
| loanFactory   |[0xF250d169DAb339a7083d6A7D593881c25a48aAB2](https://goerli.basescan.org/address/0xF250d169DAb339a7083d6A7D593881c25a48aAB2)          |
| loanRouter   | [0x0CBD3f6FE7D6f97d6145b58197E3FB76BEb81aC6](https://goerli.basescan.org/address/0x0CBD3f6FE7D6f97d6145b58197E3FB76BEb81aC6)         |
| lendingPool (USDT)   |[0x2F4C8775E1f56cc7dE85B7059A07940092382A5c](https://goerli.basescan.org/address/0x2F4C8775E1f56cc7dE85B7059A07940092382A5c)       |


# Bounty Infomation 

We are targeting the following partners in addition to the main-stream judging: 

   
1) **Uniswap**. We built a concept for a Uniswap V4 pool that would implement custom hooks that would lend to our protocol whenever the price would move out of range for a user's LP. Furthermore, when borrowers miss coupon payments that they committed to, our loan contracts would "liquidate" a portion of their collateral in order to satisfy the coupon payment. The intention is for this liquidation event to be routed through our custom pool and hook.
    
2) **Base**. We deployed our contracts on Base-Goarli as we intend for our application to be useful for long-term HODLers who are not already deep into DeFi and looking for user-friendly UI's.

3) **WalletConnect**. Our Front-end implements Wallet-Connect's modal for users to connect their wallets to our dApp. 




