// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {ERC6551Registry} from "../lib/erc6551/src/ERC6551Registry.sol";
import {ERC6551Account} from "../lib/erc6551/src/examples/simple/ERC6551Account.sol";

import {TokenboundERC20} from "../src/TokenboundERC20.sol";
import {BindingERC721, PermissionlessBindingERC721} from "../src/BindingERC721.sol";


contract TokenboundERC20Tests is Test {
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

    function test_tberc20_mint_through_tba_as_nft_owner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));
        ERC6551Account tba = ERC6551Account(payable(nfts.tba(tokenId)));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player1);
        tba.execute(address(tberc20), 0, abi.encodeWithSelector(tberc20.mint.selector, player3, 100), 0);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 100);
    }

    function testRevert_tberc20_mint_directly_as_nft_owner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(TokenboundERC20.InvalidMinter.selector, player1));
        tberc20.mint(player3, 100);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 0);
    }

    function testRevert_tberc20_mint_through_tba_as_ex_nft_owner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));
        ERC6551Account tba = ERC6551Account(payable(nfts.tba(tokenId)));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player1);
        nfts.transferFrom(player1, player2, tokenId);
        vm.expectRevert("Invalid signer");
        tba.execute(address(tberc20), 0, abi.encodeWithSelector(tberc20.mint.selector, player3, 100), 0);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 0);
    }

    function testRevert_tberc20_mint_through_tba_as_nonowner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));
        ERC6551Account tba = ERC6551Account(payable(nfts.tba(tokenId)));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player2);
        vm.expectRevert("Invalid signer");
        tba.execute(address(tberc20), 0, abi.encodeWithSelector(tberc20.mint.selector, player3, 100), 0);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 0);
    }

    function test_tberc20_mint_through_tba_as_new_nft_owner() public {
        (uint256 tokenId,,) = nfts.mint(player1);

        TokenboundERC20 tberc20 = TokenboundERC20(nfts.tberc20(tokenId));
        ERC6551Account tba = ERC6551Account(payable(nfts.tba(tokenId)));

        assertEq(tberc20.balanceOf(player3), 0);

        vm.prank(player1);
        nfts.transferFrom(player1, player2, tokenId);

        vm.prank(player2);
        tba.execute(address(tberc20), 0, abi.encodeWithSelector(tberc20.mint.selector, player3, 100), 0);
        vm.stopPrank();

        assertEq(tberc20.balanceOf(player3), 100);
    }
}
