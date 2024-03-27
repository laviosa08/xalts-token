Answers to follow up questions:

1. What happens when you increase the number of wallets on the network to 1000?

    When the wallets on network increases, the contract's storage cost of storing wallet addresses and wallet transaction interactions with their peers also increases.
   In our contract we are maintaining wallet peer mapping as "interactions" for a address with array of addresses. In order to fetch all the peers for blacklist or whitelist operaction,
   the gas cost of this iteraction over this mapping also increases. Hence causing scalability issue.

2. Does a smart contract only approach still work? If not, what alternative solution do you propose?

   No, the smart contract only approcah will not work. Alternatively, we can maintain a off-chain database.
   1. This database would maintain records of all the wallet addresses in our system along with a status if the address is whitelisted or not.
   2. This database would also maintain records of wallet peers by storing transactions of a wallet with another wallet address and the amount of transaction. This would help in blacklisting/whitelisting the peers everytime a address is blacklisted/whitelisted. 

3. Highlight the changes required to implement the additional functionality on application side and relevant smart contract changes if any.

   Off-chain Management:
     1. Develop a backend server to manage the whitelist/blacklist status of addresses.
     2. Maintain a database to store all the wallet addresses in our system along with a status isWhitelisted (boolean).
     3. This database would also maintain records of transactions of a wallet with another wallet address and the amount of transaction. Example: Id, From Addresss, To Address, Amount
     4. Develop API to interact with smart contract to get wallet status "isWhitelisted".
     5. Develop API to interact with smart contract to blacklist a address.
     6. Develop API to interact with off-chain database to get all peers of an address. Call the above API to blacklist/whitelist all peers by calling respective function on smart contract.

   On-chain Verification:
     1. Update the smart contract to allow off-chain management to update the whitelist/blacklist status.
     2. Implement functionality for the smart contract to fetch the whitelist/blacklist status from the off-chain database.
     3. Remove the functionality of iterating over wallet peers from smart contract as We will call the respective whitelist or blacklist function of smart contract from our backend.


   
