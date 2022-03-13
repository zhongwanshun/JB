//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AuctionFactory {
    address[] public auctions;

    event AuctionCreated(
        address auctionContract,
        address owner,
        uint256 numAuctions,
        address[] allAuctions
    );

    function allAuctions() public view returns (address[] memory) {
        return auctions;
    }
}
