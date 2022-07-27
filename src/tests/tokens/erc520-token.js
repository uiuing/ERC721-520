const { expect } = require("chai");
const { utils } = require("ethers");

describe("ticket-token", function() {
  let nfToken, owner, bob, jane, sara, token1, token2;
  const zeroAddress = "0x0000000000000000000000000000000000000000";
  const id1 = 0;
  const id2 = 1;

  beforeEach(async () => {
    const token1Contract = await ethers.getContractFactory("MockERC20");
    const token2Contract = await ethers.getContractFactory("MockERC20");

    token1 = await token1Contract.deploy("token1", "token1", utils.parseEther("10000"));
    token2 = await token2Contract.deploy("token2", "token2", utils.parseEther("10000"));

    await token1.deployed();
    await token2.deployed();

    const nftContract = await ethers.getContractFactory("Ticket");
    nfToken = await nftContract.deploy(token1.address, token2.address);
    [owner, bob, jane, sara] = await ethers.getSigners();
    await nfToken.deployed();
  });

  it("correctly checks all the supported interfaces", async function() {
    const token1Balance = await token1.balanceOf(owner.address);
    const token2Balance = await token2.balanceOf(owner.address);

    console.log("token1Balance", utils.formatEther(token1Balance.toString()));
    console.log("token2Balance", utils.formatEther(token2Balance.toString()));
    await (await token1.approve(nfToken.address, utils.parseEther("100"))).wait();
    await (await token2.approve(nfToken.address, utils.parseEther("100"))).wait();

    await (await nfToken.mint(1)).wait();

    const token1BalanceLeft = await token1.balanceOf(owner.address);
    const token2BalanceLeft = await token2.balanceOf(owner.address);
    console.log("token1BalanceLeft", utils.formatEther(token1BalanceLeft.toString()));
    console.log("token1BalanceLeft", utils.formatEther(token1BalanceLeft.toString()));
    expect(utils.formatEther(token1Balance.sub(token1BalanceLeft))).to.equal("20.0");
    expect(utils.formatEther(token2Balance.sub(token2BalanceLeft))).to.equal("50.0");

    console.log("token1 balance", utils.formatEther(await token1.balanceOf(nfToken.address)));
    console.log("token2 balance", utils.formatEther(await token2.balanceOf(nfToken.address)));

    await (await nfToken.withdraw()).wait();
    console.log("token1 balance", utils.formatEther(await token1.balanceOf(nfToken.address)));
    console.log("token2 balance", utils.formatEther(await token2.balanceOf(nfToken.address)));

    expect(await nfToken.totalSupply()).to.equal(1);

    await (await nfToken.transferFrom(owner.address, bob.address, 1)).wait();

    console.log("transform owner to bob");

    console.log("owner balance", await nfToken.balanceOf(owner.address));
    console.log("bob balance", await nfToken.balanceOf(bob.address));
  });
});
