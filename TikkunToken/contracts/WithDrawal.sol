pragma solidity ^0.4.14;

//import "./TikkunToken.sol";

contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// Daily withdrawal limit
contract WithDrawal is SafeMath {
    
    uint private dailyWithdraw = 5000;
    uint private spentToday = 0;
    uint private presentDay = today();
    mapping (address => uint) public balances;
    address public minter;
    
    event Transfer(address from, address to, uint amount);
    //The mint function is used to create the the tokens
    constructor() public {
        minter = msg.sender;
    }

    function mint(address _to, uint _tokens) external {
        if (msg.sender != minter) return;
        balances[_to] += _tokens;
    }
    // This function determines today's index at midnight.
    function today() private constant returns (uint) { return now - (now % 1 days); } 

    // This function is used to withdraw, the _to address is for address[0], _tokens is the amount of tokens to be withdrawn
    function withDrawals ( address _to, uint _tokens) public {
        require(isUnderLimit(_tokens), "You have reached your daily withdrawal limit");
        require(_tokens>=0,"Invalid amount");
        require(balances[msg.sender] >=_tokens,"Insufficient funds");
        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        spentToday = safeAdd(spentToday, _tokens);
        emit Transfer(msg.sender, _to, _tokens);
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
