# BoundERC721
[Git Source](https://github.com/moonstream-to/tokenbound-erc20/blob/c3749b7d9f8d80d4678c170755d026810e9ee6fa/src/TokenboundERC20.sol)

**Inherits:**
ERC721


## State Variables
### tbaRegistryAddress

```solidity
address public tbaRegistryAddress;
```


### tbaImplementationAddress

```solidity
address public tbaImplementationAddress;
```


### tbaRegistry

```solidity
IERC6551Registry private tbaRegistry;
```


### decimals

```solidity
uint8 public decimals;
```


### tba

```solidity
mapping(uint256 => address) public tba;
```


### tberc20

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

### _mintAndDeployTBAAndTBERC20


```solidity
function _mintAndDeployTBAAndTBERC20(
    address to,
    uint256 tokenId,
    bytes32 salt,
    string memory name_,
    string memory symbol_
) internal returns (address, address);
```

