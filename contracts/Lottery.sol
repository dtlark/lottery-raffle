// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Ownable {
  address private _owner;
  
  constructor() {
    _owner = msg.sender;
  }
  
  function owner() public view returns(address) {
    return _owner;
  }
  
  modifier onlyOwner() {
    require(isOwner(),
    "Function accessible only by the owner !!");
    _;
  }
  
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }
}

contract Lottery is VRFConsumerBase, Ownable {
    
    mapping(uint => address) public entries;
    address payable public winner;
    uint256 usdEntryFee;
    uint ticketNum;
    AggregatorV3Interface internal EthUsdPrice;
    enum LOTTO_STATE {
        OPEN,
        CLOSED,
        CALCULATING
    }
    LOTTO_STATE public lottery_state;
    uint256 fee;
    bytes32 public keyHash;

    constructor(address _ethusdpriceAddress, 
                address _vrfCoordinator, 
                address _link,
                uint256 _fee,
                bytes32 _keyHash
                ) public VRFConsumerBase(_vrfCoordinator, _link) {
        usdEntryFee = 50 * (10 ** 18);
        EthUsdPrice = AggregatorV3Interface(_ethusdpriceAddress);
        lottery_state = LOTTO_STATE.CLOSED;
        fee = _fee;
        ticketNum = 0;
        keyHash = _keyHash;
    }

    function enter() public payable {
        require(lottery_state == LOTTO_STATE.OPEN);
        require(msg.value >= getFee(), "Not enough eth!");
        ticketNum += 1;
        entries[ticketNum] = payable(msg.sender);
    }

    function getFee() public view returns(uint256) {
        (, int price, , ,) = EthUsdPrice.latestRoundData();
        uint256 adjusted = uint256(price) * 10 ** 10;
        uint256 costToEnter = (usdEntryFee * 10 ** 18) / adjusted;
        return costToEnter;
    }

    function startLotto() public onlyOwner {
        require(lottery_state == LOTTO_STATE.CLOSED, "Cannot start a new lotto yet!");
        lottery_state = LOTTO_STATE.OPEN;
    }

    function endLotto() public onlyOwner {
        lottery_state = LOTTO_STATE.CALCULATING;
        requestRandomness(keyhash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 _randomness) internal override {
        require(lottery_state == LOTTO_STATE.CALCULATING, "Not yet.");
        require(_randomness > 0, "Not able to get random number!!");
        uint256 indexofWinner = _randomness % ticketNum;
        winner = entries[indexofWinner];
        winner.transfer(address(this).balance);
        entries = new address payable[](0);
        lottery_state = LOTTO_STATE.CLOSED;
    }
}