pragma solidity ^0.4.21;

import "./Ownable.sol";

contract MonthlyPayroll is Ownable {
                         
    mapping(address => uint) internal _employeeMonthlyPay;
    mapping(address => uint) internal _employeeLastPaymentTime;
    
    function MonthlyPayroll() public Ownable() payable {
        
    }
    
    modifier canWithdraw() {
        require(_employeeMonthlyPay[msg.sender] != 0);
        require(_employeeLastPaymentTime[msg.sender] < (now - 30 days));
        _;
    }

    function getEmployeePay(address _employee) public view returns (uint) {
        require(_employee != address(0));
        return _employeeMonthlyPay[_employee];
    }
    
    function upsertEmployeeMonthlyPay(address[] employees, uint[] ratesInEth) onlyOwner public {
        require(employees.length == ratesInEth.length);
        
        for(uint i = 0; i < employees.length; i++) {
            _employeeMonthlyPay[employees[i]] = ratesInEth[i] * 1 ether;
        }
    }

    function withdrawPay() canWithdraw payable public {
        uint monthlyPay = _employeeMonthlyPay[msg.sender];
        address thisContract = this;
        
        require(thisContract.balance >= monthlyPay);
        _employeeLastPaymentTime[msg.sender] = now;
        
        msg.sender.transfer(monthlyPay);
    }
}