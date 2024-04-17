# BindingERC721
[Git Source](https://github.com/moonstream-to/tokenbound-erc20/blob/c3749b7d9f8d80d4678c170755d026810e9ee6fa/src/TokenboundERC20.sol)

**Inherits:**
ERC721

**Author:**
Moonstream Engineering (engineering@moonstream.to)

This is a base ERC721 implementation on which the owner of each ERC721 token has minting authority on
an ERC20 contract bound to that token.

*This contract has a private _mintAndDeployTBAAndTBERC20 function which is used to mint an ERC721 token as well
as deploy a tokenbound account and a TokenboundERC20 contract connected to that token. The contract does not
expose a public minting function because minting logic varies so much between ERC721 implementations.
Subclassing this contract is the intended method of use.*


## State Variables
### tbaRegistryAddress
The address of the ERC6551 registry used to create tokenbound accounts.


```solidity
address public tbaRegistryAddress;
```


### tbaImplementationAddress
The address of the ERC6551 account implementation used to create tokenbound accounts.


```solidity
address public tbaImplementationAddress;
```


### tbaRegistry
An IERC6551Registry instance corresponding to tbaRegistryAddress.


```solidity
IERC6551Registry private tbaRegistry;
```


### decimals
The number of decimals that each TokenboundERC20 contract deployed by this contract will have.


```solidity
uint8 public decimals;
```


### tba
A mapping which relates each token ID to the tokenbound account with minting authority on its TokenboundERC20 contract.


```solidity
mapping(uint256 => address) public tba;
```


### tberc20
A mapping which relates each token ID to its TokenboundERC20 contract.


```solidity
mapping(uint256 => address) public tberc20;
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
) ERC721(name_, symbol_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name of the token collection represented by this ERC721 contract.|
|`symbol_`|`string`|A short identifier for the token collection represented by this ERC721 contract.|
|`_tbaRegistryAddress`|`address`|The address of the ERC6551 registry that this contract uses to create tokenbound accounts.|
|`_tbaImplementationAddress`|`address`|The address of the ERC6551 account implementation for the tokenbound accounts created by this contract.|
|`_decimals`|`uint8`|The number of decimal digits that make up the fractional part of token amounts in all TokenboundERC20 contracts created by this contract.|


### _mintAndDeployTBAAndTBERC20

This function is used to mint an ERC721 token as well as deploy a tokenbound account and a TokenboundERC20 contract connected to that token.


```solidity
function _mintAndDeployTBAAndTBERC20(
    address to,
    uint256 tokenId,
    bytes32 salt,
    string memory name_,
    string memory symbol_
) internal returns (address, address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The account which will own the newly minted ERC721 token.|
|`tokenId`|`uint256`|The intended token ID of the new ERC721 token.|
|`salt`|`bytes32`|A salt used to create the tokenbound account and the TokenboundERC20 contract.|
|`name_`|`string`|The name of the TokenboundERC20 contract.|
|`symbol_`|`string`|The symbol of the TokenboundERC20 contract.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the tokenbound account followed by the address of the TokenboundERC20 contract, both bound to the newly minted ERC721 token with the given tokenId.|
|`<none>`|`address`||


