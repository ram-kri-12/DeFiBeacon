Struct to store protocol information
    struct Protocol {
        string name;
        address protocolAddress;
        uint256 registrationTime;
        bool isActive;
        uint256 totalSignals;
    }
    
    State variables
    address public owner;
    uint256 public protocolCount;
    uint256 public signalCount;
    
    Events
    event ProtocolRegistered(address indexed protocolAddress, string name, uint256 timestamp);
    event SignalEmitted(uint256 indexed signalId, address indexed protocol, string eventType, uint256 timestamp);
    event ProtocolStatusUpdated(address indexed protocolAddress, bool isActive);
    
    update
// 
// 
update
// 
