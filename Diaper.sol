// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./SSTORE2.sol";

import "./Base64.sol";
import "./IOpenseaStorefront.sol";

contract Diaper is ERC721("Pixelated Shit (wrapped)", "SHIT"), Ownable, ReentrancyGuard {
    IOpenseaStorefront os = IOpenseaStorefront(0x495f947276749Ce646f68AC8c248420045cb7b5e);

    
    uint256 constant public firstShit = 0x64D471D7B05B2BD4D7430C3E020A7512C158433000000000000010000000001;
    uint256 public lastShit = 0x64D471D7B05B2BD4D7430C3E020A7512C158433000000000000C60000000001;

    mapping(uint256 => uint256) osTokenIdToNewTokenId;
    mapping(uint256 => address) onChainSvgPointers; 
    mapping(uint256 => string) onChainDescription; 

    function wrapDiaper(uint256 tokenId) external {
        require((tokenId >= firstShit && tokenId <= lastShit), "not a shit");

        os.safeTransferFrom(msg.sender, owner(), tokenId, 1, '');
        _safeMint(msg.sender, osTokenIdToNewTokenId[tokenId]);
    }

    //token uri function

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return buildMetadata(_tokenId);
    }

    function buildMetadata(uint256 _tokenId) public view returns(string memory) {
        return string(abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                            '{"name": "Pixelatedshit #" + _tokenId.toString()', 
                            ', "description":"', 
                            onChainDescription[_tokenId],
                            '", "image": "', 
                            string(SSTORE2.read(onChainSvgPointers[_tokenId])),
                            '"}')))));
    }

    // must be called for new Shits. 
    // 1. maps old token id to new token id
    // 2. uploads svg
    // 3. uploadsdescription 
    //individual methods for 1, 2, 3, below as needed.
    function mapTokensAndUploadSVGAndDescription(uint256 osTokenId, uint256 newTokenId, 
                                    string memory svg, string memory description) external onlyOwner {
        osTokenIdToNewTokenId[osTokenId] = newTokenId;
        onChainSvgPointers[newTokenId] = SSTORE2.write(bytes(svg));
        onChainDescription[newTokenId] = description;
    }
    function mapTokens(uint256 osTokenId, uint256 newTokenId) external onlyOwner {
        osTokenIdToNewTokenId[osTokenId] = newTokenId;
    }

    function uploadSvg(uint256 newTokenId, string memory svg) external onlyOwner {
        onChainSvgPointers[newTokenId] = SSTORE2.write(bytes(svg));
    }

    function uploadDescription(uint256 newTokenId, string memory description) external onlyOwner {
        onChainDescription[newTokenId] = description;
    }

    function setLastShit(uint256 _lastShit) external onlyOwner {
        lastShit = _lastShit;
    }

    //for auctions. 
    function mintNewShitToOwner(uint256 tokenId) external onlyOwner {
        _safeMint(msg.sender, tokenId);
    }

}
