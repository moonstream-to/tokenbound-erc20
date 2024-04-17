# PermissionlessBindingERC721
[Git Source](https://github.com/moonstream-to/tokenbound-erc20/blob/b584017f4f519c3f5c8c0caf5fe209d68eb59ca6/src/BindingERC721.sol)

**Inherits:**
[BindingERC721](/src/BindingERC721.sol/contract.BindingERC721.md)

**Author:**
Moonstream Engineering (engineering@moonstream.to)

This contract is a BindingERC721 contract which allows anyone to mint ERC721 tokens with corresponding
tokenbound ERC20 contracts.

*This implementation adds a public and permissionless mint method to BindingERC721. It doesn't specify
additional behavior, like tokenURI, etc. Subclass this if you want free mints.*


## State Variables
### supply
The number of ERC721 tokens minted by this contract.


```solidity
uint256 public supply = 0;
```


## Functions
### constructor


```solidity
constructor(
    string memory name_,
    string memory symbol_,
    address _tbaRegistryAddress,
    address _tbaImplementationAddress,
    uint8 _decimals
) BindingERC721(name_, symbol_, _tbaRegistryAddress, _tbaImplementationAddress, _decimals);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name of the token collection represented by this ERC721 contract.|
|`symbol_`|`string`|A short identifier for the token collection represented by this ERC721 contract.|
|`_tbaRegistryAddress`|`address`|The address of the ERC6551 registry that this contract uses to create tokenbound accounts.|
|`_tbaImplementationAddress`|`address`|The address of the ERC6551 account implementation for the tokenbound accounts created by this contract.|
|`_decimals`|`uint8`|The number of decimal digits that make up the fractional part of token amounts in all TokenboundERC20 contracts created by this contract.|


### mint

This function allows any caller to mint a token on this contract to any address.

*This is not a "safe" mint - it does not check if a smart contract recipient implements onERC721Received.*


```solidity
function mint(address to) public returns (uint256, address, address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The token ID of the newly minted token, the address of the tokenbound account which has ERC20 minting control, and the address of the TokenboundERC20 contract.|
|`<none>`|`address`||
|`<none>`|`address`||


