// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/utils/Counters.sol";
import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/math/SafeMath.sol";

/// @title BRAIN Pass NFT
/// @author Oleanji
/// @notice A pass for IQ Wiki Editors

contract BrainPassCollectibles is ERC721, Ownable {
    /// -----------------------------------------------------------------------
    /// Inheritances
    /// -----------------------------------------------------------------------
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------
    struct Pass {
        uint256 _tokenId;
        string _passType;
        uint256 _startTimestamp;
        uint256 _endTimestamp;
    }

    /// -----------------------------------------------------------------------
    /// Mapping
    /// -----------------------------------------------------------------------
    mapping(address => mapping(uint256 => Pass)) public addressToNFTPass;

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------
    uint public constant MAX_SUPPLY = 3000;
    uint public constant MAX_PER_ADDRESS = 3;
    uint public constant PRICE = 1;

    /// -----------------------------------------------------------------------
    /// Variables
    /// -----------------------------------------------------------------------
    string public baseTokenURI;
    Counters.Counter private _tokenIds;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------
    constructor(string memory baseURI) ERC721("BRAINY EDITOR PASS", "BEP") {
        setBaseURI(baseURI);
    }

    // This function returns the baseURL  of the NFT (i.e the ipfs cid where the json format of all the token data is kept)
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

// This sets the BaseURI in the constructor
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

// This mints the NFT 
    function mintNFT(string memory _passType, uint256 _endTime) public payable {
        require(totalSupply().add(1) <= MAX_SUPPLY, "Max supply reached");
        require(
            balanceOf(msg.sender) < MAX_PER_ADDRESS,
            "Max NFTs per address reached"
        );
        require(msg.value >= PRICE, "Not enough payment token");
        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId);
        uint256 _startTime = block.timestamp;
        Pass memory purchase = Pass(tokenId, _passType, _startTime, _endTime);
        addressToNFTPass[msg.sender][tokenId] = purchase;
        _tokenIds.increment();
        emit BrainPassBought(msg.sender, tokenId, _startTime, _endTime);
    }

    function getPassTime(
        address buyer,
        uint256 tokenId
    ) external view returns (uint256, uint256) {
        Pass memory pass = addressToNFTPass[buyer][tokenId];
        return (pass._startTimestamp, pass._endTimestamp);
    }

    function increasePassTime(
        uint256 tokenId,
        uint256 additionalTime
    ) external {
        require(
            msg.sender == ownerOf(tokenId),
            "You cannot increase the time for an nft you dont own"
        );
        Pass storage pass = addressToNFTPass[ownerOf(tokenId)][tokenId];
        pass._endTimestamp = pass._endTimestamp.add(additionalTime);
        emit TimeIncreased(
            msg.sender,
            tokenId,
            pass._startTimestamp,
            pass._endTimestamp
        );
    }

    function getUserNFTs(address _user) public view returns (uint256[] memory) {
        uint256 userTokenCount = balanceOf(_user);
        uint256[] memory userTokens = new uint256[](userTokenCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalSupply(); i++) {
            if (ownerOf(i) == _user) {
                userTokens[counter] = i;
                counter++;
            }
        }
        return userTokens;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event BrainPassBought(
        address indexed _owner,
        uint _tokenId,
        uint _startTimestamp,
        uint _endTimestamp
    );
    event TimeIncreased(
        address indexed _owner,
        uint _tokenId,
        uint _startTimestamp,
        uint _newEndTimestamp
    );
}
