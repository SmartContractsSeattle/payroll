pragma solidity ^0.4.21;

import "./Ownable.sol";

contract Payroll is Ownable {

    uint totalReceived = 0;

    address[] public employees;
    mapping (address => uint) private withdrawnAmounts;
    
    /* Constructor */
    //need the 'payable' keyword to be able to accept money
    function Payroll (address[] allEmployees) payable Ownable() public {
        updateTotalReceived();
        employees = allEmployees;
    }
    
    /*this is the fallback function*/
    function () payable public {
        updateTotalReceived();
    }
    
    //keeping a running tally of how much money has been deposited to the contract
    function updateTotalReceived() internal {
        totalReceived += msg.value;
        
    }
    
    //returns a boolean to ensure only valid addresses are trying to collect pay
    modifier canWithdraw() {
        
        bool contains = false;
        for(uint i = 0; i < employees.length; i++) {
            if (employees[i] == msg.sender) {
                contains = true;
            }
        }
        
        require(contains);
        _;
    }
    
    //the withdrawal function; this instance divides and disburses to a validated address of a requestor
    //but only once
    function withdraw() canWithdraw public {
        //simple equal allocation
        uint amountAllocated = totalReceived/employees.length;
        //keeping track of who's already withdrawn
        uint amountWithdrawn = withdrawnAmounts[msg.sender];
        uint amount = amountAllocated - amountWithdrawn;
        withdrawnAmounts[msg.sender] = amountWithdrawn + amount;
        
        if (amount > 0) {
            msg.sender.transfer(amount);
        
        }
    }
}