## Tokenbound ERC20s

A tokenbound ERC20 is an ERC20 contract which is bound permanently to an NFT. The holder of the NFT has
the *sole* and *irrevocable* authority to mint tokens on the tokenbound ERC20 contract to anyone they choose.

This authority transfers with the NFT.

### How they work

This repository implements two contracts:
1. `TokenboundERC20` - the actual ERC20 implementation which confers minting privileges to the holder of the binding NFT.
2. `BindingERC721` - an ERC721 implementation which is responsible for the deployment of the tokenbound account and the tokenbound ERC20 contract
bound to each of its NFTs.

Every time an NFT is minted on the `BindingERC721` contract, it deploys a tokenbound account and a tokenbound ERC20 contract
which respects the minting authority of that tokenbound account (and *only* that tokenbound account).

In this architecture, the ERC721 contract is self-aware in the sense that it has a canonical Tokenbound registry
and account implementation which it uses to configure its Tokenbound ERC20 contracts.

### Motivation

Tokenbound ERC20s originated as a mechanic in our permissionless game, [The Degen Trail](https://github.om/moonstream-to/degen-trail),
which is being developed in partnership with [OP Games](https://arcadia.fun/).

We intend to use Tokenbound ERC20s as a system in other games, and feel they might be useful even outside
of the scope of our games. This is why we are releasing them in a standalone repository.

### Development

This project can be built and tested using [Foundry](https://github.com/foundry-rs/foundry).

To build:

```bash
forge build
```

To test:

```bash
forge test -vvv
```

For technical documentation:

```bash
forge doc --serve
```

You can read the technical documentation directly from this repo using [this index](./docs/src/SUMMARY.md).
