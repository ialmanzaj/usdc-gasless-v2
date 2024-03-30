// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { EIP3009Implementation } from "./utils/EIP3009Implementation.sol";

// A simple ERC20 mock that also implements EIP-3009 and allows gasless transfers
// Fake USDC for testnet and local development.
contract TestUSDC is EIP3009Implementation {
    constructor() ERC20("testUSDC", "USDC") {
        this;
    }

    // USDC has 6 decimals
    function decimals() public pure virtual override returns (uint8) {
        return 6;
    }

    // mint function mints tokens to the specified address
    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
