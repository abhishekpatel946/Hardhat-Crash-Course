async function main() {
  const [deployer] = await ethers.getSigners();
  const TestToken = await ethers.getContractFactory("TestToken");
  const testToken = await TestToken.deploy();
  console.log("Deployed TestToken: ", testToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
