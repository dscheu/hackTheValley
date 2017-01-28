pragma solidity ^0.4.4;

// virtual "dapple" package imported when `dapple test` is run
import 'dapple/test.sol';
import 'parking.sol';

// Deriving from `Test` marks the contract as a test and gives you access to various test helpers.
contract ParkingTest is Test {
    Parking parking;
    Tester proxy_tester;
    // The function called "setUp" with no arguments is
    // called on a fresh instance of this contract before
    // each test.
    function setUp() {
        parking = new Parking();
        proxy_tester = new Tester();
        proxy_tester._target(parking);
    }
    
    function testEmptyContractZeroSlots() logs_gas() {
        assertEq( parking.getSlotsNumber(), 0);
    }

    function testProvideSlotOneSlot() logs_gas() {
        parking.provideSlot(1, 123, "desc", 0, 0, "bluetoothName");
        assertEq( parking.getSlotsNumber(), 1);
        var ( slotId, pricePerMinute, descr, xCoord, yCoord, available, bluetoothName ) = parking.getEntry(0);
        assertEq( slotId, uint(1));
        assertEq( pricePerMinute, uint(123));
        assertEq( xCoord, uint(0));
        assertEq( yCoord, uint(0));
        assertEq( available, bool(true));
    }

    function testFailProvideSlotWithSameIdTwice() logs_gas() {
        parking.provideSlot(1, 123, "desc", 0, 0, "bluetoothName");
        parking.provideSlot(1, 234, "otherDesc", 1, 1, "bluetoothName2");        
    }

    function testDeleteSlotNoMoreSlotsPresent() logs_gas() {
        parking.provideSlot(1, 123, "desc", 0, 0, "btn");
        parking.provideSlot(2, 123, "desc", 0, 0, "btn");
        parking.deleteSlot(1);
        assertEq( parking.getSlotsNumber(), 1);
        parking.deleteSlot(2);
        assertEq( parking.getSlotsNumber(), 0);
    }

    function testNoAccess() logs_gas() {
        parking.provideSlot(1, 123, "desc", 0, 0, "bluetoothName");
        assertEq( parking.hasAccess(1, 0x123), false);
    }

    function testReserveSlotAccess() logs_gas() {
        parking.provideSlot(1, 10, "desc", 0, 0, "bluetoothName");
        parking.reservateSlot.value(600).gas(400000)(1,60);
        assertEq( parking.hasAccess(1, 0x123), false);
        assertEq( parking.hasAccess(1, address(this)), true);
    }

    function testReserveSlotAccessWithInsufficientFunds() logs_gas() {
        parking.provideSlot(1, 10, "desc", 0, 0, "bluetoothName");
        //Only send 1 wei, must be at least (10*60) wei
        parking.reservateSlot.value(1).gas(400000)(1,60);
        
        //TODO: Verify that enough ETHER was submitted for the entire duration
        //assertEq( parking.hasAccess(1, address(this)), false);
    }
}