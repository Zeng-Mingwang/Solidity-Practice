// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CrowdFunding {
    // 受益人
    address public immutable beneficiary;
    uint public immutable fundingGoal;
    mapping (address => uint) funders;
    uint public fundersCount;
    uint public fundingAmount;
    bool public hasDone;

    event Contribute(address contributer, uint amount);
   

    constructor(uint goal) {
        // 设置受益人
        beneficiary = msg.sender;
        fundingGoal = goal;
    }

    function contribute() external payable {
        require(!hasDone,"Funding has Done");
        funders[msg.sender] += msg.value;
        fundersCount++;
        fundingAmount += msg.value;
        if(fundersCount >= fundingGoal){
            hasDone = true;
            payable(beneficiary).transfer(address(this).balance);
        }
        emit Contribute(msg.sender, msg.value);
    }
}