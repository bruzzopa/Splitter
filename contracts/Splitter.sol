pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Pausable.sol";

contract Splitter is Pausable {
    using SafeMath for uint256;

    event LogSplitterCreated(address indexed owner);
    event LogMakeSplit(address indexed caller, address indexed beneficiary1, address indexed beneficiary2, uint256 amount,  uint256 remainder);
    event LogSplitterWithdraw(address indexed beneficiary, uint256 indexed amount);

    mapping(address => uint256) public balances;

    constructor()  public {
        emit LogSplitterCreated(msg.sender);
    }

    /**
     * Allow any users to make its funds split
     */
    function makeSplit(address first, address second) isWorking public payable {
        require(first != address(0));
        require(second != address(0));
        require(msg.value != 0);

        uint256 remainder = msg.value.mod(2);
        uint256 half = msg.value.sub(remainder).div(2);
        require(half != 0);
        balances[first]      = balances[first].add(half);
        balances[second]     = balances[second].add(half);

        if (remainder != 0) {
          balances[msg.sender] = balances[msg.sender].add(remainder);
        }

        emit LogMakeSplit(msg.sender, first, second, half, remainder);
    }

    /**
     * Allow any users to get its funds
     */
    function withdraw() public isWorking {
        uint256 amount = balances[msg.sender];
        require(amount != 0);

        balances[msg.sender] = 0;

        emit LogSplitterWithdraw(msg.sender, amount);   

        msg.sender.transfer(amount);
    }
}
