// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

error ERC20InvalidUnderlying(address token);
error AddressBanned(address);
error ERC20ZeroBalance();

import {IERC20, IERC20Metadata, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


    contract MouseTrap is Context, ERC20, Ownable {
    mapping(address => bool) public banAddressList;
    event UpdatedBanStatus(address user, bool banned);
    IERC20 private immutable _underlying;

    constructor(IERC20 underlyingToken) Ownable(msg.sender) ERC20("MouseTrap", unicode"🪤") {
            
        if (underlyingToken == this) {
            revert ERC20InvalidUnderlying(address(this));
        }
        _underlying = underlyingToken;
    }

    function decimals() public view virtual override returns (uint8) {
        try IERC20Metadata(address(_underlying)).decimals() returns (uint8 value) {
            return value;
        } catch {
            return super.decimals();
        }
    }

    function underlying() public view returns (IERC20) {
        return _underlying;
    }


    function wrap(address account, uint256 value) public virtual onlyEligible returns (bool) {
        if (_msgSender() == address(this)) {
            revert ERC20InvalidSender(address(this));
        }
        if (account == address(this)) {
            revert ERC20InvalidReceiver(account);
        }
        SafeERC20.safeTransferFrom(_underlying, _msgSender(), address(this), value);
        _mint(account, value);
        return true;
    }

    function unwrap(address account, uint256 value) public virtual onlyEligible returns (bool) {
        if (account == address(this)) {
            revert ERC20InvalidReceiver(account);
        }
        _burn(_msgSender(), value);
        SafeERC20.safeTransfer(_underlying, account, value);
        return true;
    }

    function _recover(address account) internal virtual returns (uint256) {
        uint256 value = _underlying.balanceOf(address(this)) - totalSupply();
        _mint(account, value);
        return value;
    }

    // This function allows only the owner to recover and mint excess supply from reflections to the contract
    function mouseTrap() external onlyOwner {
		_recover(owner());
	}

    // Return stuck MouseTrap Tokens from the contract
    function gibMouseTrap() external onlyOwner {
        if(balanceOf(address(this)) == 0) {
            revert ERC20ZeroBalance();
        }
        transfer(owner(), balanceOf(address(this)));
    }

    // ERC20 Recover
    function gibToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        if(token.balanceOf(address(this)) == 0) {
            revert ERC20ZeroBalance();
        }
        token.transfer(owner(), token.balanceOf(address(this)));
    }
    
    // Allows the owner to add or remove wallets from the blacklist, uses a boolean "bannedStatus" to flip true/false
    function setAddressBanStatus(address account, bool bannedStatus) external onlyOwner {
        banAddressList[account] = bannedStatus;
        emit UpdatedBanStatus(account, bannedStatus);
    }

    //override transfer function to add check for blacklist
    function transfer(address recipient, uint256 amount) public override onlyEligible returns (bool) {
        //check added to ensure sender is not on blacklist- see "setBotBanStatus" function below
        if(banAddressList[recipient]) {
            revert AddressBanned(recipient);
        }

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    //override transferFrom function to add check for blacklist (allows contract or address to spend on user behalf)
    function transferFrom(address from, address to, uint256 value) public override onlyEligible returns (bool) {
    //check added to ensure sender is not on blacklist- see "setBotBanStatus" function below
    if(banAddressList[to]) {
            revert AddressBanned(to);
        }
    _spendAllowance(from, _msgSender(), value);
    _transfer(from, to, value);
    return true;
    }

    // contract will not accept any ETH
    receive() external payable { 
        revert();
    }

    modifier onlyEligible() {
        if(banAddressList[_msgSender()]) {
            revert AddressBanned(_msgSender());
        }
        _;
    }
}
