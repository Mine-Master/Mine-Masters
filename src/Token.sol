// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoniteToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10 ** 18; // 100 billion tokens
    uint256 public constant LIQUIDITY_ALLOCATION = 10_000_000_000 * 10 ** 18; // 10%
    uint256 public constant TEAM_ALLOCATION = 15_000_000_000 * 10 ** 18; // 15%
    uint256 public constant TREASURY_ALLOCATION = 15_000_000_000 * 10 ** 18; // 15%
    uint256 public constant YIELD_FARMING_ALLOCATION =
        10_000_000_000 * 10 ** 18; // 10%
    uint256 public constant IN_GAME_REWARDS_ALLOCATION =
        50_000_000_000 * 10 ** 18; // 50%

    address public liquidityAddress;
    address public teamAddress;
    address public treasuryAddress;
    address public yieldFarmingAddress;

    uint256 public burnRate = 10; // 10%

    event TokensBurned(address indexed from, uint256 amount);

    constructor(
        address _liquidityAddress,
        address _teamAddress,
        address _treasuryAddress,
        address _yieldFarmingAddress
    ) ERC20("Cryptonite", "CRT") {
        liquidityAddress = _liquidityAddress;
        teamAddress = _teamAddress;
        treasuryAddress = _treasuryAddress;
        yieldFarmingAddress = _yieldFarmingAddress;

        _mint(liquidityAddress, LIQUIDITY_ALLOCATION);
        _mint(teamAddress, TEAM_ALLOCATION);
        _mint(treasuryAddress, TREASURY_ALLOCATION);
        _mint(yieldFarmingAddress, YIELD_FARMING_ALLOCATION);
        _mint(msg.sender, IN_GAME_REWARDS_ALLOCATION);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 burnAmount = (amount * burnRate) / 100;
        uint256 sendAmount = amount - burnAmount;
        _burn(_msgSender(), burnAmount);
        emit TokensBurned(_msgSender(), burnAmount);
        return super.transfer(recipient, sendAmount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 burnAmount = (amount * burnRate) / 100;
        uint256 sendAmount = amount - burnAmount;
        _burn(sender, burnAmount);
        emit TokensBurned(sender, burnAmount);
        return super.transferFrom(sender, recipient, sendAmount);
    }

    function setBurnRate(uint256 newBurnRate) external onlyOwner {
        require(newBurnRate <= 100, "Burn rate cannot exceed 100%");
        burnRate = newBurnRate;
    }
}
