# Hardhat-Crash-Course
This hardhat template comes with some setup scripts, tasks and an example docker compose service to get contract development into your app quickly.

The idea is that it can be dropped into any frontend project using docker compose easily. Allowing you to quickly iterate on contract development and integration with your frontend.

## Getting started
Clone the repo into your project directory:
```bash
git clone https://github.com/abhishekpatel946/Hardhat-Crash-Course.git hardhat
```

Deployed Token Address:
- TestToken
```bash
0x973Dc12Bd0496A4063A2b81EcE6A0979Ceb08e54
```
- CrowdFunding
```bash
0x5FbDB2315678afecb367f032d93F642f64180aa3
```

Etherscan Contract Creation Hash:
- TestToken
```bash
https://ropsten.etherscan.io/tx/0x22efa4f6f758432fc1a4dd759f495fed4fbc73792e7f4f0b99204b542be591bf
```
- CrowdFunding
```bash
https://ropsten.etherscan.io/tx/0xbaface72ab0d9b896f25b6471977210e46ff7ac0e136e7a4d8e3d88208eaf010
```
## Getting started with Hardhat
Install all the dependencies
```bash
npm i
```

Run the test for all contracts
```bash
npx hardhat test
```

Deploy the contract in locally using hardhat network
```bash
npx hardhat run scripts/deploy.js
```

Note: Change the `scripts/deploy.js` and run the below command to deploy the specific contract.

Deploy the contract in testnet like: ropsten
```bash
npx hardhat run scripts/deploy.js --network ropsten
```



Add the following service to your `docker-compose.yml`:
```yaml
hardhat:
  build:
    context: ./hardhat
    dockerfile: Dockerfile.dev
  restart: always
  command: yarn run dev
  volumes: 
    - ./hardhat:/app
    - /app/node_modules
    - ./<PATH_TO_FRONTEND_DIR>/contracts:/app/tmp/contracts
  ports:
    - 8545:8545
```



Once the service has been started with `docker-compose up` you contracts will be deployed to the localhost:8545 RPC. When you save the contract files they will be redeployed.

When contracts are compiled and deployed the output files are saved to `/deployments/<network>` in the hardhat container. Mounting this folder to a volume in the service as we did above with `- ./<PATH_TO_FRONTEND_DIR>/contracts:/app/deployments` means that these contracts will then be available in your frontend directory under `/contracts`.

## Deployment
First add your credentials to the `.env.example` file and rename to `.env`.

To deploy to networks other than localhost you can run commands like:
```bash
docker-compose run hardhat mainnet:deploy
```
For a full list of deployment commands for different networks see [package.json](/package.json).

## Tasks
There are a default tasks for interacting with the localhost network when it's up and running. 
```bash
docker-compose exec hardhat accounts # fetch list of default network accounts
docker-compose exec hardhat balance <address> # Get balance for an address
docker-compose exec hardhat send --from <address> --to <address> --amount 10 # Send ETH from one address to another
docker-compose exec hardhat blockNumber # Get the current blocknumber
