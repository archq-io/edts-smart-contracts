// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title SHA256TimestampStorage
 * @dev Store, retrieve and transfer SHA-256 checksums
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract SHA256TimestampStorage {

    struct Metadata {
        uint timestamp;
        bool claimed;
        bool transferred;
    }

    mapping (address => mapping (bytes32 => Metadata)) public sha256_checksums;
    event Claim(bytes32 sha256_checksum, address claimant, bool claim);

    /**
     * @dev Store checksum and claim it
     * @param sha256_checksum File checksum to store and claim
     */
    function store(bytes32 sha256_checksum) public {
        // Check if this address already stored this checksum
        require(sha256_checksums[msg.sender][sha256_checksum].timestamp == 0);

        sha256_checksums[msg.sender][sha256_checksum].timestamp = block.timestamp;
        sha256_checksums[msg.sender][sha256_checksum].claimed = true;
        sha256_checksums[msg.sender][sha256_checksum].transferred = false;

        emit Claim(sha256_checksum, msg.sender, true);
    }

    /**
     * @dev Transfer a checksum to another Ethereum address
     * @param sha256_checksum File checksum to transfer
     * @param to_address Receiving Ethereum address
     */
    function transfer_claim(bytes32 sha256_checksum, address to_address) public {
        // Check if the claim has already been transferred
        require(!sha256_checksums[msg.sender][sha256_checksum].transferred);

        // Remove claim on timestamp
        if (sha256_checksums[msg.sender][sha256_checksum].claimed) {
            sha256_checksums[msg.sender][sha256_checksum].claimed = false;
            emit Claim(sha256_checksum, msg.sender, false);
        }
        // Remove ability of this address to claim this timestamp
        sha256_checksums[msg.sender][sha256_checksum].transferred = true;

        // Tranfer the ability to claim this timestamp to a new address
        sha256_checksums[to_address][sha256_checksum].timestamp = sha256_checksums[msg.sender][sha256_checksum].timestamp;
        sha256_checksums[to_address][sha256_checksum].claimed = false;
        sha256_checksums[to_address][sha256_checksum].transferred = false;
    }

    /**
     * @dev Claim a checksum transferred to your Ethereum address
     * @param sha256_checksum File checksum to claim
     */
    function set_claim(bytes32 sha256_checksum, bool claim) public {
        // Return if this address did not store this checksum
        require(sha256_checksums[msg.sender][sha256_checksum].timestamp > 0);
        // Check if the claim has already been transferred
        require(!sha256_checksums[msg.sender][sha256_checksum].transferred);

        sha256_checksums[msg.sender][sha256_checksum].claimed = claim;
        emit Claim(sha256_checksum, msg.sender, claim);
    }

    /**
     * @dev Return checksum metadata
     * @param sha256_checksum File checksum to retrieve
     * @return Metadata struct associated with the checksum
     */
    function retrieve(bytes32 sha256_checksum) public view returns (Metadata memory){
        require(sha256_checksums[msg.sender][sha256_checksum].timestamp > 0);
        return sha256_checksums[msg.sender][sha256_checksum];
    }

    /**
     * @dev Return checksum metadata (custom address)
     * @param sha256_checksum File checksum to retrieve
     * @param checksum_address Ethereum address to check
     * @return Metadata struct associated with the checksum
     */
    function retrieve_address(bytes32 sha256_checksum, address checksum_address) public view returns (Metadata memory){
        require(sha256_checksums[checksum_address][sha256_checksum].timestamp > 0);
        return sha256_checksums[checksum_address][sha256_checksum];
    }
}