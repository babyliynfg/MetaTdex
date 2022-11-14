// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

uint256 constant PDEC = 1e8;

struct Token {
    address tokenContract;
    string symbol;
    string name;
    uint decimals;
}

library T {

    function USDT() internal pure returns (Token memory)
    {
        return Token({
            symbol: "USDT",
            name: "Binance-Peg BSC-USD",
            tokenContract: 0x55d398326f99059fF775485246999027B3197955,
            decimals: 18
        });
    }

    function ETH() internal pure returns (Token memory)
    {
        return Token({
            symbol: "BNB",
            name: "BNB Token",
            tokenContract: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
            decimals: 18
        });
    }
}
