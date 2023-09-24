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
| debtToken      | Text       |
| principalToken   | Text        |
| InterestRateStrategy   | Text        |
| loanFactory   | Text        |
| loanRouter   | Text        |
| lendingPool (WEENUS)   | Text        |



# Bounty Infomation 

We are targeting the following partners in addition to the main-stream judging: 

   
1) **Uniswap**. We built a concept for a Uniswap V4 pool that would implement custom hooks that would lend to our protocol whenever the price would move out of range for a user's LP. Furthermore, when borrowers miss coupon payments that they committed to, our loan contracts would "liquidate" a portion of their collateral in order to satisfy the coupon payment. The intention is for this liquidation event to be routed through our custom pool and hook.
    
2) **Base**. We deployed our contracts on Base-Goarli as we intend for our application to be useful for long-term HODLers who are not already deep into DeFi and looking for user-friendly UI's.

3) **WalletConnect**. Our Front-end implements Wallet-Connect's modal for users to connect their wallets to our dApp. 




