// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IVesting {
    //getters
    function beneficiary() external view returns(address);

    function cliff() external view returns(uint256);

    function start() external view returns(uint256);

    function duration() external view returns(uint256);

    function revocable() external view returns(bool);

    //setters
    function released(address token) external returns(uint256);

    function revocked(address token) external returns(bool);

    function release(contract IERC20 token) external;

    function revoke(contract IERC20 token) external;

    //Events
    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

}
