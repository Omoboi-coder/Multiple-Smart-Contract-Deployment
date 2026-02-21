// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SchoolManagement {

    address public admin;
    uint256 public nextStudentId;
    uint256 public nextStaffId;

    mapping(uint256 => Student) public studentsById;
    mapping(uint256 => Staff) public staffById;
    uint256[] public allStudentIds;
    uint256[] public allStaffIds;
    mapping(uint256 => uint256) public feeSchedule;

    struct Student {
        uint256 id;
        address wallet;
        string name;
        uint256 level;
        bool feesPaid;
        uint256 feesPaidAt;
        uint256 registeredAt;
    }

    struct Staff {
        uint256 id;
        address wallet;
        string name;
        uint256 teachingLevel;
        bool isQualified;
        uint256 salary;
        bool salaryPaid;
        uint256 lastPaidAt;
    }

    event StudentRegistered(uint256 studentId, address wallet, string name, uint256 level);
    event FeesPaid(uint256 studentId, uint256 amount, uint256 timestamp);
    event StaffRegistered(uint256 staffId, address wallet, string name);
    event StaffPaid(uint256 staffId, uint256 amount, uint256 timestamp);

    constructor() {
        admin = msg.sender;
        nextStudentId = 1;
        nextStaffId = 1;
        feeSchedule[100] = 0.1 ether;
        feeSchedule[200] = 0.15 ether;
        feeSchedule[300] = 0.2 ether;
        feeSchedule[400] = 0.25 ether;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this");
        _;
    }

    function registerStudent(
        address _wallet,
        string memory _name,
        uint256 _level
    ) public onlyAdmin returns (uint256) {
        require(_wallet != address(0), "Wallet cannot be zero address");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(
            _level == 100 || _level == 200 || _level == 300 || _level == 400,
            "Level must be 100, 200, 300, or 400"
        );

        uint256 newId = nextStudentId;
        nextStudentId++;

        Student memory newStudent = Student({
            id: newId,
            wallet: _wallet,
            name: _name,
            level: _level,
            feesPaid: false,
            feesPaidAt: 0,
            registeredAt: block.timestamp
        });

        studentsById[newId] = newStudent;
        allStudentIds.push(newId);

        emit StudentRegistered(newId, _wallet, _name, _level);
        return newId;
    }

    function payFees(uint256 _studentId) public payable {
        Student storage student = studentsById[_studentId];
        require(student.id != 0, "Student does not exist");
        require(!student.feesPaid, "Fees already paid");
        require(
            msg.value >= feeSchedule[student.level],
            "Insufficient payment for this level"
        );

        student.feesPaid = true;
        student.feesPaidAt = block.timestamp;

        emit FeesPaid(_studentId, msg.value, block.timestamp);
    }

    function registerStaff(
        address _wallet,
        string memory _name,
        uint256 _teachingLevel
    ) public onlyAdmin returns (uint256) {
        require(_wallet != address(0), "Wallet cannot be zero address");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(
            _teachingLevel == 100 || _teachingLevel == 200 || _teachingLevel == 300 || _teachingLevel == 400,
            "Teaching level must be 100, 200, 300, or 400"
        );

        uint256 newId = nextStaffId;
        nextStaffId++;

        uint256 salary = feeSchedule[_teachingLevel] * 2;

        Staff memory newStaff = Staff({
            id: newId,
            wallet: _wallet,
            name: _name,
            teachingLevel: _teachingLevel,
            isQualified: true,
            salary: salary,
            salaryPaid: false,
            lastPaidAt: 0
        });

        staffById[newId] = newStaff;
        allStaffIds.push(newId);

        emit StaffRegistered(newId, _wallet, _name);
        return newId;
    }

    function payStaff(uint256 _staffId) public onlyAdmin {
        Staff storage staff = staffById[_staffId];
        require(staff.id != 0, "Staff does not exist");
        require(!staff.salaryPaid, "Salary already paid");
        require(address(this).balance >= staff.salary, "Contract has insufficient funds");

        (bool success, ) = staff.wallet.call{value: staff.salary}("");
        require(success, "ETH transfer failed");

        staff.salaryPaid = true;
        staff.lastPaidAt = block.timestamp;

        emit StaffPaid(_staffId, staff.salary, block.timestamp);
    }

    function getStudent(uint256 _id) public view returns (
        uint256 id,
        address wallet,
        string memory name,
        uint256 level,
        bool feesPaid,
        uint256 feesPaidAt,
        uint256 registeredAt
    ) {
        Student storage student = studentsById[_id];
        require(student.id != 0, "Student not found");
        return (
            student.id,
            student.wallet,
            student.name,
            student.level,
            student.feesPaid,
            student.feesPaidAt,
            student.registeredAt
        );
    }

    function getAllStudentIds() public view returns (uint256[] memory) {
        return allStudentIds;
    }

    function getStaff(uint256 _id) public view returns (
        uint256 id,
        address wallet,
        string memory name,
        uint256 teachingLevel,
        bool isQualified,
        uint256 salary,
        bool salaryPaid,
        uint256 lastPaidAt
    ) {
        Staff storage staff = staffById[_id];
        require(staff.id != 0, "Staff not found");
        return (
            staff.id,
            staff.wallet,
            staff.name,
            staff.teachingLevel,
            staff.isQualified,
            staff.salary,
            staff.salaryPaid,
            staff.lastPaidAt
        );
    }

    function getAllStaffIds() public view returns (uint256[] memory) {
        return allStaffIds;
    }

    function getFeeForLevel(uint256 _level) public view returns (uint256) {
        return feeSchedule[_level];
    }
}