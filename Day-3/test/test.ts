import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("SaveAsset", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const ERC20 = await hre.ethers.getContractFactory("contracts/ERC20.sol:ERC20");
    const token = await ERC20.deploy() as any;

    const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
    const saveAsset = await SaveAsset.deploy(await token.getAddress());

    return { owner, otherAccount, token, saveAsset };
  }

  describe("ERC20 basic metadata only", function () {
    it("checks name, symbol, decimals", async function () {
      const { token } = await loadFixture(deployFixture);

      expect(await token.name()).to.equal("WEB3CXIV");
      expect(await token.symbol()).to.equal("CXIV");
      expect(await token.decimals()).to.equal(18);
    });
  });

  describe("SaveAsset ETH functions", function () {
    it("deposits ETH and updates user + contract balances", async function () {
      const { owner, saveAsset } = await loadFixture(deployFixture);
      const amount = hre.ethers.parseEther("1");

      await expect(saveAsset.deposit({ value: amount }))
        .to.emit(saveAsset, "DepositSuccessful")
        .withArgs(owner.address, amount);

      expect(await saveAsset.getUserSavings()).to.equal(amount);
      expect(await saveAsset.getContractBalance()).to.equal(amount);
    });

    it("reverts on zero ETH deposit", async function () {
      const { saveAsset } = await loadFixture(deployFixture);

      await expect(saveAsset.deposit({ value: 0 })).to.be.revertedWith(
        "Can't deposit zero value"
      );
    });

    it("withdraws ETH from savings", async function () {
      const { saveAsset } = await loadFixture(deployFixture);
      const depositAmount = hre.ethers.parseEther("1");
      const withdrawAmount = hre.ethers.parseEther("0.4");

      await saveAsset.deposit({ value: depositAmount });
      await saveAsset.withdraw(withdrawAmount);

      expect(await saveAsset.getUserSavings()).to.equal(depositAmount - withdrawAmount);
      expect(await saveAsset.getContractBalance()).to.equal(depositAmount - withdrawAmount);
    });

    it("reverts ETH withdraw when user has no savings", async function () {
      const { saveAsset } = await loadFixture(deployFixture);

      await expect(saveAsset.withdraw(1)).to.be.revertedWith("Insufficient funds");
    });
  });

  describe("SaveAsset ERC20 functions", function () {
    it("deposits ERC20 into savings", async function () {
      const { owner, token, saveAsset } = await loadFixture(deployFixture);
      const amount = hre.ethers.parseEther("100");

      await token.mint(owner.address, amount);
      await token.approve(await saveAsset.getAddress(), amount);

      await expect(saveAsset.depositERC20(amount))
        .to.emit(saveAsset, "DepositSuccessful")
        .withArgs(owner.address, amount);

      expect(await saveAsset.getErc20SavingsBalance()).to.equal(amount);
    });

    it("withdraws ERC20 from savings", async function () {
      const { owner, token, saveAsset } = await loadFixture(deployFixture);
      const amount = hre.ethers.parseEther("100");
      const withdrawAmount = hre.ethers.parseEther("30");

      await token.mint(owner.address, amount);
      await token.approve(await saveAsset.getAddress(), amount);
      await saveAsset.depositERC20(amount);

      await saveAsset.withdrawERC20(withdrawAmount);

      expect(await saveAsset.getErc20SavingsBalance()).to.equal(amount - withdrawAmount);
      expect(await token.balanceOf(owner.address)).to.equal(withdrawAmount);
    });
  });
});
