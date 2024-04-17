// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Tokenbound ERC20 contract
/// @author Moonstream Engineering (engineering@moonstream.to)
/// @notice This is an ERC20 contract on which the owner of the bound ERC721 token can mint tokens, and anyone can
/// burn tokens they hold. The mint authority is immutably and irrevocably tied to an ERC6551 tokenbound account
/// connected to the ERC721 token.
/// @dev The name, symbol, decimals, and address of the account with minting authority are set in the constructor
/// and can never be changed after the contract is deployed.
contract TokenboundERC20 is ERC20 {
    /// @notice The address of the account with minting authority on this contract. Once set, this address
    /// can never be changed.
    address public minter;

    /// @notice The number of decimals on
    uint8 private _decimals;

    /// @notice This error is raised when an account which is not the minter attempts to mint tokens on this contract.
    error InvalidMinter(address sender);

    /// @param name_ The name of the ERC20 token (this is what callers of the `name()` method will see).
    /// @param symbol_ The symbol of the ERC20 token (this is what callers of the `symbol()` method will see).
    /// @param decimals_ The number of decimal digits that make up the fractional part of token amounts.
    /// @param _minter The address of the account with minting authority on this contract.
    constructor(string memory name_, string memory symbol_, uint8 decimals_, address _minter) ERC20(name_, symbol_) {
        _decimals = decimals_;
        minter = _minter;
    }

    /// @notice The number of decimal digits that make up the fractional part of token amounts. If decimals
    // is 3, then a balance of 12345 tokens should be displayed to a user as 12.345.
    function decimals() public view override returns (uint8) {
        return uint8(_decimals);
    }

    /// @notice Allows holders of tokens on this contract to burn any amount of tokens up to their balance.
    function burn(uint256 value) external {
        return _burn(msg.sender, value);
    }

    /// @notice Allows the holder of the bound ERC721 token to mint additional ERC20 tokens on this contract.
    function mint(address account, uint256 value) external {
        if (msg.sender != minter) {
            revert InvalidMinter(msg.sender);
        }
        _mint(account, value);
    }
}
