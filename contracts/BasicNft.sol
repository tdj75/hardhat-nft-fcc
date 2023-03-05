// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNFT is ERC721URIStorage, Ownable {
    uint256 private itemID;

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) ERC721(tokenName, tokenSymbol) {
        itemID = 0;
    }

    function mintItem(
        address player,
        string memory itemURI
    ) public onlyOwner returns (uint256) {
        uint256 newItemID = itemID;
        itemID = newItemID + 1;
        _safeMint(player, newItemID);
        _setTokenURI(newItemID, itemURI);

        return newItemID;
    }

    function getCurrentItemID() public view onlyOwner returns (uint256) {
        return itemID;
    }
}
