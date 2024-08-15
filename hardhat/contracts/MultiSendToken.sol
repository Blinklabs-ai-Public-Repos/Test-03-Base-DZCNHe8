// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/**
 * @title MultiSendToken
 * @dev ERC20 token with multisend feature and inherits from OpenZeppelin Multicall
 */
contract MultiSendToken is ERC20, ERC20Burnable, Pausable, Ownable, Multicall {
    uint256 private immutable _maxSupply;

    /**
     * @dev Constructor that sets the name, symbol, and max supply of the token
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param maxSupply_ The maximum supply of the token
     */
    constructor(string memory name_, string memory symbol_, uint256 maxSupply_) ERC20(name_, symbol_) {
        require(maxSupply_ > 0, "Max supply must be greater than 0");
        _maxSupply = maxSupply_;
    }

    /**
     * @dev Returns the maximum supply of the token
     * @return The maximum supply
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Pauses all token transfers
     * @notice Can only be called by the contract owner
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers
     * @notice Can only be called by the contract owner
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Mints new tokens
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     * @notice Can only be called by the contract owner
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= _maxSupply, "Minting would exceed max supply");
        _mint(to, amount);
    }

    /**
     * @dev Sends tokens to multiple recipients in a single transaction
     * @param recipients An array of recipient addresses
     * @param amounts An array of amounts to send to each recipient
     * @return success A boolean indicating whether the operation was successful
     */
    function multiSend(address[] memory recipients, uint256[] memory amounts) public returns (bool success) {
        require(recipients.length == amounts.length, "Recipients and amounts arrays must have the same length");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        require(balanceOf(_msgSender()) >= totalAmount, "Insufficient balance for multisend");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(_msgSender(), recipients[i], amounts[i]);
        }
        
        return true;
    }

    /**
     * @dev Hook that is called before any transfer of tokens
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param amount The amount of tokens transferred
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}