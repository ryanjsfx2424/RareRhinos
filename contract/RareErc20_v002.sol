// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @dev Extends standard ERC20 contract from OpenZeppelin
 */

abstract contract RareRhinos {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function walletOfOwner(address _owner) public view virtual returns (uint256[] memory);
}

contract RareToken is ERC20("Rare", "RARE"), ReentrancyGuard, Ownable {

    // state variables (no constructor)    
    RareRhinos rrn = RareRhinos( 0x6B93dfB248Fd23b775f36Bff59FAbA423248E65d);

    // We start tracking time from the deployment of this contract    
    uint256 public immutable startTime;

    mapping(uint256 => uint256) private timeLastPaidMap;

    constructor() {
        startTime = block.timestamp;
    }

    function rareUnit() internal pure virtual returns (uint256) {
        return 1 ether;
    }

    // the meat and potatoes function!
    function getPayoutAmount(uint256 tokenId) private returns (uint256) {
        // make sure it's been >= 1 day since last payout
        uint256 now = block.timestamp;
        uint256 timeLastPaid = uint256(timeLastPaidMap[tokenId]);

        if (timeLastPaid == 0) {
            timeLastPaidMap[tokenId] = startTime;
        } else {
            if (now - timeLastPaid < 1 days) {
                return 0;
            } else {
                // this sucks if gas fails farther down the line...
                // but I guess it's better to be safe to avoid double payouts...
                timeLastPaidMap[tokenId] = now;
            }
        }

        // get time since deployed
        uint256 dtDeployed = (now - startTime) / 14 days;

        // payout amount halves every two weeks, diminishing to 1e-18 after two years
        if (dtDeployed < 52) {
            return (rareUnit() / (2**dtDeployed));
        } else {
            return 1;
        }
    }

    function payoutSingle(uint256 tokenId) external nonReentrant returns (uint256) {
        require(msg.sender == rrn.ownerOf(tokenId), "error! msg.sender does not own input token");

        uint256 payoutAmount = getPayoutAmount(tokenId);
        require(payoutAmount > 0, "need to wait 24 hours from last claim");

        _mint(msg.sender, payoutAmount);
        return payoutAmount;
    }

    // sadly payoutSingle isn't visible from here :(
    // on the plus side, that makes it safer from Re-entrancy...
    function payoutAll() external nonReentrant returns (uint256) {
        uint256 totalPayoutAmount;
        uint256 payoutAmount;
        uint256 tokenId;
        uint256[] memory tokenList;
        tokenList = rrn.walletOfOwner(msg.sender);

        for (uint256 ii = 0; ii < tokenList.length; ii++) {
            tokenId = tokenList[ii];
            require(msg.sender == rrn.ownerOf(tokenId), "error! msg.sender does not own input token");

            payoutAmount = getPayoutAmount(tokenId);
            require(payoutAmount > 0, "need to wait 24 hours from last claim");

            _mint(msg.sender, payoutAmount);
            totalPayoutAmount = totalPayoutAmount + payoutAmount;
        }
        return totalPayoutAmount;
    }
}
