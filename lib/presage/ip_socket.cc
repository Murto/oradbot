//	This file defines implementations for the ip_socket
//	class member functions.

#include "ip_socket.hh"

#include <fcntl.h>
#include <limits.h>
#include <unistd.h>
#include <sys/socket.h>

#include <cerrno>
#include <cstring>
#include <stdexcept>
#include <type_traits>


namespace presage {

//	Constructs an ip_socket with the specified protocol 
//	and block_on_connect. The block_on_connect value
//	determines whether a socket waits to connect or not
//	and is true by default. Throws an std::runtime_error 
//	if a socket cannot be created.
ip_socket::ip_socket(const protocol socket_type, const bool block_on_connect) : socket_type{socket_type} {

	//	POSIX function call to get file descriptor associated with
	//	a new socket.
	file_desc = socket(AF_INET6, static_cast<std::underlying_type<protocol>::type>(socket_type) | (block_on_connect ? 0 : SOCK_NONBLOCK), 0);

	//	If file_desc is invalid then an error is thrown.
	if (file_desc == -1)
		throw std::runtime_error{std::strerror(errno)};

	//	Set socket to be dual stack instead of IPv6 exclusive.
	int setting{0};
	if (setsockopt(file_desc, IPPROTO_IPV6, IPV6_V6ONLY, &setting, sizeof(setting)))
		throw std::runtime_error{std::strerror(errno)};
}

//	Closes the file descriptor associated with an
//	ip_socket.
ip_socket::~ip_socket() noexcept {

	//	POSIX call to close file descriptor.
	close(file_desc);
}

//	Moves member values from one ip_socket to another
//	and closes the file descriptor that overwritten.
ip_socket& ip_socket::operator=(ip_socket&& other) noexcept {

	//	POSIX function call to close old file descriptor.
	close(file_desc);

	//	Move member values over.
	file_desc = other.file_desc;
	socket_type = other.socket_type;
	return *this;
}

//	Binds an ip_socket to a port, allowing other
//	sockets to send data to it. Returns true if the
//	socket has been binded.
bool ip_socket::bind(const uint16_t port) const {

	//	POSIX struct that is used to store information
	//	about an address.
	struct addrinfo hints = {};
	struct addrinfo* result;

	//	Load the struct with hints so that getaddrinfo
	//	can be used to resolve the address information.

	//	Specify that it is an IPV6 address.
	hints.ai_family = AF_INET6;

	//	Specify the socket protocol.
	hints.ai_socktype = static_cast<std::underlying_type<protocol>::type>(socket_type);

	//	Specify that the address should be filled
	//	in automatically.
	hints.ai_flags = AI_PASSIVE;

	//	Attempt to resolve the address with POSIX
	//	function getaddrinfo.
	if (getaddrinfo(NULL, std::to_string(port).c_str(), &hints, &result))
		return false;

	//	Attempt to bind the socket to the address
	//	pointed to by result.
	auto status{::bind(file_desc, result->ai_addr, result->ai_addrlen)};

	//	Free the memory pointed to by result.
	freeaddrinfo(result);
	return !status;
}

//	Connects an ip_socket to an address on the
//	specified port. If true is returned then
//	the ip_socket is connected and any sends, receives 
//	or peeks will be to and from the address and port 
//	until disconnect() is called.
bool ip_socket::connect(const char* address, const uint16_t port) const {
	
	//	Get information about the specified address and port.
	auto result{get_address_info(address, port)};
	if (result == NULL)
		return false;

	//	Attempt to connect to addresses until one works or the
	//	list of addresses is exhausted.
	for (auto address = result; address != NULL; address = address->ai_next) {

		//	Attempt to connect to the address
		//	pointed to by result.
		if (!::connect(file_desc, address->ai_addr, address->ai_addrlen)) {
	
			//	Free the memory pointed to by result.
			freeaddrinfo(result);
			return true;
		}
	}

	//	Free the memory pointed to by result.
	freeaddrinfo(result);
	return false;
}

//	Does the same as the above definition of connect 
//	but takes an std::string.
bool ip_socket::connect(const std::string& address, const uint16_t port) const {

	//	Call connect using the underlying char array
	//	of address and the port.
	return connect(address.c_str(), port);
}

//	Sends the specified message to the address 
//	and port that this ip_socket is currently connected 
//	to. If true is returned then the message was 
//	sent. Fails if the socket is not connected.
bool ip_socket::send(const char* message) const noexcept {
	
	//	Get the size of the message.
	auto message_size{std::strlen(message)};

	//	Send the entire message.
	while (message_size > 0) {

		// Attempt to send the message using the POSIX send function
		// to the currently connected address.
		auto sent{::send(file_desc, message, message_size, MSG_NOSIGNAL)};

		//	Return false if the send fails.
		if (sent == -1)
			return false;

		//	Subtract the send characters.
		message_size -= sent;

		//	Move along the pointer to the first unsent character.
		message += sent;
	}
	
	return true;
}

//	Does the same as the above definition of send
//	but takes an std::string.
bool ip_socket::send(const std::string& message) const noexcept {
	
	//	Call send using the underlying char array
	//	of message.
	return send(message.c_str());
}

//	Receives a buffer_size length string from the address
//	and port that this ip_socket is currently connected to.
//	Throws an std::runtime_error if the socket cannot
//	receive any data. Fails if the socket is not connected.
std::string ip_socket::receive(const std::string::size_type buffer_size) const {

	//	Zero initialise a buffer using buffer_size to
	//	store the received characters.
	char buffer[buffer_size + 1] = {};

	//	Attempt to use the POSIX recv function to receive
	//	from the currently connected address.
	if (recv(file_desc, buffer, buffer_size, 0) == -1)
		throw std::runtime_error{std::strerror(errno)};

	//	Construct and return a std::string object with
	//	buffer as the only argument.
	return {buffer};
}

//	Does the same as the above definition of receive 
//	but does not remove the received data from the
//	receive queue.
std::string ip_socket::peek(const std::string::size_type buffer_size) const {

	//	Zero initialise a buffer using buffer_size to
	//	store the received characters.
	char buffer[buffer_size + 1] = {};
	
	//	Use the POSIX recv function with the MSG_PEEK
	//	flag to receive from the currently connected
	//	address without removing the characters from the
	//	receive queue.
	if (recv(file_desc, buffer, buffer_size, MSG_PEEK) == -1)
		throw std::runtime_error{std::strerror(errno)};

	//	Construct and return a std::string object with
	//	buffer as the only argument.
	return {buffer};
}

//	Waits for one of the operations corresponding to
//	the options passed to become available. If an
//	operation being polled becomes available then true
//	is returned. If duration microseconds are passed without
//	an operation becoming available then false is returned.
bool ip_socket::poll(const poll_options& options, const poll_duration duration) const {

	//	Fails if no options are passed.
	if (!options.any())
		throw std::runtime_error{"No options selected for polling."};
	
	//	Initialise the timeval struct used for the
	//	poll duration.
	struct timeval time = {};
	time.tv_usec = duration;

	//	fd_set is used to hold file the descriptor
	//	for the POSIX select function.
	fd_set poll_desc;

	//	Zero the fd_set.
	FD_ZERO(&poll_desc);

	//	Add file_desc to the set.
	FD_SET(file_desc, &poll_desc);
	
	//	Attempt to use the POSIX function select to wait
	//	for an operation to be available.
	auto status{select(file_desc + 1, (options[1] ? &poll_desc : NULL), (options[0] ? &poll_desc : NULL), NULL, (duration >= 0 ? &time : NULL))};
	
	//	Fails if select fails.
	if (status == -1)
		throw std::runtime_error{std::strerror(errno)};

	return status;
}

//	Disconnects a previously connected ip_socket. If true
//	is returned then the scoket has been disconnected.
//	Fails if the socket was not connected.
bool ip_socket::disconnect() const noexcept {
	
	//	Attemp to use the POSIX shutdown function to
	//	disallow any further send or receives until
	//	the socket is connected again and return
	//	whether it was successful.
	return !shutdown(file_desc, 2);
}

//	Returns the name of the host of an ip_socket 
//	that can be used to connect to it on the
//	local network. Fails if the hostname cannot
//	be resolved.
std::string ip_socket::get_hostname() const {
	
	//	Initialise an array to store the hostname.
	char hostname[HOST_NAME_MAX + 1] = {};

	//	Attempt to use the POSIX function gethostname
	//	to resolve the hostname associated with the
	//	socket.
	if (gethostname(hostname, HOST_NAME_MAX))
		throw std::runtime_error{std::strerror(errno)};
	
	//	Construct and return an std::string object with
	//	hostname as the only argument.
	return {hostname};
}

//	Returns the name of the peer that an ip_socket
//	if connected to. Fails if the peername could
//	not be resolved.
std::string ip_socket::get_peername() const {

	//	POSIX struct sockaddr_storage is used to
	//	store information about either an IPV4 or
	//	IPV6 compliant socket.
	struct sockaddr_storage address = {};

	//	Get the size of sockaddr_storage.
	socklen_t size{sizeof(struct sockaddr_storage)};

	//	Attempt to use the POSIX function getpeername
	//	to resolve the peername associated with the
	//	socket.
	if (getpeername(file_desc, reinterpret_cast<struct sockaddr*>(&address), &size))
		throw std::runtime_error{std::strerror(errno)};
	
	//	Initialise an array to store the peername.
	char peername[HOST_NAME_MAX + 1] = {};

	//	Attempt to use the POSIX function getnameinfo
	//	to resolve the name associated with the information
	//	stored in address.
	if (getnameinfo(reinterpret_cast<struct sockaddr*>(&address), size, peername, HOST_NAME_MAX, NULL, 0, 0))
		throw std::runtime_error{gai_strerror(errno)};
	

	//	Construct and return an std::string object with
	//	peername as the only argument.
	return {peername};
}

//	Constructs an ip_socket with the specified file
//	descriptor, protocol and block_on_connect value. 
//	The block_on_connect value determines whether a 
//	socket waits to connect or not and is true by
//	default. Throws an std::runtime_error if a socket
//	cannot be created.
ip_socket::ip_socket(const int file_desc, const protocol socket_type, const bool block_on_connect) : file_desc{file_desc}, socket_type{socket_type} {
	
	//	Attempt to get the file descriptor flags to	check
	//	if the file descriptor is valid and for later
	//	setting the appropriate blocking flags.
	auto flags{fcntl(file_desc, F_GETFL)};

	//	Fail if the unable to get the flags.
	if (flags == -1)
		throw std::runtime_error{std::strerror(errno)};

	//	Set the appropriate blocking flags.
	auto new_flags{flags & (block_on_connect ? ~O_NONBLOCK : O_NONBLOCK)};

	//	Attempt to set the new flag if the file descriptor
	//	does not already have it.
	if (flags != new_flags && fcntl(file_desc, F_SETFL, new_flags))
		throw std::runtime_error{std::strerror(errno)};
}

//	Handles the fetching of compatible addresses for
//	an ip_socket. Returns NULL on failure.
struct addrinfo* ip_socket::get_address_info(const char* address, const uint16_t port) const noexcept {
	
	//	POSIX struct that is used to store information
	//	about an address.
	struct addrinfo hints = {};
	struct addrinfo* result;

	//	Specify that the address must be IPv4.
	hints.ai_family = AF_INET6;

	//	Specify the socket protocol.
	hints.ai_socktype = static_cast<std::underlying_type<protocol>::type>(socket_type);

	//	Specify that IPv4 address will be
	//	mapped to IPv6.
	hints.ai_flags = AI_V4MAPPED | AI_ALL;

	//	Attempt to resolve the address with the POSIX
	//	function getaddrinfo and return if successful.
	return (getaddrinfo(address, std::to_string(port).c_str(), &hints, &result) ? NULL : result);
}

}
