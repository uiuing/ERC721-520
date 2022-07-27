const { ethers, network, run } = require("hardhat");
const { utils } = require("ethers");

const main = async () => {
  // Compile contracts
  await run("compile");
  console.log("Compiled contracts.");
  const token1Contract = await ethers.getContractFactory("MockERC20");
  const token2Contract = await ethers.getContractFactory("MockERC20");
  token1 = await token1Contract.attach("0x3c2e3259e0d3889cfc65bf5c6f58d9fb4de3bf39");
  token2 = await token2Contract.attach("0xa874a23e4b0c9d1d726ec88ade07850a63432032");
  // token1 = await token1Contract.deploy("token1", "token1", utils.parseEther("10000"));
  // token2 = await token2Contract.deploy("token2", "token2", utils.parseEther("10000"));

  // await token1.deployed();
  // await token2.deployed();

  const nftContract = await ethers.getContractFactory("Ticket");
  // nfToken = await nftContract.deploy(
  //   "0x3c2e3259e0d3889cfc65bf5c6f58d9fb4de3bf39",
  //   "0xa874a23e4b0c9d1d726ec88ade07850a63432032"
  // );
  nfToken = await nftContract.attach("0x2b4b6a8C3334411f1db158eaEaF6Da54f2f52311");
  // [owner, bob, jane, sara] = await ethers.getSigners();
  // await nfToken.deployed();

  // await (await nfToken.setFodgMountPerTicket(utils.parseEther("3"))).wait();
  // await (await nfToken.setFboxMountPerTicket(utils.parseEther("6"))).wait();

  // await (await nfToken.setMaxSupply(1667)).wait();
  await (await nfToken.setMaxSupply(3665)).wait();

  // approve token1
  // await (await token1.approve(nfToken.address, utils.parseEther("1000000"))).wait();
  // await (await token2.approve(nfToken.address, utils.parseEther("1000000"))).wait();
  // await (await nfToken.mint(1)).wait();

  // await (await nfToken.withdraw()).wait();
  // console.log("token1", token1.address);
  // console.log("token2", token2.address);
  console.log("nfToken", nfToken.address);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
