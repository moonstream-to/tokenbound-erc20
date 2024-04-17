// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC6551Executable} from "../lib/erc6551/src/interfaces/IERC6551Executable.sol";
import {IERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {ERC721} from "../lib/openzeppelin/contracts/token/ERC721/ERC721.sol";
import {TokenboundERC20} from "./TokenboundERC20.sol";

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

    function mintTokenboundERC20(uint256 tokenId, address to, uint256 amount) public {
        require(msg.sender == ownerOf(tokenId), "BindingERC721: only the owner of the NFT can mint tokenbound ERC20 tokens");
        IERC6551Executable boundAccount = IERC6551Executable(payable(tba[tokenId]));
        _transfer(msg.sender, address(this), tokenId);
        boundAccount.execute(tberc20[tokenId], 0, abi.encodeWithSelector(TokenboundERC20.mint.selector, to, amount), 0);
        _transfer(address(this), msg.sender, tokenId);
    }
}

/// @title A permissionless implementation of an ERC721 contract designed to bind Tokenbound ERC20s
/// @author Moonstream Engineering (engineering@moonstream.to)
/// @notice This contract is a BindingERC721 contract which allows anyone to mint ERC721 tokens with corresponding
/// tokenbound ERC20 contracts.
/// @dev This implementation adds a public and permissionless mint method to BindingERC721. It doesn't specify
/// additional behavior, like tokenURI, etc. Subclass this if you want free mints.
contract PermissionlessBindingERC721 is BindingERC721 {
    /// @notice The number of ERC721 tokens minted by this contract.
    uint256 public supply = 0;

    /// @param name_ The name of the token collection represented by this ERC721 contract.
    /// @param symbol_ A short identifier for the token collection represented by this ERC721 contract.
    /// @param _tbaRegistryAddress The address of the ERC6551 registry that this contract uses to create tokenbound accounts.
    /// @param _tbaImplementationAddress The address of the ERC6551 account implementation for the tokenbound accounts created by this contract.
    /// @param _decimals The number of decimal digits that make up the fractional part of token amounts in all TokenboundERC20 contracts created by this contract.
    constructor (string memory name_, string memory symbol_, address _tbaRegistryAddress, address _tbaImplementationAddress, uint8 _decimals) BindingERC721(name_, symbol_, _tbaRegistryAddress, _tbaImplementationAddress, _decimals) {}

    /// @notice This function allows any caller to mint a token on this contract to any address.
    /// @dev This is not a "safe" mint - it does not check if a smart contract recipient implements onERC721Received.
    /// @return The token ID of the newly minted token, the address of the tokenbound account which has ERC20 minting control, and the address of the TokenboundERC20 contract.
    function mint(address to) public returns (uint256, address, address) {
        uint256 newTokenID = supply + 1;
        (address tbaAddress, address tberc20Address) = _mintAndDeployTBAAndTBERC20(to, newTokenID, bytes32(0), symbol(), symbol());
        supply = newTokenID;
        return (newTokenID, tbaAddress, tberc20Address);
    }
}
