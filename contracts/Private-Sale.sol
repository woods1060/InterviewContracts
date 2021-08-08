// SPDX-License-Identifier: ISC
pragma solidity ^0.8.2;

contract PrivateSale {

    uint256 public constant TICKET_PRICE = 0.01 ether;

    mapping(address => uint256) private purchasedTickets;

    error NotEnoughFundsSent();
    modifier enoughFundsSent(uint256 ticketQuantity) {
        if (msg.value < ticketQuantity * TICKET_PRICE) {
            revert NotEnoughFundsSent();
        }
        _;
    }

    error TicketsWereNotBought();
    modifier ticketsWereBought(uint256 ticketQuantity) {
        if (purchasedTickets[msg.sender] < ticketQuantity) {
            revert TicketsWereNotBought();
        }
        _;
    }

    function buyTickets(uint256 quantity)
        external
        payable
        enoughFundsSent(quantity)
    {
        purchasedTickets[msg.sender] += quantity;
    }

    function getRefund(uint256 quantity)
        external
        payable
        ticketsWereBought(quantity)
    {

        (bool refunded, ) = msg.sender.call{value: quantity * TICKET_PRICE}("");
        require(refunded, "Ticket refund failed");

        unchecked {
            purchasedTickets[msg.sender] -= quantity;
        }
    }

    receive() external payable {}
}
