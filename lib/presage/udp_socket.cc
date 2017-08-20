//	This file defines implementations for the udp_socket
//	class member functions.

#include "udp_socket.hh"

#include <cerrno>
#include <cstring>
#include <stdexcept>

#include <limits.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>


namespace presage {

//	Constructs a udp_socket with the specified block_on_connect.
//	The block_on_connect value determines whether a socket 
//	waits to connect or not and is true by default. Throws
//	an std::runtime_error if a socket cannot be created.
udp_socket::udp_socket(const bool block_on_connect) : ip_socket{protocol::UDP, block_on_connect} {}

//	Moves member values from one udp_socket to another
//	and closes the file descriptor that overwritten.
udp_socket& udp_socket::operator=(udp_socket&& other) noexcept {

	//	Use ip_socket implementation of = operator.
	ip_socket::operator=(std::move(other));
	return *this;
}

//	Sends the specified message to the specified
//	address and port. If true is returned then the
//	message was sent. Throws an std::runtime_error
//	if the message cannot be sent.
bool udp_socket::send_to(const char* address, const uint16_t port, const char* message) const {
	
	//	Get information about the specified address and port.
	auto result{get_address_info(address, port)};
	if (result == NULL)
		return false;
	
	//	Get the size of the message.
	auto message_size{std::strlen(message)};

	//	Send the entire message.
	while (message_size > 0) {

		// Attempt to send the message using the POSIX send function
		// to the specified address and port.
		auto sent{::sendto(file_desc, message, message_size, MSG_NOSIGNAL, result->ai_addr, result->ai_addrlen)};

		//	Return false if the send fails.
		if (sent == -1) {

			//	Free the memory pointed to by result.
			freeaddrinfo(result);
			return false;
		}

		//	Subtract the send characters.
		message_size -= sent;

		//	Move along the pointer to the first unsent character.
		message += sent;
	}

	//	Free the memory pointed to by result.
	freeaddrinfo(result);
	return true;
}

//	Does the same as the above definition of send
//	but takes std::strings.
bool udp_socket::send_to(const std::string& address, const uint16_t port, const std::string& message) const {

	//	Call send using the underlying char array
	//	of address and message.
	return send_to(address.c_str(), port, message.c_str());
}

//	Receives a buffer_size length string from the specified 
//	address and port. Throws an std::runtime_error if the 
//	socket cannot receive any data.
std::string udp_socket::receive(const char* address, const uint16_t port, const std::string::size_type buffer_size) const {

	//	Get information about the specified address and port.
	auto result{get_address_info(address, port)};
	if (result == NULL)
		throw std::runtime_error{gai_strerror(errno)};

	//	Zero initialise a buffer using buffer_size to
	//	store the received characters.
	char buffer[buffer_size + 1] = {};

	//	Attempt to use the POSIX recvfrom function to receive
	//	from the specified address and port.
	if (recvfrom(file_desc, buffer, buffer_size, 0, result->ai_addr, &result->ai_addrlen) == -1) {

	//	Free the memory pointed to by result.
		freeaddrinfo(result);
		throw std::runtime_error{std::strerror(errno)};
	}

	//	Free the memory pointed to by result.
	freeaddrinfo(result);

	//	Construct and return a std::string object with
	//	buffer as the only argument.
	return {buffer};
}

//	Does the same as the above definition of receive
//	but takes an std::string.
std::string udp_socket::receive(const std::string& address, const uint16_t port, const std::string::size_type buffer_size) const {

	//	Call receive using the underlying char array
	//	of address, the port and the buffer_size.
	return receive(address.c_str(), port, buffer_size);
}

//	Does the same as the above definition of receive 
//	but does not remove the received data from the
//	receive queue.
std::string udp_socket::peek(const char* address, const uint16_t port, const std::string::size_type buffer_size) const {

	//	Get information about the specified address and port.
	auto result{get_address_info(address, port)};
	if (result == NULL)
		throw std::runtime_error{gai_strerror(errno)};

	//	store the received characters.
	char buffer[buffer_size + 1] = {};

	//	Attempt to use the POSIX recvfrom function with the
	//	MSG_PEEK flag to receive from the specified address
	//	and port without removing characters from the receive
	//	queue.
	if (recvfrom(file_desc, buffer, buffer_size, MSG_PEEK, result->ai_addr, &result->ai_addrlen) == -1) {

		//	Free the memory pointed to by result.
		freeaddrinfo(result);
		throw std::runtime_error{std::strerror(errno)};
	}

	//	Free the memory pointed to by result.
	freeaddrinfo(result);

	//	Construct and return a std::string object with
	//	buffer as the only argument.
	return {buffer};
}

//	Does the same as the above definition of peek
//	but takes an std::string.
std::string udp_socket::peek(const std::string& address, const uint16_t port, const std::string::size_type buffer_size) const {

	//	Call peek using the underlying char array
	//	of address, the port and the buffer_size.
	return peek(address.c_str(), port, buffer_size);
}

//	Constructs a udp_socket with the specified file
//	descriptor, protocol and block_on_connect value. 
//	The block_on_connect value determines whether a 
//	socket waits to connect or not and is true by
//	default. Throws an std::runtime_error if a socket
//	cannot be created.
udp_socket::udp_socket(const int file_desc, const bool block_on_connect) : ip_socket{file_desc, protocol::UDP, block_on_connect} {}

}
