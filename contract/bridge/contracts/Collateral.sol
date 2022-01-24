// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract ICollateral {
    using SafeMathUpgradeable for uint256;

    event LockCollateral(address sender, uint256 amount);
    event ReleaseCollateral(address sender, uint256 amount);
    event SlashCollateral(address sender, address receiver, uint256 amount);

    mapping(address => uint256) public CollateralBalances;
    mapping(address => uint256) public CollateralUsed; // for vaults

    function totalCollateral() external view returns (uint256) {
        return address(this).balance;
    }

    function _lockCollateral(address sender, uint256 amount) internal virtual {
        require(amount > 0, "Invalid collateral");
        CollateralBalances[sender] = CollateralBalances[sender].add(amount);
        emit LockCollateral(sender, amount);
    }

    function release(
        address sender,
        address to,
        uint256 amount
    ) private {
        require(
            CollateralBalances[sender].sub(CollateralUsed[sender]) >= amount,
            "Insufficient collateral"
        );
        CollateralBalances[sender] = CollateralBalances[sender].sub(amount);
        address payable _to = address(uint160(to));
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Transfer failed.");
    }

    function _releaseCollateral(address sender, uint256 amount) internal virtual {
        release(sender, sender, amount);
        emit ReleaseCollateral(sender, amount);
    }

    function _slashCollateral(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        release(from, to, amount);
        emit SlashCollateral(from, to, amount);
    }

    function _getFreeCollateral(address vaultId)
        internal
        view
        returns (uint256)
    {
        return CollateralBalances[vaultId].sub(CollateralUsed[vaultId]);
    }

    function getTotalCollateral(address vaultId) internal view returns (uint256) {
        return CollateralBalances[vaultId];
    }

    function _useCollateralInc(address vaultId, uint256 amount) internal virtual {
        CollateralUsed[vaultId] = CollateralUsed[vaultId].add(amount);
        require(
            CollateralBalances[vaultId] >= CollateralUsed[vaultId],
            "Insufficient collateral"
        );
    }

    function _useCollateralDec(address vaultId, uint256 amount) internal virtual {
        require(CollateralUsed[vaultId] >= amount, "Insufficient collateral");
        CollateralUsed[vaultId] = CollateralUsed[vaultId].sub(amount);
    }

    uint256[45] private __gap;
}
