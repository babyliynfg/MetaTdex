// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./TokenConfig.sol";

interface _erc20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library TokenHelper {
    function get(address _tokenContract) internal view returns (Token memory)
    {
        if (_tokenContract == T.ETH().tokenContract)
        {
            return T.ETH();
        }
        else if (_tokenContract == T.USDT().tokenContract)
        {
            return T.USDT();
        }
        else
        {
            _erc20 erc20 = _erc20(_tokenContract);
            require(erc20.decimals() <= 18, "This decimal is not supported");

            return Token({
                    symbol:erc20.symbol(),
                    name:erc20.name(),
                    tokenContract:_tokenContract,
                    decimals:erc20.decimals()
                });
        }
    }
}

struct TokenMap
{
    mapping(address => Token) data;
    mapping(address => string) tokenIcons;
    address[] keys;
    uint size;
}

library TokenMapHelper {

    function insert(TokenMap storage tokenMap, address __tokenContract) internal returns (bool)
    {
        if (__tokenContract == T.USDT().tokenContract)
            return false;

        if (tokenMap.data[__tokenContract].tokenContract != address(0))
            return false;
        else
        {
            tokenMap.data[__tokenContract] = TokenHelper.get(__tokenContract);

            tokenMap.size++;
            {
                bool added = false;
                for (uint i=0; i<tokenMap.keys.length;i++)
                {
                    if (tokenMap.keys[i] == address(0))
                    {
                        tokenMap.keys[i] = __tokenContract;
                        added = true;
                        break;
                    }
                }
                if (added == false)
                {
                    tokenMap.keys.push(__tokenContract);
                }
            }
            return true;
        }
     }

    function remove(TokenMap storage tokenMap, address __tokenContract) internal returns (bool)
    {
        if (__tokenContract == T.USDT().tokenContract)
            return false;

        if (tokenMap.data[__tokenContract].tokenContract == address(0))
            return false;
        else
        {
            delete tokenMap.data[__tokenContract];
            tokenMap.size--;

            for (uint i=0; i<tokenMap.keys.length; i++)
            {
                if (tokenMap.keys[i] == __tokenContract)
                {
                    tokenMap.keys[i] = address(0);
                }
            }

            while (true)
            {
                if (tokenMap.keys.length == 0)
                    break;
                if (tokenMap.keys[tokenMap.keys.length-1] != address(0))
                    break;
                tokenMap.keys.pop();
            }

            return true;
        }
    }

    function get(TokenMap storage tokenMap, address __tokenContract) internal view returns (Token memory)
    {
        return tokenMap.data[__tokenContract];
    }

    function length(TokenMap storage tokenMap) internal view returns (uint256)
    {
        return tokenMap.keys.length;
    }

    function toList(TokenMap storage tokenMap, uint256 start, uint256 end) internal view returns (address[] memory list)
    {
        end = tokenMap.keys.length >= end ? end : tokenMap.keys.length;
        list = new address[](end-start);
        uint index = 0;
        for (uint256 i=start; i<end; i++)
        {
            list[index] = tokenMap.keys[i];
            index++;
        }
        return list;
    }
}

contract TokenManager {

    // 交易对
    TokenMap tokenMap;

    address private _owner;
    address private _admin;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
    }

    function setAdmin(address __admin) external onlyOwner
    {
        _admin = __admin;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender || _owner == msg.sender, "Ownable: caller is not the admin");
        _;
    }

    function insertToken(address __tokenContract) external onlyAdmin returns (bool)
    {
        return TokenMapHelper.insert(tokenMap, __tokenContract);
    }

    function removeToken(address __tokenContract) external onlyAdmin returns (bool)
    {
        return TokenMapHelper.remove(tokenMap, __tokenContract);
    }

    function getToken(address __tokenContract) external view returns (Token memory token)
    {
        return TokenMapHelper.get(tokenMap, __tokenContract);
    }

    function getTokenMapLength() external view returns (uint length)
    {
        return TokenMapHelper.length(tokenMap);
    }

    function getTokenAddressList(uint256 start, uint256 end) external view returns (address[] memory list)
    {
        return TokenMapHelper.toList(tokenMap, start, end);
    }
    
    function setTokenIconUrl(address __tokenContract, string memory __url) external onlyAdmin
    {
        tokenMap.tokenIcons[__tokenContract] = __url;
    }

    function getTokenIconUrl(address __tokenContract) external view returns (string memory)
    {
        return tokenMap.tokenIcons[__tokenContract];
    }
}







