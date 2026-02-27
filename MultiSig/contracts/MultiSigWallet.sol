// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.20;

contract MultiSigWallet{

    // event Deposit(address indexed sender, uint amount);
    // event Submit (uint indexed txId);
    // event Approve(address indexed owner, uint indexed txId);
    // event Revoke (address indexed owner, uint indexed txId);
    // event Executed (uint indexed txId);

    
    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;
    // mapping to input the number of transaction and approve anyone by the owner
    mapping(uint => mapping(address => bool )) public approved;

    address[] public owners;
    // mapping to check if owner is true with the address passed in
    mapping(address => bool) public isOwner;

//  number of owners required
    uint public required;

    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
    _;

    }

    modifier txExist(uint _txId){ 
        require (_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notApproved (uint _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted (uint _txId){
        require(!transactions[_txId].executed, "tx already excuted");
        _;
    }


    constructor(address[] memory _owners, uint _required ) {
        require(_owners.length > 0, "owner not up to three yet");
        require(_required > 0 && _required <= _owners.length, 
        "number of required owners not enough");
        for (uint i; i < _owners.length; i++){
            address owner = _owners[i];
            require(owner !=address(0), "you get sense so ?");
            require(!isOwner[owner], "owner is already added");
             isOwner[owner] = true;
             owners.push(owner);
        }
        required = _required;
    }

    function withdrawReq(address _to, uint _value, bytes calldata _data) 
        external onlyOwner{
                transactions.push(Transaction({
                      to : _to,
                      value: _value,
                      data : _data,
                      executed: false
                })) ;  
                
        } 

        function approve(uint _txId) external 
        onlyOwner txExist(_txId) notApproved(_txId) notExecuted(_txId){
                approved[_txId][msg.sender] = true;

        }
 
        function getApprovedCount(uint _txId) private view returns (uint count) {
            for (uint i; i < owners.length; i++){

                if (approved[_txId][owners[i]]){
                    count+=1;
                }
            }
            return count;
        }

        function execute(uint _txId) external txExist(_txId) notExecuted(_txId) {
            require(getApprovedCount(_txId) >= required, "approvals < required");
            Transaction storage transaction = transactions[_txId];
            transaction.executed = true;
            (bool success,)= transaction.to.call{value: transaction.value}(
                transaction.data
            );
            require(success, "tx failed");
        }
        function revoke(uint _txId) external onlyOwner txExist (_txId) notExecuted(_txId){
            require(approved[_txId][msg.sender], "tx not approved");
            approved [_txId][msg.sender] = false;
        }






    receive() external payable {
        (bool success,) = payable(address(this)).call{value: msg.value} ("");
       
    } // emit Deposit(msg.sender, msg.value);
    fallback() external payable{}
}
