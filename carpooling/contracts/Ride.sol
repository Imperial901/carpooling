// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Carpooling {
    struct Ride {
        address owner;
        string source;
        string destination;
        uint256 availableSeats;
        uint256 departureTime;
        bool booked;
        address bookedBy;
        uint256 fareAmount;
    }

    mapping(uint256 => Ride) public rides;
    uint256 public totalRides;

    event RideCreated(uint256 indexed rideId, address indexed owner, string source, string destination, uint256 availableSeats, uint256 departureTime, uint256 fareAmount);
    event RideBooked(uint256 indexed rideId, address indexed owner, address indexed bookedBy, uint256 fareAmountPaid, uint256 numSeatsBooked);
    event RideCancelled(uint256 indexed rideId, address indexed owner);

    modifier onlyOwner(uint256 _rideId) {
        require(rides[_rideId].owner == msg.sender, "You are not the ride owner");
        _;
    }

    function createRide(string memory _source, string memory _destination, uint256 _availableSeats, uint256 _departureTime, uint256 _fareAmount) external {
        uint256 rideId = totalRides++;
        rides[rideId] = Ride(msg.sender, _source, _destination, _availableSeats, _departureTime, false, address(0), _fareAmount);
        emit RideCreated(rideId, msg.sender, _source, _destination, _availableSeats, _departureTime, _fareAmount);
    }

    function bookRide(uint256 _rideId, uint256 _numSeats) external payable {
        Ride storage ride = rides[_rideId];
        require(ride.owner != address(0), "Ride does not exist");
        require(!ride.booked, "Ride already booked");
        require(_numSeats > 0 && _numSeats <= ride.availableSeats, "Invalid number of seats");
        require(msg.value == ride.fareAmount * _numSeats, "Incorrect fare amount");

        ride.booked = true;
        ride.bookedBy = msg.sender;
        ride.availableSeats -= _numSeats;

        payable(ride.owner).transfer(msg.value);
        emit RideBooked(_rideId, ride.owner, msg.sender, msg.value, _numSeats);
    }

    function cancelRide(uint256 _rideId) external {
        Ride storage ride = rides[_rideId];
        require(ride.booked, "Ride is not booked");
        require(ride.bookedBy == msg.sender, "You did not book this ride");

        // Transfer the fare amount back to the owner of the ride
        // payable(ride.owner).transfer(ride.fareAmount);

        ride.booked = false;
        ride.bookedBy = address(0);
        ride.availableSeats += 1;
        emit RideCancelled(_rideId, ride.owner);
    }

    function getRideDetails(uint256 _rideId) external view returns (address owner, string memory source, string memory destination, uint256 availableSeats, uint256 departureTime, bool booked, address bookedBy, uint256 fareAmount) {
        Ride storage ride = rides[_rideId];
        return (ride.owner, ride.source, ride.destination, ride.availableSeats, ride.departureTime, ride.booked, ride.bookedBy, ride.fareAmount);
    }

    function getAvailableRides() external view returns (uint256[] memory) {
        uint256[] memory availableRidesList = new uint256[](totalRides);
        uint256 availableRidesCount = 0;

        for (uint256 i = 0; i < totalRides; i++) {
            if (!rides[i].booked && rides[i].availableSeats > 0) {
                availableRidesList[availableRidesCount++] = i;
            }
        }

        uint256[] memory result = new uint256[](availableRidesCount);
        for (uint256 i = 0; i < availableRidesCount; i++) {
            result[i] = availableRidesList[i];
        }

        return result;
    }

    function getBookedRides(address _user) external view returns (uint256[] memory) {
        uint256[] memory bookedRidesList = new uint256[](totalRides);
        uint256 bookedRidesCount = 0;

        for (uint256 i = 0; i < totalRides; i++) {
            if (rides[i].booked && rides[i].bookedBy == _user) {
                bookedRidesList[bookedRidesCount++] = i;
            }
        }

        uint256[] memory result = new uint256[](bookedRidesCount);
        for (uint256 i = 0; i < bookedRidesCount; i++) {
            result[i] = bookedRidesList[i];
        }

        return result;
    }
}
