// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {ERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {ERC6551Account} from "../lib/erc6551/src/examples/simple/ERC6551Account.sol";
import {IERC721Errors} from "../lib/openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {TokenboundERC20} from "../src/TokenboundERC20.sol";
import {PermissionlessBindingERC721} from "../src/BindingERC721.sol";


contract BindingERC721Tests is Test {
    ERC6551Registry private registry;
    ERC6551Account private accountImplementation;
    PermissionlessBindingERC721 private nfts;

    uint256 private player1PrivateKey = 0x1;
    uint256 private player2PrivateKey = 0x2;
    uint256 private player3PrivateKey = 0x3;

    address private player1 = vm.addr(player1PrivateKey);
    address private player2 = vm.addr(player2PrivateKey);
    address private player3 = vm.addr(player3PrivateKey);

    function setUp() public {
        registry = new ERC6551Registry();
        accountImplementation = new ERC6551Account();
        nfts = new PermissionlessBindingERC721("test", "test", address(registry), address(accountImplementation), 0);
    }

    function test_mint_nft() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        assertEq(nfts.ownerOf(tokenId), player1);

        assertEq(registry.account(address(accountImplementation), bytes32(0), block.chainid, address(nfts), tokenId), nfts.tba(tokenId));
        assertGt(address(nfts.tba(tokenId)).code.length, 0);
        assertGt(address(nfts.tberc20(tokenId)).code.length, 0);
    }

    function test_mint_nft_if_tba_already_created_with_same_salt() public {
        uint256 tokenId = nfts.supply() + 1;

        address directTBAAddress = registry.createAccount(address(accountImplementation), bytes32(0), block.chainid, address(nfts), tokenId);

        nfts.mint(player1);

        assertEq(nfts.tba(tokenId), directTBAAddress);
    }

    function test_mint_nft_if_tba_already_created_with_same_salt_differnt_account_implementation() public {
        ERC6551Account otherAccountImplementation = new ERC6551Account();

        uint256 tokenId = nfts.supply() + 1;

        address directTBAAddress = registry.createAccount(address(otherAccountImplementation), bytes32(0), block.chainid, address(nfts), tokenId);

        nfts.mint(player1);

        assertTrue(nfts.tba(tokenId) != directTBAAddress);
    }

    function test_mint_tberc20_through_binding_erc721_as_owner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player1);
        nfts.mintTokenboundERC20(tokenId, player3, 100);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 100);
        assertEq(nfts.ownerOf(tokenId), player1);
    }

    function testRevert_mint_tberc20_through_binding_erc721_as_nonowner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player2);
        vm.expectRevert("BindingERC721: only the owner of the NFT can mint tokenbound ERC20 tokens");
        nfts.mintTokenboundERC20(tokenId, player3, 100);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 0);
        assertEq(nfts.ownerOf(tokenId), player1);
    }

    function testRevert_mint_tberc20_for_nonexistent_tokenid() public {
        uint256 tokenId = nfts.supply() + 1;

        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, tokenId));
        nfts.mintTokenboundERC20(tokenId, player3, 100);
        vm.stopPrank();
    }

}
