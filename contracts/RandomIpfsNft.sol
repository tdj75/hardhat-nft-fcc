// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNft__RangeOutOfBounds();
error RandomIpfsNft__NeedMoreEthSent();
error RandomIpfsNft__WithdrawFailed();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
  string private constant TOKEN_NAME = "Cagnolino";
  string private constant TOKEN_SYMBOL = "DOG";
  uint256 private constant MAX_CHANCE_VALUE = 1000;
  uint256 private s_tokenCounter;
  string[] private s_dogTokenUris;

  enum Breed {
    PUG,
    SHIBA_INU,
    ST_BERNARD
  }

  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  bytes32 private immutable i_keyHash;
  uint64 private immutable i_subscriptionId;
  uint16 private constant REQUEST_CONFIRMATIONS = 3;
  uint32 private immutable i_callbackGasLimit;
  uint32 private constant NUM_WORDS = 1;
  uint256 private immutable i_mintFee;

  mapping(uint256 => address) public s_requestIdToSender;

  event NftRequested(uint256 indexed, address);
  event NftMinted(Breed, address);

  constructor(
    address vrfCoordinatorV2,
    bytes32 keyHash,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    uint256 mintFee
  ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
    s_tokenCounter = 0;
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_keyHash = keyHash;
    i_subscriptionId = subscriptionId;
    i_callbackGasLimit = callbackGasLimit;
    i_mintFee = mintFee;
  }

  function requestNft() public payable returns (uint256 requestId) {
    if (msg.value < i_mintFee) {
      revert RandomIpfsNft__NeedMoreEthSent();
    }
    requestId = i_vrfCoordinator.requestRandomWords(
      i_keyHash,
      i_subscriptionId,
      REQUEST_CONFIRMATIONS,
      i_callbackGasLimit,
      NUM_WORDS
    );
    s_requestIdToSender[requestId] = msg.sender;
    emit NftRequested(requestId, msg.sender);
  }

  function fulfillRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
  ) internal override {
    uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
    Breed dogBreed = getBreedFromModdedRng(moddedRng);

    address dogOwner = s_requestIdToSender[requestId];
    uint256 newTokenId = s_tokenCounter;
    s_tokenCounter = newTokenId + 1;
    _safeMint(dogOwner, newTokenId);
    _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
    emit NftMinted(dogBreed, dogOwner);
  }

  function withdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    (bool success, ) = payable(msg.sender).call{ value: amount }("");
    if (!success) {
      revert RandomIpfsNft__WithdrawFailed();
    }
  }

  function getBreedFromModdedRng(
    uint256 moddedRng
  ) public pure returns (Breed) {
    uint256 cumulativeSum = 0;
    uint256[] memory chanceArray = getChanceArray();
    for (uint256 i = 0; i < chanceArray.length; i++) {
      if (
        moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]
      ) return Breed(i);
      cumulativeSum = cumulativeSum + chanceArray[i];
    }
    revert RandomIpfsNft__RangeOutOfBounds();
  }

  function getChanceArray() public pure returns (uint256[] memory chanceArray) {
    chanceArray[0] = 10;
    chanceArray[1] = 30;
    chanceArray[2] = MAX_CHANCE_VALUE;
  }

  function getMintFee() public view returns (uint256) {
    return i_mintFee;
  }

  function getDogTokenUris(uint256 index) public view returns (string memory) {
    return s_dogTokenUris[index];
  }

  function getTokenCounter() public view returns (uint256) {
    return s_tokenCounter;
  }
}
