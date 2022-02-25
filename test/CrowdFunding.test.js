const { expect } = require("chai");

describe("CrowdFunding", function () {
  before(async () => {
    [
      owner,
      contributer1,
      contributer2,
      contributer3,
      contributer4,
      contributer5,
    ] = await ethers.getSigners();
    CrowdFunding = await ethers.getContractFactory("CrowdFunding");
    crowdFunding = await CrowdFunding.deploy(
      "1645767281", // funding start at 1645767281
      "1645768281", // funding end at 1645768281
      "1000", // funding goal is 1000
      "10", // each contributer can contribute minimum 10
      "100" // each contributer can contribute maximum 100
    );
  });

  describe("Deployment", function () {
    it("Should be set the correct total funding", async () => {
      const totalFunding = await crowdFunding.getFundingTarget();

      expect(totalFunding).to.equal(1000);
    });

    it("Should be set the right owner", async () => {
      expect(await crowdFunding.owner()).to.equal(owner.address);
    });

    it("Should be set the correct started epoch time", async () => {
      expect(await crowdFunding.isOpen()).to.equal(true);
    });

    it("Should be set the correct ended epoch time", async () => {
      expect(await crowdFunding.isClosed()).to.equal(false);
    });

    it("Should be set the correct funding target", async () => {
      expect(await crowdFunding.fundingTarget()).to.equal(1000);
    });

    it("Should be set the correct minimum funding", async () => {
      expect(await crowdFunding.minFunding()).to.equal(10);
    });

    it("Should be set the correct maximum funding", async () => {
      expect(await crowdFunding.maxFunding()).to.equal(100);
    });
  });

  describe("Send Funds", () => {
    it("Should be funding are open for trasaction", async () => {
      expect(await crowdFunding.isOpen()).to.equal(true);
    });

    it("Should be the correct minimum and maximum range for funding", async () => {
      expect(await crowdFunding.minFunding()).to.equal(10);
      expect(await crowdFunding.maxFunding()).to.equal(100);
    });

    // it("Should be not in correct funding range", async () => {
    //   expect(await crowdFunding.sendFunds()).to.be.revertedWith(
    //     "Amount is not within the range"
    //   );
    // });
  });
});
