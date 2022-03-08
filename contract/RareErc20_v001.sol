// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
/**
 * @dev Extends standard ERC20 contract from OpenZeppelin
 */

abstract contract RareRhinoNFTs {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function walletOfOwner(address _owner) public view virtual returns (uint256[] memory);
}

contract RareToken is ERC20("Rare", "RARE"), ReentrancyGuard, Ownable {
    
    // state variables (no constructor)
    address private _rrAddress; // Rare Rhinos holders contract address
    
    RareRhinoNFTs rrn;

    // Begin functions
    function setRrAddress(address rrAddress) external onlyOwner {
        require(_nftAddress == address(0), "Already set");
        _nftAddress = nftAddress;
    }

    function payout() external nonReentrant returns (uint256) {
        uint256 totalPayoutQty = 0;

        tokenListV1 = cfd1.walletOfOwner(msg.sender);

        uint256 numTokens = tokenIndices.length

        for (uint256 ii = 0; ii < numTokens; ii++) {
            uint256 tokenIndex = tokenIndices[ii];
            require(ERC721Enumerable(_rrAddress).ownerOf(tokenIndex) == msg.sender, "Sender is not the owner");

            // Make sure there are no duplicate tokens!
            if (ii == 0) {
                for (uint256 jj = 1; jj < numTokens; jj++) {
                    require(tokenIndices[ii] != tokenIndices[jj], "Duplicate token index");
                }
            }                 
            uint256 claimQty = getClaimableFromLastOwed(tokenIndex);
            if (claimQty != 0) {
                totalClaimQty = totalClaimQty + claimQty;
                _lastClaim[tokenIndex] = getTime();
            }
        }

        require(totalClaimQty != 0, "No accumulated SMOKE");
        _mint(_msgSender(), totalClaimQty);
        return totalClaimQty;
    }

    function perToken() internal pure virtual returns (uint256) {
        return 1 ether;
    }

    function claim(uint256 tokenId) external nonReentrant returns (uint256){
        require(ERC721Enumerable(_nftAddress).ownerOf(tokenId) == _msgSender(), "Sender is not the owner");
        uint256 owed = getClaimableFromLastOwed(tokenId);          
        _mint(_msgSender(), owed);
        _lastClaim[tokenId] = getTime();
        return owed;
    }

    /**
        @dev 
        to find owed = total owed since start - claimed tokens  
     */
    function caclulateOwed(uint256 lastClaimed, uint256 totalDays) public pure returns (uint256) {
        uint256 accrued = totalDays - lastClaimed;
        if(accrued >= 1800) {
            return totalEmissions(1800) - totalEmissions(lastClaimed);
        }
        return totalEmissions(totalDays) - totalEmissions(lastClaimed);
    }

    function getTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function getInterval(uint qty) internal pure virtual returns (uint256) {
        return qty * 1 days;
    }

    /**
        @dev 
        10 Smokes a day for 180 days = 1800 (180 days)
        8 Smokes a day for 180 days = 1440 (360 days)
        6 Smokes a day for 180 days = 1080 (540 days)
        4 Smokes a day for 180 days = 720 (720 days)
        2 Smokes a day for 180 days = 360 (900 days) 

        Total = 5400 smoke per dragon
        5400 * 5000 (no. of NFTs) = 27,000,000

        2 smokes a day for 900 more days
        900 * 2 * 5000 = 9,000,000

        36,000,000 total smokes created
     */
    function totalEmissions(uint256 totalDays) public pure returns (uint256) {
        require(totalDays <= 1800, "Exceeds timeline");
        if(totalDays <= 180) return 10 * (totalDays);
        // 10 * 180 + 8 * (totalDays - 180);
        if(totalDays <= 360) return 1800 + 8 * (totalDays - 180);
        // 10 * 180 + 8 * 180 + 6 * (totalDays - 360);
        if(totalDays <= 540) return 3240 + 6 * (totalDays - 360);
        // 10 * 180 + 8 * 180 + 6 * 180 + 4 * (totalDays - 540);
        if(totalDays <= 720) return 4320 + 4 * (totalDays - 540);
        // 10 * 180 + 8 * 180 + 6 * 180 + 4 * 180 + 2 * (totalDays - 720);
        return 5040 + 2 * (totalDays - 720);
    }
}
