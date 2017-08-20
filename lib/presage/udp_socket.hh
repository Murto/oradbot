//	This file declares a base class and it's members
//	for UDP Internet Protocol (IP) sockets.

#ifndef PRESAGE_UDP_SOCKET_HH
#define PRESAGE_UDP_SOCKET_HH

#include "ip_socket.hh"

#include <string>


namespace presage {

//	This class is a specialised derivation of
//	ip_socket for UDP Internet Protocol (IP) sockets.
class udp_socket : public ip_socket {
public:

	//	Constructs a udp_socket with the specified block_on_connect.
	//	The block_on_connect value determines whether a socket 
	//	waits to connect or not and is true by default. Throws
	//	an std::runtime_error if a socket cannot be created.
	udp_socket(const bool block_on_connect = true);

	//	Deleted as copying is not clearly defined.
	udp_socket(const udp_socket&) = delete;

	//	Default move constructor.
	udp_socket(udp_socket&& other) = default;

	//	Default virtual deconstructor.
	virtual ~udp_socket() = default;

	//	Moves member values from one udp_socket to another
	//	and closes the file descriptor that overwritten.
	udp_socket& operator=(udp_socket&& other) noexcept;
	
	//	Sends the specified message to the specified
	//	address and port. If true is returned then the
	//	message was sent. Throws an std::runtime_error
	//	if the message cannot be sent.
	bool send_to(const char* address, const uint16_t port, const char* message) const;

	//	Does the same as the above definition of send
	//	but takes std::strings.
	bool send_to(const std::string& address, const uint16_t port, const std::string& message) const;

	//	Receives a buffer_size length string from the specified 
	//	address and port. Throws an std::runtime_error if the 
	//	socket cannot receive any data.
	std::string receive(const char* address, const uint16_t port, const std::string::size_type buffer_size) const;

	//	Does the same as the above definition of receive
	//	but takes an std::string.
	std::string receive(const std::string& address, const uint16_t port, const std::string::size_type buffer_size) const;

	//	Does the same as the above definition of receive 
	//	but does not remove the received data from the
	//	receive queue.
	std::string peek(const char* address, const uint16_t port, const std::string::size_type buffer_size) const;
	
	//	Does the same as the above definition of peek
	//	but takes an std::string.
	std::string peek(const std::string& address, const uint16_t port, const std::string::size_type buffer_size) const;

private:

	//	Constructs a udp_socket with the specified file
	//	descriptor, protocol and block_on_connect value. 
	//	The block_on_connect value determines whether a 
	//	socket waits to connect or not and is true by
	//	default. Throws an std::runtime_error if a socket
	//	cannot be created.
	udp_socket(const int file_desc, const bool block_on_connect = true);
};

}

#endif
