// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DeFiBeacon
 * @dev Registry of DeFi pools/strategies with metadata and health beacons
 * @notice Allows registering DeFi endpoints and updating simple status beacons
 */
contract DeFiBeacon {
    address public owner;

    struct Pool {
        uint256 id;
        address contractAddress;
        string  name;
        string  protocol;       // e.g. "lending", "dex", "vault"
        string  metadataURI;    // docs, strategy description, risk report
        bool    isActive;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 lastHealthPing; // timestamp of last health update
        bool    healthy;
    }

    uint256 public nextPoolId;

    // poolId => Pool
    mapping(uint256 => Pool) public pools;

    // registrant => poolIds[]
    mapping(address => uint256[]) public poolsOf;

    event PoolRegistered(
        uint256 indexed id,
        address indexed registrant,
        address indexed contractAddress,
        string name,
        string protocol,
        string metadataURI,
        uint256 timestamp
    );

    event PoolUpdated(
        uint256 indexed id,
        string metadataURI,
        bool isActive,
        uint256 timestamp
    );

    event HealthPinged(
        uint256 indexed id,
        bool healthy,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier poolExists(uint256 id) {
        require(pools[id].contractAddress != address(0), "Pool not found");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new DeFi pool or strategy
     */
    function registerPool(
        address contractAddress,
        string calldata name,
        string calldata protocol,
        string calldata metadataURI
    ) external returns (uint256 id) {
        require(contractAddress != address(0), "Zero contract");

        id = nextPoolId++;

        pools[id] = Pool({
            id: id,
            contractAddress: contractAddress,
            name: name,
            protocol: protocol,
            metadataURI: metadataURI,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            lastHealthPing: 0,
            healthy: false
        });

        poolsOf[msg.sender].push(id);

        emit PoolRegistered(
            id,
            msg.sender,
            contractAddress,
            name,
            protocol,
            metadataURI,
            block.timestamp
        );
    }

    /**
     * @dev Update pool metadata and active flag (owner only)
     */
    function updatePool(
        uint256 id,
        string calldata metadataURI,
        bool isActive
    )
        external
        onlyOwner
        poolExists(id)
    {
        Pool storage p = pools[id];
        p.metadataURI = metadataURI;
        p.isActive = isActive;
        p.updatedAt = block.timestamp;

        emit PoolUpdated(id, metadataURI, isActive, block.timestamp);
    }

    /**
     * @dev Health ping from the pool contract itself (or owner) to mark status
     */
    function pingHealth(uint256 id, bool healthy)
        external
        poolExists(id)
    {
        Pool storage p = pools[id];
        require(
            msg.sender == p.contractAddress || msg.sender == owner,
            "Not authorized"
        );

        p.healthy = healthy;
        p.lastHealthPing = block.timestamp;

        emit HealthPinged(id, healthy, block.timestamp);
    }

    /**
     * @dev Get all pool IDs registered by an address
     */
    function getPoolsOf(address registrant)
        external
        view
        returns (uint256[] memory)
    {
        return poolsOf[registrant];
    }

    /**
     * @dev Transfer ownership of beacon registry
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
