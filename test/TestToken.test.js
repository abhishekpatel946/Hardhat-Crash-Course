const { expect } = require("chai");

describe("TestToken", function () {
  let owner, TestToken, testToken, user1, user2;
  before(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.deploy();
  });

  describe("Deployment", function () {
    it("Should assign the total supply of tokens to the owner", async () => {
      const ownerBalance = await testToken.balanceOf(owner.address);

      expect(await testToken.totalSupply()).to.equal(ownerBalance);
    });

    it("Should set the right owner", async () => {
      expect(await testToken.owner()).to.equal(owner.address);
    });
  });

  describe("Transactions", () => {
    it("Should transfer tokens correctly", async () => {
      await testToken.transfer(user1.address, 100);

      // expect(await testToken.balanceOf(owner.address)).to.equal(900);
      expect(await testToken.balanceOf(user1.address)).to.equal(100);
      expect(await testToken.balanceOf(user2.address)).to.equal(0);

      await testToken.transfer(user2.address, 200);

      // expect(await testToken.balanceOf(owner.address)).to.equal(800);
      expect(await testToken.balanceOf(user1.address)).to.equal(100);
      expect(await testToken.balanceOf(user2.address)).to.equal(200);
    });

    it("Should fail if sender have insufficient tokens", async () => {
      const initialOwnerBalance = await testToken.balanceOf(owner.address);
      await expect(
        testToken.connect(user1).transfer(owner.address, 1000)
      ).to.be.revertedWith("Insufficient balance");
      expect(await testToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should udpate balances after transfer", async () => {
      const initialOwnerBalance = await testToken.balanceOf(owner.address);

      await testToken.transfer(user1.address, 500);
      await testToken.transfer(user2.address, 500);

      const initialUser1Balance = await testToken.balanceOf(user1.address);
      const initialUser2Balance = await testToken.balanceOf(user2.address);

      expect(await testToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance - 1000
      );
      expect(await testToken.balanceOf(user1.address)).to.equal(600);
      expect(await testToken.balanceOf(user2.address)).to.equal(700);
    });
  });
});
