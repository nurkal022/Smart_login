// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EmployeeAuth {
    struct LoginEvent {
        address employee;
        uint256 timestamp;
    }

    event EmployeeAdded(address indexed addr, string name);
    event EmployeeRemoved(address indexed addr);
    event LoginRecorded(address indexed addr, uint256 timestamp);

    address public immutable owner;
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
        emit EmployeeAdded(_addr, _name);
    }

    function removeEmployee(address _addr) external onlyOwner {
        require(bytes(employeeNames[_addr]).length > 0, "Not found");
        for (uint i = 0; i < employeeList.length; i++) {
            if (employeeList[i] == _addr) {
                employeeList[i] = employeeList[employeeList.length - 1];
                employeeList.pop();
                break;
            }
        }
        delete employeeNames[_addr];
        emit EmployeeRemoved(_addr);
    }

    function isEmployee(address _addr) external view returns (bool) {
        return bytes(employeeNames[_addr]).length > 0;
    }

    function getEmployeeName(address _addr) external view returns (string memory) {
        return employeeNames[_addr];
    }

    function logLogin(address _addr) external onlyOwner {
        require(bytes(employeeNames[_addr]).length > 0, "Not an employee");
        loginLog.push(LoginEvent(_addr, block.timestamp));
        emit LoginRecorded(_addr, block.timestamp);
    }

    function getLoginHistory() external view returns (LoginEvent[] memory) {
        return loginLog;
    }

    function getEmployeeList() external view returns (address[] memory) {
        return employeeList;
    }
}
