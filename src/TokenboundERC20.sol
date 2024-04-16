// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {ERC20} from "../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "../lib/openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenboundERC20 is ERC20 {
    address public minter;
    uint8 private _decimals;

    error InvalidMinter(address sender);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, address _minter) ERC20(name_, symbol_) {
        _decimals = decimals_;
        minter = _minter;
    }

    function decimals() public view override returns (uint8) {
        return uint8(_decimals);
    }

    function burn(uint256 value) external {
        return _burn(msg.sender, value);
    }

    function mint(address account, uint256 value) external {
        if (msg.sender != minter) {
            revert InvalidMinter(msg.sender);
        }
        _mint(account, value);
    }
}

contract BoundERC721 is ERC721 {
    address public tbaRegistryAddress;
    address public tbaImplementationAddress;
    IERC6551Registry private tbaRegistry;
    uint8 public decimals;

    mapping(uint256 => address) public tba;
    mapping(uint256 => address) public tberc20;

    constructor (string memory name_, string memory symbol_, address _tbaRegistryAddress, address _tbaImplementationAddress, uint8 _decimals) ERC721(name_, symbol_) {
        tbaRegistryAddress = _tbaRegistryAddress;
        tbaImplementationAddress = _tbaImplementationAddress;
        tbaRegistry = IERC6551Registry(_tbaRegistryAddress);
        decimals = _decimals;
    }

    function _mintAndDeployTBAAndTBERC20(address to, uint256 tokenId, bytes32 salt, string memory name_, string memory symbol_) internal returns (address, address) {
        tba[tokenId] = tbaRegistry.createAccount(tbaImplementationAddress, salt, block.chainid, address(this), tokenId);
        TokenboundERC20 tberc20Contract = new TokenboundERC20{salt: salt}(name_, symbol_, decimals, tba[tokenId]);
        tberc20[tokenId] = address(tberc20Contract);
        _mint(to, tokenId);
        return (tba[tokenId], tberc20[tokenId]);
    }
}
