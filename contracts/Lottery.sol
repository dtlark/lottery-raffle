// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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

contract Lottery is Ownable {
    
    address payable[] public entries;
    uint256 usdEntryFee;
    AggregatorV3Interface internal EthUsdPrice;
    enum LOTTO_STATE {
        OPEN,
        CLOSED,
        CALCULATING
    }
    LOTTO_STATE public lottery_state;

    constructor(address _ethusdpriceAddress) public {
        usdEntryFee = 50 * (10 ** 18);
        EthUsdPrice = AggregatorV3Interface(_ethusdpriceAddress);
        lottery_state = LOTTO_STATE.CLOSED;
    }

    function enter() public payable {
        require(lottery_state == LOTTO_STATE.OPEN);
        require(msg.value >= getFee(), "Not enough eth!");
        entries.push(payable(msg.sender));
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

    function endLotto() public {

    }
}