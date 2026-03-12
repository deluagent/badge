// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Badge
/// @notice Soulbound achievement badges. Non-transferable. Issued by owner.
///         Use case: agent reputation, onchain achievements, proof of work.
contract Badge is ERC721, Ownable {

    struct BadgeType {
        string name;
        string description;
        string imageURI;
        uint256 totalIssued;
    }

    uint256 public nextTypeId;
    uint256 public nextTokenId;

    mapping(uint256 => BadgeType) public badgeTypes;
    mapping(uint256 => uint256) public tokenBadgeType; // tokenId → typeId
    mapping(address => mapping(uint256 => bool)) public hasBadge; // holder → typeId → bool

    event BadgeTypeCreated(uint256 indexed typeId, string name);
    event BadgeIssued(address indexed recipient, uint256 indexed tokenId, uint256 indexed typeId);

    error Soulbound();
    error AlreadyHasBadge();
    error BadgeTypeNotFound();

    constructor(address initialOwner) ERC721("Badge", "BADGE") Ownable(initialOwner) {}

    /// @notice Create a new badge type
    function createBadgeType(
        string calldata name,
        string calldata description,
        string calldata imageURI
    ) external onlyOwner returns (uint256 typeId) {
        typeId = nextTypeId++;
        badgeTypes[typeId] = BadgeType({
            name: name,
            description: description,
            imageURI: imageURI,
            totalIssued: 0
        });
        emit BadgeTypeCreated(typeId, name);
    }

    /// @notice Issue a badge to a recipient
    function issue(address recipient, uint256 typeId) external onlyOwner returns (uint256 tokenId) {
        if (typeId >= nextTypeId) revert BadgeTypeNotFound();
        if (hasBadge[recipient][typeId]) revert AlreadyHasBadge();

        tokenId = nextTokenId++;
        tokenBadgeType[tokenId] = typeId;
        hasBadge[recipient][typeId] = true;
        badgeTypes[typeId].totalIssued++;

        _mint(recipient, tokenId);
        emit BadgeIssued(recipient, tokenId, typeId);
    }

    /// @notice Soulbound — transfers are disabled
    function transferFrom(address, address, uint256) public pure override {
        revert Soulbound();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        uint256 typeId = tokenBadgeType[tokenId];
        return badgeTypes[typeId].imageURI;
    }
}
