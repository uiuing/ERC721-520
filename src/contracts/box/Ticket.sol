// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../contracts/tokens/nf-token-enumerable.sol";
import "../ownership/ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";
import "../../contracts/tokens/nf-token-metadata.sol";

/**
 * @dev This is an example contract implementation of NFToken with enumerable extension.
 */
contract Ticket is NFTokenEnumerable, Ownable, NFTokenMetadata {
    using SafeERC20 for IERC20;

    IERC20 private immutable FODG;
    IERC20 private immutable FBOX;

    uint256 fodgMountPerTicket = 30 * 10**18;
    uint256 fboxMountPerTicket = 60 * 10**18;

    uint256 public maxSupply = 1666;

    constructor(address _fodg, address _fbox) {
        FODG = IERC20(_fodg);
        FBOX = IERC20(_fbox);
        nftName = "FboxArmyTicket";
        nftSymbol = "FboxArmyTicket";
    }

    event Minted(address indexed to, uint256 indexed _amount);

    function setFodgMountPerTicket(uint256 _amount) public onlyOwner {
        fodgMountPerTicket = _amount;
    }

    function setFboxMountPerTicket(uint256 _amount) public onlyOwner {
        fboxMountPerTicket = _amount;
    }

    function setMaxSupply(uint256 _amount) public onlyOwner {
        maxSupply = _amount;
    }

    /**
     * @dev Mints a new NFT.
     */
    function mint(uint256 _amount) external {
        require(tx.origin == msg.sender, "Only the owner can mint tickets");
        require(_amount > 0, "amount must be greater than 0");
        uint256 totalSupply = tokens.length;
        require(totalSupply <= maxSupply, "Max supply reached");
        // 计算需要的 FOG 和 FBOX 的数量
        uint256 fodgAmount = _amount * fodgMountPerTicket;
        uint256 fboxAmount = _amount * fboxMountPerTicket;

        // 检查余额
        require(FODG.balanceOf(tx.origin) >= fodgAmount, "Not enough FODG");
        require(FBOX.balanceOf(tx.origin) >= fboxAmount, "Not enough FBOX");

        // 检查用户的approve是否足够
        require(
            FODG.allowance(tx.origin, address(this)) >= fodgAmount,
            "Not enough FODG allowance"
        );
        require(
            FBOX.allowance(tx.origin, address(this)) >= fboxAmount,
            "Not enough FBOX allowance"
        );

        console.log("fodgAmount", fodgAmount);
        console.log("fboxAmount", fboxAmount);

        console.log("FODG.balanceOf", FODG.balanceOf(tx.origin));
        console.log("FBOX.balanceOf", FBOX.balanceOf(tx.origin));
        // 减去用户的 FODG 和 FBOX
        FODG.transferFrom(msg.sender, address(this), fodgAmount);
        FBOX.transferFrom(msg.sender, address(this), fboxAmount);

        for (uint256 i = 0; i < _amount; i++) {
            _mint(tx.origin, tokens.length + 1);
        }

        emit Minted(tx.origin, _amount);
    }

    /**
     * @dev Removes a NFT from owner.
     * @param _tokenId Which NFT we want to remove.
     */
    function burn(uint256 _tokenId) external onlyOwner {
        _burn(_tokenId);
    }

    function mintByOwner(address _to, uint256 _amount) external onlyOwner {
        for (uint256 i = 0; i < _amount; i++) {
            _mint(_to, tokens.length + 1);
        }
    }

    /**
     * 提取 fodg 和 fbox
     */
    function withdraw() external onlyOwner {
        uint256 fodgAmount = FODG.balanceOf(address(this));
        uint256 fboxAmount = FBOX.balanceOf(address(this));
        FODG.safeTransfer(msg.sender, fodgAmount);
        FBOX.safeTransfer(msg.sender, fboxAmount);
    }

    /**
     * @dev Mints a new NFT.
     * @notice This is an internal function which should be called from user-implemented external
     * mint function. Its purpose is to show and properly initialize data structures when using this
     * implementation.
     * @param _to The address that will own the minted NFT.
     * @param _tokenId of the NFT to be minted by the msg.sender.
     */
    function _mint(address _to, uint256 _tokenId)
        internal
        virtual
        override(NFToken, NFTokenEnumerable)
    {
        NFTokenEnumerable._mint(_to, _tokenId);
    }

    /**
     * @dev Burns a NFT.
     * @notice This is an internal function which should be called from user-implemented external
     * burn function. Its purpose is to show and properly initialize data structures when using this
     * implementation. Also, note that this burn implementation allows the minter to re-mint a burned
     * NFT.
     * @param _tokenId ID of the NFT to be burned.
     */
    function _burn(uint256 _tokenId)
        internal
        virtual
        override(NFTokenMetadata, NFTokenEnumerable)
    {
        NFTokenEnumerable._burn(_tokenId);
        if (bytes(idToUri[_tokenId]).length != 0) {
            delete idToUri[_tokenId];
        }
    }

    /**
     * @notice Use and override this function with caution. Wrong usage can have serious consequences.
     * @dev Removes a NFT from an address.
     * @param _from Address from wich we want to remove the NFT.
     * @param _tokenId Which NFT we want to remove.
     */
    function _removeNFToken(address _from, uint256 _tokenId)
        internal
        override(NFToken, NFTokenEnumerable)
    {
        NFTokenEnumerable._removeNFToken(_from, _tokenId);
    }

    /**
     * @notice Use and override this function with caution. Wrong usage can have serious consequences.
     * @dev Assigns a new NFT to an address.
     * @param _to Address to wich we want to add the NFT.
     * @param _tokenId Which NFT we want to add.
     */
    function _addNFToken(address _to, uint256 _tokenId)
        internal
        override(NFToken, NFTokenEnumerable)
    {
        NFTokenEnumerable._addNFToken(_to, _tokenId);
    }

    /**
     * @dev Helper function that gets NFT count of owner. This is needed for overriding in enumerable
     * extension to remove double storage(gas optimization) of owner nft count.
     * @param _owner Address for whom to query the count.
     * @return Number of _owner NFTs.
     */
    function _getOwnerNFTCount(address _owner)
        internal
        view
        override(NFToken, NFTokenEnumerable)
        returns (uint256)
    {
        return NFTokenEnumerable._getOwnerNFTCount(_owner);
    }
}
