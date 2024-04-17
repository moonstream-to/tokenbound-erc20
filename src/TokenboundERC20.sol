// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {ERC20} from "../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "../lib/openzeppelin/contracts/token/ERC721/ERC721.sol";

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

/// @title An ERC721 implementation which binds Tokenbound ERC20s
/// @author Moonstream Engineering (engineering@moonstream.to)
/// @notice This is a base ERC721 implementation on which the owner of each ERC721 token has minting authority on
/// an ERC20 contract bound to that token.
/// @dev This contract has a private _mintAndDeployTBAAndTBERC20 function which is used to mint an ERC721 token as well
/// as deploy a tokenbound account and a TokenboundERC20 contract connected to that token. The contract does not
/// expose a public minting function because minting logic varies so much between ERC721 implementations.
/// Subclassing this contract is the intended method of use.
contract BindingERC721 is ERC721 {
    /// @notice The address of the ERC6551 registry used to create tokenbound accounts.
    address public tbaRegistryAddress;
    /// @notice The address of the ERC6551 account implementation used to create tokenbound accounts.
    address public tbaImplementationAddress;
    /// @notice An IERC6551Registry instance corresponding to tbaRegistryAddress.
    IERC6551Registry private tbaRegistry;
    /// @notice The number of decimals that each TokenboundERC20 contract deployed by this contract will have.
    uint8 public decimals;

    /// @notice A mapping which relates each token ID to the tokenbound account with minting authority on its TokenboundERC20 contract.
    mapping(uint256 => address) public tba;
    /// @notice A mapping which relates each token ID to its TokenboundERC20 contract.
    mapping(uint256 => address) public tberc20;

    /// @param name_ The name of the token collection represented by this ERC721 contract.
    /// @param symbol_ A short identifier for the token collection represented by this ERC721 contract.
    /// @param _tbaRegistryAddress The address of the ERC6551 registry that this contract uses to create tokenbound accounts.
    /// @param _tbaImplementationAddress The address of the ERC6551 account implementation for the tokenbound accounts created by this contract.
    /// @param _decimals The number of decimal digits that make up the fractional part of token amounts in all TokenboundERC20 contracts created by this contract.
    constructor (string memory name_, string memory symbol_, address _tbaRegistryAddress, address _tbaImplementationAddress, uint8 _decimals) ERC721(name_, symbol_) {
        tbaRegistryAddress = _tbaRegistryAddress;
        tbaImplementationAddress = _tbaImplementationAddress;
        tbaRegistry = IERC6551Registry(_tbaRegistryAddress);
        decimals = _decimals;
    }

    /// @notice This function is used to mint an ERC721 token as well as deploy a tokenbound account and a TokenboundERC20 contract connected to that token.
    /// @param to The account which will own the newly minted ERC721 token.
    /// @param tokenId The intended token ID of the new ERC721 token.
    /// @param salt A salt used to create the tokenbound account and the TokenboundERC20 contract.
    /// @param name_ The name of the TokenboundERC20 contract.
    /// @param symbol_ The symbol of the TokenboundERC20 contract.
    /// @return The address of the tokenbound account followed by the address of the TokenboundERC20 contract, both bound to the newly minted ERC721 token with the given tokenId.
    function _mintAndDeployTBAAndTBERC20(address to, uint256 tokenId, bytes32 salt, string memory name_, string memory symbol_) internal returns (address, address) {
        tba[tokenId] = tbaRegistry.createAccount(tbaImplementationAddress, salt, block.chainid, address(this), tokenId);
        TokenboundERC20 tberc20Contract = new TokenboundERC20{salt: salt}(name_, symbol_, decimals, tba[tokenId]);
        tberc20[tokenId] = address(tberc20Contract);
        _mint(to, tokenId);
        return (tba[tokenId], tberc20[tokenId]);
    }
}
