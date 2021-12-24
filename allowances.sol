// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./2_Owner.sol";

/* TODO: save to github */
/* TODO: move allownace to a seprate file */
/* TODO: deploy this to testnet and build UI for this */
/* TODO: add ability for owner to change default allowance */
/* TODO: list of all transactions */
/* TODO: for owner ability do display all allownces */

contract Allowance is Owner {
    
    event AllowanceChanged(address indexed _forWho, address indexed _whoChanged, uint oldAllowance, uint _newAllowance);
    uint private defaultAllowance = 3; 
    mapping(address => uint) internal allowances;

     modifier hasWallet() {
        require(allowances[msg.sender] != 0 || msg.sender == owner , "You're not in this wallet.");
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowances[_who], allowances[_who] - _amount);
        allowances[_who] -= _amount;
    }

    function addAddress(address _newAddress) public isOwner {
        /* TODO: only if there is no allowance there */
        allowances[_newAddress] = defaultAllowance;
    }

    function changeAllowance(address _address, uint _newAllowance) public isOwner {
        emit AllowanceChanged(_address, msg.sender, allowances[_address], _newAllowance);
        allowances[_address] = _newAllowance;
    }

    function getAllowance(address _address) public isOwner view returns (uint) {
        return allowances[_address];
    }

}

contract SharedWallet is Allowance {

    event EtherReceived(address indexed _from, uint _amount);
    event EtherWithdrawn(address indexed _beneficiary, uint _amount);

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
            reduceAllowance(msg.sender, _amount);
            emit EtherWithdrawn(msg.sender, _amount);
            payable(msg.sender).transfer(_amount);
        }
        
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }
}
