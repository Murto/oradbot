//	This file declares a base class and it's members
//	for TCP Internet Protocol (IP) sockets.

#ifndef PRESAGE_TCP_SOCKET_HH
#define PRESAGE_TCP_SOCKET_HH

#include "ip_socket.hh"

#include <string>


namespace presage {

//	This class is a specialised derivation of
//	ip_socket for TCP Internet Protocol (IP) sockets.
class tcp_socket : public ip_socket {
public:

	//	Constructs a tcp_socket with the specified block_on_connect.
	//	The block_on_connect value determines whether a socket 
	//	waits to connect or not and is true by default. Throws
	//	an std::runtime_error if a socket cannot be created.
	tcp_socket(const bool block_on_connect = true);

	//	Deleted as copying is not clearly defined.
	tcp_socket(const tcp_socket&) = delete;

	//	Default move constructor.
	tcp_socket(tcp_socket&& other) = default;

	//	Default virtual deconstructor.
	virtual ~tcp_socket() = default;

	//	Moves member values from one tcp_socket to another
	//	and closes the file descriptor that overwritten.
	tcp_socket& operator=(tcp_socket&& other) noexcept;

	//	Starts listening for connections from other sockets
	//	to be accepted later. backlog specifies the number 
	//	of incoming connectings that can be queued before
	//	they start being rejected.
	bool listen(const unsigned int backlog) const noexcept;

	//	Accepts a queued or incoming connecting and returns
	//	a connected socket for communication. Throws an
	//	std::runtime_error if a connection cannot be accepted.
	tcp_socket accept() const;

protected:
	
	//	Constructs a tcp_socket with the specified file
	//	descriptor, protocol and block_on_connect value. 
	//	The block_on_connect value determines whether a 
	//	socket waits to connect or not and is true by
	//	default. Throws an std::runtime_error if a socket
	//	cannot be created.
	tcp_socket(const int file_desc, const bool block_on_connect = true);
};

#endif

}
