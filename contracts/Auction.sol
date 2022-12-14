// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

contract Auction {
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State {
        Started,
        Running,
        Ended,
        Cancelled
    }
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor() {
        owner = payable(msg.sender);
        auctionState = State.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 100;
    }

    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // helper function
    function min(uint a, uint b) internal pure returns (uint) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function cancelAuction() public onlyOwner {
        auctionState = State.Cancelled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]) {
            highestBindingBid = min(
                currentBid + bidIncrement,
                bids[highestBidder]
            );
        } else {
            highestBindingBid = min(
                currentBid,
                bids[highestBidder] + bidIncrement
            );
            highestBidder = payable(msg.sender);
        }
    }

    function finalizedAuction() public {
        require(auctionState == State.Cancelled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        if (auctionState == State.Cancelled) {
            // auction was canceled
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            // auction ended (not canceled)
            if (msg.sender == owner) {
                // this is the owner
                recipient = owner;
                value = highestBindingBid;
            } else {
                // this is a bidder
                if (msg.sender == highestBidder) {
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    // this is neither the owner nor the highestbidder
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        recipient.transfer(value);
    }
}
