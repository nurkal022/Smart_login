// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EmployeeAuth {
    struct LoginEvent {
        address employee;
        uint256 timestamp;
    }

    address public owner;
    mapping(address => string) private employeeNames;
    address[] private employeeList;
    LoginEvent[] private loginLog;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEmployee(address _addr, string calldata _name) external onlyOwner {
        require(bytes(employeeNames[_addr]).length == 0, "Already exists");
        employeeNames[_addr] = _name;
        employeeList.push(_addr);
    }

    function removeEmployee(address _addr) external onlyOwner {
        require(bytes(employeeNames[_addr]).length > 0, "Not found");
        delete employeeNames[_addr];
        for (uint i = 0; i < employeeList.length; i++) {
            if (employeeList[i] == _addr) {
                employeeList[i] = employeeList[employeeList.length - 1];
                employeeList.pop();
                break;
            }
        }
    }

    function isEmployee(address _addr) external view returns (bool) {
        return bytes(employeeNames[_addr]).length > 0;
    }

    function getEmployeeName(address _addr) external view returns (string memory) {
        return employeeNames[_addr];
    }

    function logLogin(address _addr) external onlyOwner {
        loginLog.push(LoginEvent(_addr, block.timestamp));
    }

    function getLoginHistory() external view returns (LoginEvent[] memory) {
        return loginLog;
    }

    function getEmployeeList() external view returns (address[] memory) {
        return employeeList;
    }
}
