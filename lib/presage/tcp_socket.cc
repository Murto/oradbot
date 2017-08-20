//	This file defines implementations for the tcp_socket
//	class member functions.

#include "tcp_socket.hh"

#include <cerrno>
#include <cstring>
#include <stdexcept>

#include <limits.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>


namespace presage {

//	Constructs a tcp_socket with the specified block_on_connect.
//	The block_on_connect value determines whether a socket 
//	waits to connect or not and is true by default. Throws
//	an std::runtime_error if a socket cannot be created.
tcp_socket::tcp_socket(const bool block_on_connect) : ip_socket{protocol::TCP, block_on_connect} {}

//	Moves member values from one tcp_socket to another
//	and closes the file descriptor that overwritten.
tcp_socket& tcp_socket::operator=(tcp_socket&& other) noexcept {

	//	Use ip_socket implementation of = operator.
	ip_socket::operator=(std::move(other));
	return *this;
}

//	Starts listening for connections from other sockets
//	to be accepted later. backlog specifies the number 
//	of incoming connectings that can be queued before
//	they start being rejected.
bool tcp_socket::listen(const unsigned int backlog) const noexcept {

	//	Return result of POSIX function call to listen
	//	for incoming connections.
	return !::listen(file_desc, backlog);
}

//	Accepts a queued or incoming connecting and returns
//	a connected socket for communication. Throws an
//	std::runtime_error if a connection cannot be accepted.
tcp_socket tcp_socket::accept() const {
	
	//	Attempt POSIX function call to accept
	//	a queued or incoming 
	auto peer_file_desc{::accept(file_desc, NULL, NULL)};
	if (peer_file_desc == -1)
		throw std::runtime_error{std::strerror(errno)};
	
	//	Constructs and returns a tcp_socket object with
	//	the peer file descriptor as the only argument.
	return {peer_file_desc};
}

//	Constructs a tcp_socket with the specified file
//	descriptor, protocol and block_on_connect value. 
//	The block_on_connect value determines whether a 
//	socket waits to connect or not and is true by
//	default. Throws an std::runtime_error if a socket
//	cannot be created.
tcp_socket::tcp_socket(const int file_desc, const bool block_on_connect) : ip_socket{file_desc, protocol::TCP, block_on_connect} {}

}
