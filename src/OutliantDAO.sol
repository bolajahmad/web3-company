// SPDX-License-Identifier: MIT
// This contract is not audited!!!
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "@openzeppelin/contracts/utils/Counters.sol";

// import "hardhat/console.sol";

contract OutliantDAO is ReentrancyGuard {
    address public owner;
    using Counters for Counters.Counter;
    Counters private _beneficiaryCount;

    enum BeneficiaryStatus {
        ACTIVE,
        RETIRED,
        RESIGNED,
        SACKED
    }

    struct Beneficiary {
        address user;
        BeneficiaryStatus status;
    }
    mapping(uint256 => address) allAddedAddress
    mapping(address => Beneficiary) beneficiaries;

    event BeneficiaryAdded(
        address indexed account,
        uint256 indexed totalBeneficiaries
    )

    error UserMustNotExist();

    error TransferFailed();
    error NeedsMoreThanZero();

    // Account -> Token -> Amount
    mapping(address => mapping(address => uint256))
        public s_accountToTokenDeposits;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        _beneficiaryCount.increment();
    }

    

    function deposit(address token, uint256 amount)
        external
        nonReentrant
        moreThanZero(amount)
    {
        emit Deposit(msg.sender, token, amount);
        s_accountToTokenDeposits[msg.sender][token] += amount;
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) revert TransferFailed();
    }
}
