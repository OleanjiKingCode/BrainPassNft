// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BrainPassCollectibles.sol";

contract CounterTest is Test {
    BrainPassCollectibles public Brainpass;

    function setUp() public {
        Brainpass = new BrainPassCollectibles("ipfs//cid");
    }

    function testMintNFT() public {
        uint expectedTokenId = 0;
        uint expectedStartTime = block.timestamp;
        string memory passType = "Bronze";

        Brainpass.mintNFT(passType);
        uint actualTokenId = Brainpass.totalSupply() - 1;
        uint actualStartTime = Brainpass.getStartTime(
            msg.sender,
            actualTokenId
        );

        assertEq(actualTokenId, expectedTokenId, "Token ID should match");
        assertEq(actualStartTime, expectedStartTime, "Start time should match");
    }

    function testGetUserNFTs() public {
        uint expectedTokenId = 0;
        string memory passType = "Bronze";

        Brainpass.mintNFT(passType);
        uint256[] memory userTokens = Brainpass.getUserNFTs(msg.sender);

        assertEq(userTokens.length, 1, "User should have 1 NFT");
        assertEq(userTokens[0], expectedTokenId, "NFT Token ID should match");
    }
}
