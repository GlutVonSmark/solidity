// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./2_Owner.sol";


contract SharedWallet is Owner {

    event Received(address, uint);

    modifier hasWallet() {
        require(allowances[msg.sender] != 0 || msg.sender == owner , "You're not in this wallet.");
        _;
    }
    
    uint private defaultAllowance = 3; 
    mapping(address => uint) private allowances;



    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

 
    function withdraw(uint _amount) public hasWallet payable {
        require(_amount <= getBalance(), "Not enought funds in the wallet");
        

        if (msg.sender == owner) {
            payable(msg.sender).transfer(_amount);
        } else {
            uint allowance = allowances[msg.sender];
            require(_amount <= allowance, "You tried to withdraw more than your allowance");
            payable(msg.sender).transfer(_amount);
        }
        
    }

    /* question...optional parameters? */
    function addAddress(address _newAddress) public isOwner {
        /* for now we dont care if the address is already there */
        allowances[_newAddress] = defaultAllowance;
    }

    function changeAllowance(address _address, uint _newAllowance) public isOwner {
        allowances[_address] = _newAllowance;
    }

    function getAllowance(address _address) public isOwner view returns (uint) {
        return allowances[_address];
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}
