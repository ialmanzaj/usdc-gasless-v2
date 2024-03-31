// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { SenderForwarder } from "../src/SenderForwarder.sol";
import { TestUSDC } from "../src/TestUsdc.sol";
import { IEIP3009 } from "../src/utils/IEIP3009.sol";
import { Authorization } from "../src/types/Authorization.sol";

contract SenderForwarderTest is PRBTest, StdCheats {
    SenderForwarder senderForwarder;
    TestUSDC usdc;
    Authorization authorization;

    address bob;
    address maria = address(2);

    uint256 constant AMOUNT = 10_000_000; // 10 USD
    uint256 constant SENDER_PRIVATE_KEY = 2222;
    uint256 constant FEE = 10;
    uint256 constant initial_suppy = 1e12;
    uint256 deadline = block.timestamp + 24 hours;

    function setUp() public virtual {
        bob = vm.addr(SENDER_PRIVATE_KEY);
        usdc = new TestUSDC();
        usdc.mint(bob, initial_suppy);
        senderForwarder = new SenderForwarder(address(this), address(usdc));
    }

    function testSent() public {
        uint256 amountLeft = initial_suppy - AMOUNT;
        bytes32 nonce = vm.parseBytes32("0x0000000000000000000000000000000000000000000000000000000000000001");
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, maria, AMOUNT, 0, deadline, nonce);
        console2.log(deadline);
        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);

        authorization = Authorization(0, deadline, nonce, v, r, s);
        //execute sent
        senderForwarder.send(bob, maria, AMOUNT, authorization);

        //bob balance should be left amount
        assertEq(usdc.balanceOf(bob), amountLeft, "owner balance");
        //maria balance should be amount due from bob
        assertEq(usdc.balanceOf(maria), AMOUNT, "receiver balance");
    }

    function _getPermitHash(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce
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
                        keccak256(
                            "TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
                        ),
                        _from,
                        _to,
                        _value,
                        _validAfter,
                        _validBefore,
                        _nonce
                    )
                )
            )
        );
    }
}
