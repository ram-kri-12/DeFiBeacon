// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DeFiBeacon
 * @dev A decentralized beacon for tracking and signaling important DeFi protocol events
 * @notice This contract allows protocols to register, emit signals, and users to track DeFi activities
 */
contract DeFiBeacon {
    
    // Struct to store protocol information
    struct Protocol {
        string name;
        address protocolAddress;
        uint256 registrationTime;
        bool isActive;
        uint256 totalSignals;
    }
    
    // Struct to store signal information
    struct Signal {
        address protocol;
        string eventType;
        string description;
        uint256 timestamp;
        uint256 value;
    }
    
    // State variables
    address public owner;
    uint256 public protocolCount;
    uint256 public signalCount;
    
    // Mappings
    mapping(address => Protocol) public protocols;
    mapping(uint256 => Signal) public signals;
    mapping(address => uint256[]) public protocolSignals;
    
    // Events
    event ProtocolRegistered(address indexed protocolAddress, string name, uint256 timestamp);
    event SignalEmitted(uint256 indexed signalId, address indexed protocol, string eventType, uint256 timestamp);
    event ProtocolStatusUpdated(address indexed protocolAddress, bool isActive);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyRegisteredProtocol() {
        require(protocols[msg.sender].isActive, "Protocol not registered or inactive");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Register a new DeFi protocol to the beacon
     * @param _name Name of the protocol
     * @param _protocolAddress Address of the protocol contract
     */
    function registerProtocol(string memory _name, address _protocolAddress) external {
        require(_protocolAddress != address(0), "Invalid protocol address");
        require(!protocols[_protocolAddress].isActive, "Protocol already registered");
        require(bytes(_name).length > 0, "Protocol name cannot be empty");
        
        protocols[_protocolAddress] = Protocol({
            name: _name,
            protocolAddress: _protocolAddress,
            registrationTime: block.timestamp,
            isActive: true,
            totalSignals: 0
        });
        
        protocolCount++;
        
        emit ProtocolRegistered(_protocolAddress, _name, block.timestamp);
    }
    
    /**
     * @dev Emit a signal/event from a registered protocol
     * @param _eventType Type of event (e.g., "LIQUIDITY_ADDED", "PRICE_UPDATE", "GOVERNANCE_PROPOSAL")
     * @param _description Description of the event
     * @param _value Numerical value associated with the event (optional, can be 0)
     */
    function emitSignal(
        string memory _eventType,
        string memory _description,
        uint256 _value
    ) external onlyRegisteredProtocol returns (uint256) {
        require(bytes(_eventType).length > 0, "Event type cannot be empty");
        
        uint256 signalId = signalCount;
        
        signals[signalId] = Signal({
            protocol: msg.sender,
            eventType: _eventType,
            description: _description,
            timestamp: block.timestamp,
            value: _value
        });
        
        protocolSignals[msg.sender].push(signalId);
        protocols[msg.sender].totalSignals++;
        signalCount++;
        
        emit SignalEmitted(signalId, msg.sender, _eventType, block.timestamp);
        
        return signalId;
    }
    
    /**
     * @dev Query signals by protocol address
     * @param _protocolAddress Address of the protocol
     * @return Array of signal IDs emitted by the protocol
     */
    function getProtocolSignals(address _protocolAddress) external view returns (uint256[] memory) {
        return protocolSignals[_protocolAddress];
    }
    
    /**
     * @dev Get protocol information
     * @param _protocolAddress Address of the protocol
     * @return Protocol struct containing all protocol details
     */
    function getProtocolInfo(address _protocolAddress) external view returns (Protocol memory) {
        return protocols[_protocolAddress];
    }
    
    /**
     * @dev Get signal information by ID
     * @param _signalId ID of the signal
     * @return Signal struct containing all signal details
     */
    function getSignal(uint256 _signalId) external view returns (Signal memory) {
        require(_signalId < signalCount, "Signal does not exist");
        return signals[_signalId];
    }
    
    /**
     * @dev Update protocol status (active/inactive)
     * @param _protocolAddress Address of the protocol
     * @param _isActive New status
     */
    function updateProtocolStatus(address _protocolAddress, bool _isActive) external onlyOwner {
        require(protocols[_protocolAddress].protocolAddress != address(0), "Protocol not found");
        protocols[_protocolAddress].isActive = _isActive;
        
        emit ProtocolStatusUpdated(_protocolAddress, _isActive);
    }
    
    /**
     * @dev Get total number of registered protocols
     * @return Total count of protocols
     */
    function getTotalProtocols() external view returns (uint256) {
        return protocolCount;
    }
    
    /**
     * @dev Get total number of signals emitted
     * @return Total count of signals
     */
    function getTotalSignals() external view returns (uint256) {
        return signalCount;
    }
}
