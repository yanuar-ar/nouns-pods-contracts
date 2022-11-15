// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import { INounsDescriptorMinimal } from './interfaces/INounsDescriptorMinimal.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';
import './NounsPodsMembers.sol';

contract NounsPods is ERC721, ERC721Enumerable, Ownable {
    event PodsCreated(uint256 indexed podId, INounsSeeder.Seed seed);
    event PodsMembersCreated(uint256 indexed podId, address indexed podsMembers);

    mapping(uint256 => address) public getNounsPodsMembers;
    address[] public allNounsPodsMembers;

    // The Nouns token URI descriptor
    INounsDescriptorMinimal public descriptor;

    // The Nouns token seeder
    INounsSeeder public seeder;

    // The noun seeds
    mapping(uint256 => INounsSeeder.Seed) public seeds;

    // The internal noun ID tracker
    uint256 private _currentPodId;

    constructor(INounsDescriptorMinimal _descriptor, INounsSeeder _seeder) ERC721('Nouns Pods', 'PODS') {
        descriptor = _descriptor;
        seeder = _seeder;
    }

    function mint() public returns (address nounsPodsMembers) {
        uint256 podId = _currentPodId++;

        nounsPodsMembers = address(new NounsPodsMembers(podId, IERC721(address(this)), descriptor, seeder));

        getNounsPodsMembers[podId] = nounsPodsMembers;
        allNounsPodsMembers.push(nounsPodsMembers);
        emit PodsMembersCreated(podId, nounsPodsMembers);

        _mintTo(msg.sender, _currentPodId++);
    }

    function _mintTo(address to, uint256 podId) internal returns (uint256) {
        INounsSeeder.Seed memory seed = seeds[podId] = seeder.generateSeed(podId, descriptor);

        _mint(to, podId);
        emit PodsCreated(podId, seed);

        return podId;
    }

    function tokenURI(uint256 podId) public view override returns (string memory) {
        require(_exists(podId), 'NounsToken: URI query for nonexistent token');
        return descriptor.tokenURI(podId, seeds[podId]);
    }

    function dataURI(uint256 podId) public view returns (string memory) {
        require(_exists(podId), 'NounsToken: URI query for nonexistent token');
        return descriptor.dataURI(podId, seeds[podId]);
    }

    function setDescriptor(INounsDescriptorMinimal _descriptor) external onlyOwner {
        descriptor = _descriptor;
    }

    function setSeeder(INounsSeeder _seeder) external onlyOwner {
        seeder = _seeder;
    }

    function allNounsPodsMembersLength() external view returns (uint256) {
        return allNounsPodsMembers.length;
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
