pragma solidity ^0.4.23;
import "./SafeMath.sol";
import "./ERC621Interface.sol";
import "./Owned.sol";

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
contract TikkunToken is ERC621Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;
    uint256 public interestRate;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) interestDue;


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

    // -----------------------------------------------------------------------
    // when someone buys tokens the number of tokens is increased then 
    // they are transfered to the buyer's address
    // -----------------------------------------------------------------------
    //function buyTKK(uint tokens) public returns(bool){
        //need contact address, represented as 0x0 for now
        //increaseSupply(tokens, msg.sender);
        //transferFrom(0x0, msg.sender, tokens);
        //return true;
    //}

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
        // FIXME: replace with oralized exchange rate for eth to dollar, then convert to rands
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        emit Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }

    function increaseSupply(uint value, address to) public returns (bool) {
        if (msg.sender != owner) return;
        totalSupply = safeAdd(totalSupply, value);
        balances[to] = safeAdd(balances[to], value);
        emit Transfer(address(0), to, value);
        return true;
    }

    function decreaseSupply(uint value) public returns (bool) {
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
    function calculateInterest(address to) public returns (uint256 interest){
        uint256 initBalance = balances[to];
        uint256 interestPayment = (initBalance*interestRate)/uint256(36500);
        return interestPayment;
    }

    function payInterest(address to) public returns (bool success) {
        if (msg.sender != owner) return;
        uint256 interestPayment = calculateInterest(to);
        transferFrom(msg.sender, to, interestPayment);
        return true;
    }

    // ------------------------------------------------------------------------
    // Get the interest due for account `tokenOwner`
    // ------------------------------------------------------------------------
    function interestOf(address tokenOwner) public constant returns (uint interest) {
        return interestDue[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function interestRate() public constant returns (uint) {
        return interestRate;
    }
}