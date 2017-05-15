pragma solidity ^0.4.2;

import "./Unitoken.sol";


/*
    Contract provides a way to safely exchange various tokens between Alice and Bob

    How to use:
    - Create a contract
    - Both parties verify the terms of the contract
    - Both parties send their tokens to the address of the contract
    - Either side calls the swap() method
    - Parties withdraw their tokens

    Any party may withdraw its tokens at any time before the swap and thereby cancel the deal.
*/
contract AtomicSwap{
    address public AliceAccount;
    address public AliceToken;
    uint256 public AliceMinAmount;

    address public BobAccount;
    address public BobToken;
    uint256 public BobMinAmount;

    bool public swapped = false;


    function AtomicSwap(
        address _AliceAccount,
        address _AliceToken,
        uint256 _AliceMinAmount,
        address _BobAccount,
        address _BobToken,
        uint256 _BobMinAmount){
        AliceAccount = _AliceAccount;
        AliceToken = _AliceToken;
        AliceMinAmount = _AliceMinAmount;
        BobAccount = _BobAccount;
        BobToken = _BobToken;
        BobMinAmount = _BobMinAmount;
    }


    // Interface to deal with tokens
    // This should be redefined to work with other tokens
    // TODO function pointers

    // Return amount of Alice`s tokens that belong to this contract
    function getSelfBalanceAlice() internal returns (uint256){
        var aliceToken = Unitoken(AliceToken);
        return aliceToken.balanceOf(this);
    }

    // Return amount of Bob`s tokens that belong to this contract
    function getSelfBalanceBob() internal returns (uint256){
        var bobToken = Unitoken(BobToken);
        return bobToken.balanceOf(this);
    }

    // Send Alice`s tokens to the given address
    function sendAliceTokens(address _to, uint256 _value) internal{
        var aliceToken = Unitoken(AliceToken);
        aliceToken.transfer(_to, _value);
    }

    // Send Bob`s tokens to the given address
    function sendBobTokens(address _to, uint256 _value) internal{
        var bobToken = Unitoken(BobToken);
        bobToken.transfer(_to, _value);
    }


    // Interface to perform a deal

    function swap() external{
        if (msg.sender != AliceAccount && msg.sender != BobAccount) throw;
        if (swapped){
            return;
        }
        if (getSelfBalanceAlice() >= AliceMinAmount &&
            getSelfBalanceBob() >= BobMinAmount){
            swapped = true;
        }
    }


    // Interface to withdraw tokens

    // Withdraw Alice`s tokens
    function withdrawAliceTokens() external{
        address targetAddress = swapped ? BobAccount : AliceAccount;
        if (msg.sender != targetAddress) throw;
        var balance = getSelfBalanceAlice();
        sendAliceTokens(targetAddress, balance);
    }

    // Withdraw Bob`s tokens
    function withdrawBobTokens() external{
        address targetAddress = swapped ? AliceAccount : BobAccount;
        if (msg.sender != targetAddress) throw;
        var balance = getSelfBalanceBob();
        sendBobTokens(targetAddress, balance);
    }

}
