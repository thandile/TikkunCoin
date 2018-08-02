pragma solidity ^0.4.14;

import "./TikkunToken.sol";
import "./SafeMath.sol";

// Daily withdrawal limit
contract WithDrawal is TikkunToken, SafeMath {
    
    uint private dailyWithdraw = 5000;
    uint private spentToday = 0;
    uint private presentDay = today();

    // This function determines today's index at midnight.
    function today() private constant returns (uint) { return now - (now % 1 days); } 

    // This function is used to withdraw, the _to address is for address[0], _tokens is the amount of tokens to be withdrawn
    function withDrawals ( address _to, uint _tokens) public {
        require(isUnderLimit(_tokens), "You have reached your daily withdrawal limit");
        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        spentToday = safeAdd(spentToday, _tokens);
    }

    // This function check if there is still enough tokens to withdraw within in that day
    // it also reset the amount tokens already withdrawn/spent if its on a different day
    function isUnderLimit( uint _tokens) internal returns (bool) {
        if (today() > presentDay) {
            presentDay = today();
            spentToday = 0;
        }
        if (spentToday + _tokens <= dailyWithdraw && 
            spentToday + _tokens > spentToday)
            return true;
        return false;
    }
}
