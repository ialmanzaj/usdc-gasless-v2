// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { Sender } from "../src/Sender.sol";
import { TestUSDC } from "../src/TestUsdc.sol";
import { IEIP3009 } from "../src/utils/IEIP3009.sol";

contract SenderTest is PRBTest, StdCheats {
    Sender gasless_sender;
    TestUSDC usdc;

    address bob;
    address maria = address(2);

    uint256 constant AMOUNT = 10_000_000; // 10 USD
    uint256 constant SENDER_PRIVATE_KEY = 2222;
    uint256 constant FEE = 10;
    uint256 constant initial_suppy = 1e12;
    uint256 deadline = block.timestamp + 60;

    function setUp() public virtual {
        bob = vm.addr(SENDER_PRIVATE_KEY);
        vm.prank(bob);
        usdc = new TestUSDC();
        gasless_sender = new Sender(address(this), address(usdc));
    }

    function _getPermitHash(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _nonce,
        uint256 _deadline
    )
        private
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                usdc.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        _owner,
                        _spender,
                        _value,
                        _nonce,
                        _deadline
                    )
                )
            )
        );
    }
}
