# TokenboundERC20
[Git Source](https://github.com/moonstream-to/tokenbound-erc20/blob/bc035748c1f27eaf04a1c7efb8b24f0c6f79bb6a/src/TokenboundERC20.sol)

**Inherits:**
ERC20

**Author:**
Moonstream Engineering (engineering@moonstream.to)

This is an ERC20 contract on which the owner of the bound ERC721 token can mint tokens, and anyone can
burn tokens they hold. The mint authority is immutably and irrevocably tied to an ERC6551 tokenbound account
connected to the ERC721 token.

*The name, symbol, decimals, and address of the account with minting authority are set in the constructor
and can never be changed after the contract is deployed.*


## State Variables
### minter
The address of the account with minting authority on this contract. Once set, this address
can never be changed.


```solidity
address public minter;
```


### _decimals
The number of decimals on


```solidity
uint8 private _decimals;
```


## Functions
### constructor


```solidity
constructor(string memory name_, string memory symbol_, uint8 decimals_, address _minter) ERC20(name_, symbol_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name of the ERC20 token (this is what callers of the `name()` method will see).|
|`symbol_`|`string`|The symbol of the ERC20 token (this is what callers of the `symbol()` method will see).|
|`decimals_`|`uint8`|The number of decimal digits that make up the fractional part of token amounts.|
|`_minter`|`address`|The address of the account with minting authority on this contract.|


### decimals

The number of decimal digits that make up the fractional part of token amounts. If decimals


```solidity
function decimals() public view override returns (uint8);
```

### burn

Allows holders of tokens on this contract to burn any amount of tokens up to their balance.


```solidity
function burn(uint256 value) external;
```

### mint

Allows the holder of the bound ERC721 token to mint additional ERC20 tokens on this contract.


```solidity
function mint(address account, uint256 value) external;
```

## Errors
### InvalidMinter
This error is raised when an account which is not the minter attempts to mint tokens on this contract.


```solidity
error InvalidMinter(address sender);
```

