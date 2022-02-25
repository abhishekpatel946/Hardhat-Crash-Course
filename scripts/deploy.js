async function main() {
  const [deployer] = await ethers.getSigners();
  const CrowdFunding = await ethers.getContractFactory("CrowdFunding");
  const crowdFunding = await CrowdFunding.deploy(
    "1645767281", // funding start at 1645767281
    "1645768281", // funding end at 1645768281
    "1000", // funding goal is 1000
    "10", // each contributer can contribute minimum 10
    "100" // each contributer can contribute maximum 100
  );
  console.log("Deployed Contract Address: ", crowdFunding.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
