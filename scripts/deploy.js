async function main() {
  const [deployer] = await ethers.getSigners();
  const CrowdFunding = await ethers.getContractFactory("SimpleAuction");
  const crowdFunding = await CrowdFunding.deploy(
    "604800", // The auction's ending time
    "0x3527c5644158d5cc68fb779dc98f01d92251bccf" // The beneficiary of the auction
  );
  console.log("Deployed Contract Address: ", crowdFunding.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
