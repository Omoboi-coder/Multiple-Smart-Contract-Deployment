// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract SchoolManagement {
    IERC20 token;
    address admin;

    struct Student {
        address studentAddress;
        uint8 level;
        bool feePaid;
        uint256 paymentTimestamp;
    }

    struct Staff {
        address staffAddress;
        bool salaryPaid;
        bool suspended;
    }

    mapping(uint64 => uint256) public schoolFeesPerLevel;//schoolFeesPerLevel[2]
    mapping(address => Student) public registeredStudents;
    mapping(address => Staff) public registeredStaffs;

    address[] private studentsAddress;
    address[] private staffsAddress;

    event studentRegistered(address indexed student, uint256 indexed feePaid);
    event staffRegistered(address indexed staff);
    event staffPaid(address indexed staff, uint256 indexed amountPaid);
    event studentExpelled(address indexed student);

    constructor(address _token, address _admin) {
        token = IERC20(_token);
        admin = _admin;

        schoolFeesPerLevel[100] = 500;
        schoolFeesPerLevel[200] = 1000;
        schoolFeesPerLevel[300] = 1500;
        schoolFeesPerLevel[400] = 2000;
    }   

    modifier onlyOwner() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    function getAllStudents() external view returns (address[] memory) {
        return studentsAddress;
    }

    function getAllStaff() external view returns (address[] memory) {
        return staffsAddress;
    }

    function registerStudent(uint256 amount, uint8 studentLevel) public payable returns (bool) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance not sufficient");
        require(amount == schoolFeesPerLevel[studentLevel], "Not the fee for level");
        require(!registeredStudents[msg.sender].feePaid, "Student already registered");

        token.transferFrom(msg.sender, address(this), amount);
        Student memory student;

        student.studentAddress = msg.sender;
        student.feePaid = true;
        student.level = studentLevel;
        student.paymentTimestamp = block.timestamp;
        registeredStudents[msg.sender] = student;
        studentsAddress.push(msg.sender);

        emit studentRegistered(msg.sender, amount);

        return true;
    }

    function expelStudent(address student) public onlyOwner returns (bool) {
        require(registeredStudents[student].feePaid, "Student not registered");

        for (uint256 i = 0; i < studentsAddress.length; i++) {
            if (studentsAddress[i] == student) {
                studentsAddress[i] = studentsAddress[studentsAddress.length - 1];
                studentsAddress.pop();
                break;
            }
        }
        delete registeredStudents[student];

        emit studentExpelled(student);

        return true;
    }

    function registerStaff(address _staff) public onlyOwner returns (bool) {
        require(registeredStaffs[_staff].staffAddress == address(0), "already registered");

        Staff memory staff;
        staff.staffAddress = _staff;
        staff.salaryPaid = false;
        registeredStaffs[_staff] = staff;

        emit staffRegistered(_staff);

        return true;
    }

    function suspendStaff(address staff) public onlyOwner returns (bool) {
        require(registeredStaffs[staff].staffAddress != address(0), "Staff not registered");

        registeredStaffs[staff].suspended = true;

        return true;
    }

    function unSuspendStaff(address staff) public onlyOwner returns (bool) {
        require(registeredStaffs[staff].staffAddress != address(0), "Staff not registered");
        require(registeredStaffs[staff].suspended, "Staff not suspended");

        registeredStaffs[staff].suspended = false;

        return true;
    }

    function payStaff(uint256 amount, address staff) public onlyOwner returns (bool) {
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(!registeredStaffs[staff].salaryPaid, "Not eligible for payment");
        require(!registeredStaffs[staff].suspended, "Staff is suspended");

        registeredStaffs[staff].salaryPaid = true;
        token.transfer(staff, amount);

        emit staffPaid(staff, amount);

        return true;
    }

    receive() external payable {}
    fallback() external {}
}