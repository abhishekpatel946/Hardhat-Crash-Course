const { expect } = require("chai");

describe("TestToken", function () {
  it("Should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const TestToken = await ethers.getContractFactory("TestToken");
    const testToken = await TestToken.deploy();

    const ownerBalance = await testToken.balanceOf(owner.address);

    expect(await testToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Should transfer between accounts", async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    const TestToken = await ethers.getContractFactory("TestToken");
    const testToken = await TestToken.deploy();

    await testToken.transfer(user1.address, 100);

    expect(await testToken.balanceOf(owner.address)).to.equal(900);
    expect(await testToken.balanceOf(user1.address)).to.equal(100);
    expect(await testToken.balanceOf(user2.address)).to.equal(0);

    await testToken.transfer(user2.address, 200);

    expect(await testToken.balanceOf(owner.address)).to.equal(800);
    expect(await testToken.balanceOf(user1.address)).to.equal(100);
    expect(await testToken.balanceOf(user2.address)).to.equal(200);
  });
});
