/**
SPDX-License-Identifier: MIT

@title Staked Relayers Module
@author Harmony Protocol
@notice The Staked Relayers module is responsible for handling the registration and staking of Staked Relayers. It also wraps functions for Staked Relayers to submit Bitcoin block headers to the BTC-Relay.
@dev https://onebtc-dev.web.app/spec/staked-relayers.html
*/

pragma solidity ^0.6.12;

contract stakedRelayers {

    struct StakedRelayer {
        uint256 stake;
    }

    uint STAKED_RELAYER_STAKE;
    mapping(address => StakedRelayer) public stakedRelayer;
    mapping(address => uint256) public theftReports;


    /**
    @notice Emit an event stating that a new staked relayer was registered and provide information on the Staked Relayer's stake
    @param stakedRelayer newly registered staked Relayer
    @param stake stake provided by the staked relayer upon registration
    */
    event RegisterStakedRelayer(
        StakedRelayer stakedRelayer,
        uint256 stake
    );

    /**
    @notice Emit an event stating that a staked relayer has been de-registered
    @param stakedRelayer account identifier of de-registered Staked Relayer
    */
    event DeRegisterStakedRelayer(
        StakedRelayer stakedRelayer
    );

    /**
    @notice Emits an event indicating that a staked relayer has been slashed.
    @param stakedRelayer account identifier of the slashed staked relayer.
    */
    event SlashStakedRelayer(
        StakedRelayer stakedRelayer
    );

    /**
    @notice Emits an event when a vault has been accused of theft.
    @param vault account identifier of the vault accused of theft.
    */
    event ReportVaultTheft(
        address vault
    );

    /**
    * @notice Registers a new Staked Relayer, locking the provided collateral, which must exceed STAKED_RELAYER_STAKE.
    * @param stakedRelayer The account of the staked relayer to be registered.
    * @param stake to-be-locked collateral/stake.
    */
    function registerStakedRelayer(StakedRelayer stakedRelayer, uint256 stake) public {
        /**
        The registerStakedRelayer function takes as input an AccountID and collateral amount (to be used as stake) to register a new staked relayer in the system.

        1. Check that the stakedRelayer is not already in StakedRelayers. Return ERR_ALREADY_REGISTERED if this check fails.
        2. Check that stake > STAKED_RELAYER_STAKE holds, i.e., the staked relayer provided sufficient collateral. Return ERR_INSUFFICIENT_STAKE error if this check fails.
        3. Lock the stake/collateral by calling lockCollateral and passing stakedRelayer and the stake as parameters.
        4. Store the provided information (amount of stake) in a new StakedRelayer and insert it into the StakedRelayers mapping using the stakedRelayer AccountId as key.
        5. Emit a RegisterStakedRelayer(StakedRelayer, collateral) event.

        */
    }

    /**
    * @notice De-registers a Staked Relayer, releasing the associated stake.
    * @param stakedRelayer The account of the staked relayer to be de-registered.
    */
    function deRegisterStakedRelayer(StakedRelayer memory stakedRelayer) public {
        /**
        1. Check if the stakedRelayer is indeed registered in StakedRelayers. Return ERR_NOT_REGISTERED if this check fails.
        2. Release the stake/collateral of the stakedRelayer by calling lockCollateral and passing stakedRelayer and the StakeRelayer.stake (as retrieved from StakedRelayers) as parameters.
        3. Remove the entry from StakedRelayers which has stakedRelayer as key.
        4. Emit a DeRegisterStakedRelayer(StakedRelayer) event.
        */
    }

    /**
    @notice Slashes the stake/collateral of a staked relayer and removes them from the staked relayer list (mapping).
    @param governanceMechanism The AccountId of the Governance Mechanism.
    @param stakedRelayer The account of the staked relayer to be slashed.
    */
    function slashStakedRelayer(uint256 governanceMechanism, StakedRelayer memory stakedRelayer) public {
        /**
        1. Check that the caller of this function is indeed the Governance Mechanism. Return ERR_GOVERNANCE_ONLY if this check fails.
        2. Retrieve the staked relayer with the given account identifier (stakedRelayer) from StakedRelayers. Return ERR_NOT_REGISTERED if not staked relayer with the given identifier can be found.
        3. Confiscate the Staked Relayer's collateral. For this, call slashCollateral providing stakedRelayer and governanceMechanism as parameters.
        4. Remove stakedRelayer from StakedRelayers
        5. Emit SlashStakedRelayer(stakedRelayer) event.
        */
    }

    /**
    @notice A staked relayer reports misbehavior by a vault, providing a fraud proof (malicious Bitcoin transaction and the corresponding transaction inclusion proof).
    @param vault the account of the accused Vault.
    @param merkleProof Merkle tree path (concatenated LE SHA256 hashes).
    @param rawTx Raw Bitcoin transaction including the transaction inputs and outputs.
    */
    function reportVaultTheft(address vault, uint256 merkleProof, uint256 rawTx) public {
        /**
        1. Check that the caller of this function is indeed a Staked Relayer. Return ERR_STAKED_RELAYERS_ONLY if this check fails.
        2. Check if the specified vault exists in Vaults in Vault Registry. Return ERR_VAULT_NOT_FOUND if there is no vault with the specified account identifier.
        3. Check if this vault has already been liquidated. If this is the case, return ERR_ALREADY_LIQUIDATED (no point in duplicate reporting).
        4. Check if the given Bitcoin transaction is already associated with an entry in TheftReports (calculate txId from rawTx as key for lookup). If yes, check if the specified vault is already listed in the associated set of Vaults. If the vault is already in the set, return ERR_ALREADY_REPORTED.
        5. Extract the outputs from rawTx using extractOutputs from the BTC-Relay.
        6. Check if the transaction is a "migration" of UTXOs to the same Vault. For each output, in the extracted outputs, extract the recipient Bitcoin address (using extractOutputAddress from the BTC-Relay).
            6.1. If one of the extracted Bitcoin addresses does not match a Bitcoin address of the accused vault (Vault.wallet) continue to step 7.
            6.2. If all extracted addresses match the Bitcoin addresses of the accused vault (Vault.wallet), abort and return ERR_VALID_MERGE_TRANSACTION.
        7. Check if the transaction is part of a valid Redeem, Replace or Refund process.
            7.1. Extract the OP_RETURN value using extractOPRETURN from the BTC-Relay. If this call returns an error (no valid OP_RETURN output, hence not valid Redeem, Replace or Refund process), continue to step 8.
            7.2. Check if the extracted OP_RETURN value matches any redeemId in RedeemRequest (in RedeemRequests in Redeem), any replaceId in ReplaceRequest (in RedeemRequests in Redeem) or any refundId in RefundRequest (in RefundRequests in Refund) entries associated with this Vault. If no match is found, continue to step 8.
            7.3. Otherwise, if an associated RedeemRequest, ReplaceRequest or RefundRequest was found: extract the value (using extractOutputValue from the BTC-Relay) and recipient Bitcoin address (using extractOutputAddress from the BTC-Relay). Next, check:
                i ) if the value is equal (or greater) than paymentValue in the RedeemRequest, ReplaceRequest or RefundRequest.
                ii ) if the recipient Bitcoin address matches the recipient specified in the RedeemRequest, ReplaceRequest or RefundRequest.
                iii ) if the change Bitcoin address(es) are registered to the accused vault (Vault.wallet).
            If all checks are successful, abort and return ERR_VALID_REDEEM, ERR_VALID_REPLACE or ERR_VALID_REFUND. Otherwise, continue to step 8.
        8. The vault misbehaved (displaced BTC).
            8.1. Call liquidateVault, liquidating the vault and transferring all of its balances and collateral to the LiquidationVault for failure and reimbursement handling;
            8.2. emit ReportVaultTheft(vaultId)
        9. Return
        */
    }
}
