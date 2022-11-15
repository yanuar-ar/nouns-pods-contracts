// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import { INounsDescriptorMinimal } from './interfaces/INounsDescriptorMinimal.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';

contract NounsPodsMembers is ERC721, ERC721Enumerable {
    event PodsCreated(uint256 indexed podsId, INounsSeeder.Seed seed);

    error NOT_OWNER();
    error IS_PAUSED();

    // The Nouns token URI descriptor
    INounsDescriptorMinimal public descriptor;

    // The Nouns token seeder
    INounsSeeder public seeder;

    IERC721 public nounsPods;

    uint256 public podId;

    bool public paused = false;

    mapping(uint256 => INounsSeeder.Seed) public seeds;

    uint256 private _currentMemberId;

    constructor(
        uint256 _podId,
        IERC721 _nounsPods,
        INounsDescriptorMinimal _descriptor,
        INounsSeeder _seeder
    ) ERC721('Nouns Pods Members', 'PODSM') {
        podId = _podId;
        nounsPods = _nounsPods;
        descriptor = _descriptor;
        seeder = _seeder;
    }

    function mint() public {
        if (paused == true) revert IS_PAUSED();
        _mintTo(msg.sender, _currentMemberId++);
    }

    function _mintTo(address to, uint256 memberId) internal returns (uint256) {
        INounsSeeder.Seed memory seed = seeds[memberId] = seeder.generateSeed(memberId, descriptor);

        _mint(to, memberId);
        emit PodsCreated(memberId, seed);

        return memberId;
    }

    function tokenURI(uint256 memberId) public view override returns (string memory) {
        require(_exists(memberId), 'NounsToken: URI query for nonexistent token');
        return descriptor.tokenURI(memberId, seeds[memberId]);
    }

    function dataURI(uint256 memberId) public view returns (string memory) {
        require(_exists(memberId), 'NounsToken: URI query for nonexistent token');
        return descriptor.dataURI(memberId, seeds[memberId]);
    }

    function setDescriptor(INounsDescriptorMinimal _descriptor) external {
        if (nounsPods.ownerOf(podId) != msg.sender) revert NOT_OWNER();
        descriptor = _descriptor;
    }

    function setSeeder(INounsSeeder _seeder) external {
        if (nounsPods.ownerOf(podId) != msg.sender) revert NOT_OWNER();
        seeder = _seeder;
    }

    function unpause() external {
        if (nounsPods.ownerOf(podId) != msg.sender) revert NOT_OWNER();
        paused = false;
    }

    function pause() external {
        if (nounsPods.ownerOf(podId) != msg.sender) revert NOT_OWNER();
        paused = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
