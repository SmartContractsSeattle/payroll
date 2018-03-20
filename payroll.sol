pragma solidity ^0.4.15;
contract newPayroll {


    address[] employees = [0x1dD364dB3C0352C8C15df4dC5C42ae7158Cbb39e,
                           0xB77539Cfd9EcAbdc36F5eC8a858f8fB31D7c8d6c,
                           0x575f8DA2ffa0B77B23d647BB5A39739283d49368];

    uint totalReceived = 0;
    mapping (address => uint) withdrawnAmounts;
    
    /* Constructor */
    //need the 'payable' keyword to be able to accept money
    function newPayroll() payable {
        updateTotalReceived();
    }
    
    /*this is the fallback function*/
    function() payable {
        updateTotalReceived();
        
    }
    
    //keeping a running tally of how much money has been deposited to the contract
    function updateTotalReceived() internal {
        totalReceived += msg.value;
        
    }
    
    //returns a boolean to ensure only valid addresses are trying to collect pay
    modifier    canWithdraw() {
        
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
    function withdraw() canWithdraw {
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
