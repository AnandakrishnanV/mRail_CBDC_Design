# mRail Detailed Report

- Inspired by the mBridge Report
- Idea to do a mock version on Ethereum for learning, experimenting, exploring
- Idea to add currency pooling, where entities can act as an intermediary for CBDCexchange, here another Central Bank can act as an intermediary, auto resolving from a pool of consenting wallets

## Current Design

### Bank of Banks contract

- A dumb contract that acts as the intermediary between all participating Central Banks - only one instance ever deployed
    - Holds address, currency and country name of each Central Bank contract
    - Acts as the point where a new CB should register itself with for recognition on the chain
    - Acts as the point where countries can request address of other CDBCs that can be used to hold/transact the respective CBDC

### Central Bank contract

- The contract that can be used to instantiate new Central Banks into the chain
    - Can register with the Bank of Banks after instantiation, using secret key (encryption not yet implemented)
    - Holds details of the CBDC ( name, symbol)
    - Mints new CBDCs
    - Holds its own reserves
    - Holds details of primaryUsers i.e. users who are citizens the country, after KYC
    - Hold details of secondrayUsers i.e. users who are citizens another country but has been granted access to this CBDC, after KYC
    - Holds details of Country’s policies on other  CBDCs (and can modify each):
        - Policy on use of other CBDCs inside country i.e. for primaryUsers
        - Policy on use and access for secondaryUsers based on relations to their country
    - Facilitates all transfers of the CBDCs between all its users
    - Spawner for all its primaryUsers (called RetailUsers)
    - Can view balances of all users of its CBDC

### RetailUser contract - Retail Bank Change Needed. Refer Notion (for authors only)

- Holds own details, parent Central Bank details
- Holds address of other CBDCs (allowed to be used)
- Can transact all held CBDCs with other valid users
- Can request for access of other CBDCs to Central Bank contract
- Can view its balances

### Real World Scenarios and Walkthroughs

| S.No | Scenario | Parties Involved | mRail Walkthrough | Improvements | Current Real World Process |
| --- | --- | --- | --- | --- | --- |
| 1 | New Central Bank Created | Bank, BankOfBanks | Real world connection to the BankOfBanks. Then registers the contract with BankOfBanks with the secure key and bank details to join the chain. Can now access other countries |  | - |
| 2 | Company A joining the network through MAS | MAS, Company A  | Company A registers with the MAS off chain and gives its own wallet address. MAS spawns a retail user contract using the form Company A submitted and transfers the RetailUser contract to Company A. The RetailUser contract shall act as a wallet for holding all CBDCs | Can be abstracted to a bank like HSBC spawning on behalf of MAS | Company A creates a Bank account with a registered bank |
| 3 | Company A wants to begin using INR for business in India | MAS, Company A, RBI | Company A requests MAS through a contract to access INR. MAS evaluates Company A’s wallet with some code (is Company A allowed to do this, etc. Can be fully automated or a manual step), then MAS  checks if RBI and MAS have an agreement to allow free flow or a limited flow. Based on results, if it is okay, MAS sends over details of Company A along with addition request to RBI. RBI checks if there is an agreement with MAS and if there are any restrictions by default, such as SG companies can use up to 1 million INR or so, then add MAS as a secondary user in RBI for INR and send back an acknowledgement to MAS. MAS then says Company A can begin trading INR and send over the INR/RBI address. Company A can now transact in INR. | Can be abstracted to banks as middlemen | Company A registers separately in India and goes through a very similar KYC process and stuff |
| 4 | Company A tries to trade in CNY without going through <registration through MAS> process | MAS, Company A, CNY | Company A identifies CNYs address and directly requests a transfer,  CNY checks if Company A exists in secondary users and will auto reject any request. Company A has to do an initial handshake through MAS. | China triggers an event to MAS saying Company A tried to access CNY | Company A can try directly doing business in China. Smaller companies may pull it off in lesser developed countries. |
| 5 | JPY decided that no SG companies can now trade in Yen | MAS, Company A, JPY | JPY sets all SG user trade status to 0. Now, even if SG companies held Yen, they can see balances but cannot transfer or trade them. Company A can view balance but nothing else |  | JPY has to contact all banks Company A has an account with or digitally block. Not instantaneous |
| 6 | RBI decides to increase spend limit of Company A and decrease limit of Company B | RBI, Company A, Company B | RBI increases status of Company A and decreases status of Company B. Companies can be Internal and External |  | Will involve working with all banks they have accounts in for restrictions. Administrative nightmare to pull it off in a short timespan. |
| 7 | Trading Currencies |  | TO BE IMPLEMENTED - request a exchange and all central banks come together to facilitate the exchange. Exchange rate queried from Bank Of Banks | TO BE IMPLEMENTED Phase 1 : Full exchange settled by a single bank Phase 2 : Exchange by multiple banks coming together Phase 3 : free mobility of currency between banks to ensure much faster trades | Go through Forex markets |
