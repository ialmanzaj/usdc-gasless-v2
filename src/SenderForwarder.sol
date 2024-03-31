// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { ERC2771Context } from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { IEIP3009 } from "./utils/IEIP3009.sol";
import { Authorization } from "./types/Authorization.sol";

contract SenderForwarder is ERC2771Context {
    IEIP3009 public immutable token;

    error OnlyGelatoRelayERC2771();
    error InvalidSenderAddress();
    error InvalidReceiverAddress();
    error TransferAmountMustBeGreaterThanZero();

    event TokenTransferred(address indexed sender, address indexed receiver, uint256 amount);

    // ERC2771Context: setting the immutable trustedForwarder
    constructor(address trustedForwarder, address _token) ERC2771Context(trustedForwarder) {
        token = IEIP3009(_token);
    }

    function send(address from, address to, uint256 amount, Authorization calldata _authorization) external {
        if (from == address(0)) revert InvalidSenderAddress();
        if (to == address(0)) revert InvalidReceiverAddress();
        if (amount <= 0) revert TransferAmountMustBeGreaterThanZero();

        token.transferWithAuthorization(
            from,
            to,
            amount,
            _authorization.validAfter,
            _authorization.validBefore,
            _authorization.nonce,
            _authorization.v,
            _authorization.r,
            _authorization.s
        );

        emit TokenTransferred(from, to, amount);
    }
}
