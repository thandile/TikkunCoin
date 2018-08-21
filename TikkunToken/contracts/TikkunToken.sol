pragma solidity ^0.4.23;
import "./SafeMath.sol";
import "./ERC621Interface.sol";
import "./Owned.sol";
import "./Oraclize.sol";

// ----------------------------------------------------------------------------
// 'Tikkun' CROWDSALE token contract
//
// Deployed to : 0xd62a88e4941a06bf35eaa19d1f898f45c9db080b
// Symbol      : TKK
// Name        : Tikkun Token
// Total supply: Flexible
// Decimals    : 2
//
// Enjoy.
//
// (c) by Moritz Neto & Daniel Bar with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// ERC621 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract TikkunToken is ERC621Interface, Owned, SafeMath, usingOraclize {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;
    uint256 public interestRate;
    uint public withdrawalDay;
    uint private dailyWithdraw = 5000;
    uint private presentDay = today();
    address public minter;
    

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) interestDue;
    mapping(address => uint) amountSpent;

    string public ETHUSD = "test";
    event ETHUSDUpdated(uint _time, string _newprice, uint gasLeft);
    event LowGasWarning(uint _remainingGas, uint estimateRemainingTime);
    event Withdraw(address _withdrawer, uint _amount);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function TikkunToken() public {
        symbol = "TKK";
        name = "Tikkun Token";
        decimals = 8;
        totalSupply = 0;
        interestRate = 6;
        
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return totalSupply - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // 1000 TKK Tokens per 1 ETH
    // ------------------------------------------------------------------------
    function () public payable {
        uint tokens;
        tokens = msg.value * 1000;
        oraclize_query(3000, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        // FIXME: replace with oralized exchange rate for eth to dollar, then convert to rands
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        emit Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }
    
    function updatePrice() public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            //LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            //LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        }
    }
    
    function __callback(bytes32 myid, string result) public{
        if (msg.sender != oraclize_cbAddress()) revert();
        if(oraclize_getPrice("URL")*288 > this.balance){
            emit LowGasWarning(this.balance, day);
		}
        ETHUSD = result;
        emit ETHUSDUpdated(now,result, this.balance);
    }

    // -----------------------------------------------------------------------
    // when someone buys tokens the number of tokens is increased then 
    // they are transfered to the buyer's address
    // -----------------------------------------------------------------------
    function buyTKK(uint value, address to) public returns (bool) {
        if (msg.sender != owner) return;
        totalSupply = safeAdd(totalSupply, value);
        balances[to] = safeAdd(balances[to], value);
        emit Transfer(address(0), to, value);
        return true;
    }

    // -----------------------------------------------------------------------
    // when someone sells/withdraws tokens the number of tokens is decreased then 
    // they are withdrawn from the buyer's address
    // -----------------------------------------------------------------------
    function sellTKK(uint value) public returns (bool) {
        if (msg.sender != owner) return;
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);  
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC621 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC621Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC621Interface(tokenAddress).transfer(owner, tokens);
    }

    //---------------------------------------------------------------------------
    //Calculating the daily interest that needs to be paid to account holder
    //---------------------------------------------------------------------------
    function calculateInterest(address to ) public returns (uint256 interest) {
        uint256 initBalance = balances[to];
        uint256 interestPayment = initBalance*(1+interestRate)/uint256(36500);
        interestDue[to] = safeAdd(interestDue[to], interestPayment);
        return interestPayment;
    }

    //----------------------------------------------------------------------
    // Pays the interest to account
    // Will implement scheduler for this in java script code
    //----------------------------------------------------------------------
    function payInterest(address to) public returns (uint256 interest){
        balances[to] = safeAdd(balances[to], interestDue[to]);
        clearInterest(to);
        return interestDue[to];
    }

   //----------------------------------------------------------------------
    // Clears interest due once it has been paid to account
    //----------------------------------------------------------------------
    function clearInterest(address to) public returns (uint256 interest){
        interestDue[to] = safeSub(interestDue[to], interestDue[to]);
        return interestDue[to];
    }

    // ------------------------------------------------------------------------
    // Get the interest due for account `tokenOwner`
    // ------------------------------------------------------------------------
    function interestOf(address tokenOwner) public constant returns (uint interest) {
        return interestDue[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Interest rate
    // ------------------------------------------------------------------------
    function interestRate() public constant returns (uint) {
        return interestRate;
    }

    function mint(address _to, uint _tokens) external {
        if (msg.sender != minter) return;
        balances[_to] += _tokens;
    }

    // ------------------------------------------------------------------------
    // Determines today's index at midnight.
    // ------------------------------------------------------------------------
    function today() public constant returns (uint) { return now - (now % 1 days); } 

    // ------------------------------------------------------------------------
    // Withdraws specified tokens from msg.sender's account
    // ------------------------------------------------------------------------
    function withDraw (uint _tokens) public {
        require(isUnderLimit(msg.sender, _tokens), "You have reached your daily withdrawal limit");
        require(_tokens>=0, "Invalid amount");
        require(balances[msg.sender] >= _tokens, "Insufficient funds");
        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);
        totalSupply = safeSub(totalSupply, _tokens);  
        amountSpent[msg.sender] = safeAdd(amountSpent[msg.sender], _tokens);
        emit Withdraw(msg.sender, _tokens);
        withdrawalDay = block.timestamp;
    }

    // ------------------------------------------------------------------------
    // Checks if there is still enough tokens to withdraw within in that day
    // it also resets the amount tokens already withdrawn/spent if it is on a 
    // different day
    // ------------------------------------------------------------------------
    function isUnderLimit(address withdrawer, uint _tokens) internal returns (bool) {
        if (today() > withdrawalDay) {
            withdrawalDay = block.timestamp;
            amountSpent[withdrawer] = 0;
        }
        if (amountSpent[withdrawer] + _tokens <= dailyWithdraw)
            return true;
        return false;
    }
}