pragma solidity ^0.8.0;

contract RideSharing {
    // Define variables
    address public owner;
    mapping(address => Driver) public drivers;
    mapping(address => Passenger) public passengers;
    mapping(bytes32 => Ride) public rides;
    bytes32[] public rideIds;

    // Event to trigger when a ride is created
    event RideCreated(bytes32 indexed id, address driver, address passenger, uint cost);

    // Struct to hold information about a driver
    struct Driver {
        string name;
        bool available;
        address[] rides;
    }

    // Struct to hold information about a passenger
    struct Passenger {
        string name;
        address[] rides;
    }

    // Struct to hold information about a ride
    struct Ride {
        address driver;
        address passenger;
        uint cost;
    }

    // Function to register a driver
    function registerDriver(string memory name) public {
        // Create a new driver and add it to the mapping
        drivers[msg.sender].name = name;
        drivers[msg.sender].available = true;
    }

    // Function to register a passenger
    function registerPassenger(string memory name) public {
        // Create a new passenger and add it to the mapping
        passengers[msg.sender].name = name;
    }

    // Function to create a ride
    function createRide(address passenger, uint cost) public {
        // Retrieve the driver from the mapping
        Driver storage driver = drivers[msg.sender];

        // Check if the driver is available
        require(driver.available == true);

        // Create a unique ID for the ride
        bytes32 id = keccak256(abi.encodePacked(passenger, msg.sender, now));

        // Create a new ride and add it to the mapping
        Ride storage newRide = rides[id];
        newRide.driver = msg.sender;
        newRide.passenger = passenger;
        newRide.cost = cost;

        // Add the ride ID to the list of all ride IDs
        rideIds.push(id);

        // Update the driver's availability
        driver.available = false;

        // Add the ride to the driver's rides array
        driver.rides.push(id);

        // Add the ride to the passenger's rides array
        passengers[passenger].rides.push(id);

        // Trigger the RideCreated event
        emit RideCreated(id, msg.sender, passenger, cost);
    }

    // Function to end a ride
    function endRide(bytes32 id) public {
        // Retrieve the ride from the mapping
        Ride storage ride = rides[id];

        // Retrieve the driver from the mapping
        Driver storage driver = drivers[ride.driver];

        // Update the driver's availability
        driver.available = true;

        // Transfer the ride cost to the driver
        ride.driver.transfer(ride.cost);
    }

    // Function to view a ride's information
    function viewRide(bytes32 id) public view returns (address driver, address passenger, uint cost) {
        // Retrieve the ride from the mapping
        Ride storage ride = rides[id];

        // Return the ride's information
        return (ride.driver, ride.passenger, ride.cost);
}
constructor() public {
    owner = msg.sender;
}
}
