// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IOpenseaStorefront {
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) external;
}
