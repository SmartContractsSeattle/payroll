pragma solidity ^0.4.21;

import "./MonthlyPayroll.sol";

contract MonthlyPayroll_V2 is MonthlyPayroll {
    function removeEmployee(address _employee) onlyOwner public {
        _employeeMonthlyPay[_employee] = 0;
    }
}