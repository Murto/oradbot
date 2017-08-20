//	This file declares a base class and it's members
//	for Internet Protocol (IP) sockets.

#ifndef PRESAGE_IP_SOCKET_HH
#define PRESAGE_IP_SOCKET_HH

#include <netdb.h>

#include <bitset>
#include <string>


namespace presage {

//	This class is a simple RAII Internet Protocol (IP)
//	socket wrapper with C++ friendly member function
//	parameters and return types.
class ip_socket {
public:

	//	Type to hold flags for polling.
	using poll_options = std::bitset<2>;

	//	Type that can be manipulated by bitwise operations
	//	and implicitly converted to a poll_options value.
	using poll_option = unsigned long long;

	using poll_duration = decltype(timeval::tv_usec);

	//	This enumerates the different types of
	//	protocol that this implementation supports
	//	with an underlying value that can be
	//	used directly with POSIX functions.
	enum class protocol : int {
		TCP = SOCK_STREAM,
		UDP = SOCK_DGRAM
	};


	//	Constructs an ip_socket with the specified protocol 
	//	and block_on_connect. The block_on_connect value
	//	determines whether a socket waits to connect or not
	//	and is true by default. Throws an std::runtime_error 
	//	if a socket cannot be created.
	ip_socket(const protocol socket_type, const bool block_on_connect = true);

	//	Deleted as copying is not clearly defined.
	ip_socket(const ip_socket&) = delete;

	//	Default move constructor.
	ip_socket(ip_socket&& other) = default;

	//	Closes the file descriptor associated with an
	//	ip_socket.
	virtual ~ip_socket() noexcept;

	//	Moves member values from one ip_socket to another
	//	and closes the file descriptor that overwritten.
	ip_socket& operator=(ip_socket&& other) noexcept;

	//	Binds an ip_socket to a port, allowing other
	//	sockets to send data to it. Returns true if the
	//	socket has been binded.
	bool bind(const uint16_t port) const;

	//	Connects an ip_socket to an address on the
	//	specified port. If true is returned then
	//	the ip_socket is connected and any sends, receives 
	//	or peeks will be to and from the address and port 
	//	until disconnect() is called.
	bool connect(const char* address, const uint16_t port) const;

	//	Does the same as the above definition of connect 
	//	but takes an std::string.
	bool connect(const std::string& address, const uint16_t port) const;

	//	Sends the specified message to the address 
	//	and port that this ip_socket is currently connected 
	//	to. If true is returned then the message was 
	//	sent. Fails if the socket is not connected.
	bool send(const char* message) const noexcept;

	//	Does the same as the above definition of send
	//	but takes an std::string.
	bool send(const std::string& message) const noexcept;

	//	Receives a buffer_size length string from the address
	//	and port that this ip_socket is currently connected to.
	//	Throws an std::runtime_error if the socket cannot
	//	receive any data. Fails if the socket is not connected.
	std::string receive(const std::string::size_type buffer_size) const;

	//	Does the same as the above definition of receive 
	//	but does not remove the received data from the
	//	receive queue.
	std::string peek(const std::string::size_type buffer_size) const;

	//	Waits for one of the operations corresponding to
	//	the options passed to become available. If an
	//	operation being polled becomes available then true
	//	is returned. If duration microseconds are passed without
	//	an operation becoming available then false is returned.
	//	Throws an std::runtime_error if no options are passed
	//	or a socket cannot be polled.
	bool poll(const poll_options& options, const poll_duration duration = 0) const;

	//	Disconnects a previously connected ip_socket. If true
	//	is returned then the scoket has been disconnected.
	//	Fails if the socket was not connected.
	bool disconnect() const noexcept;

	//	Returns the name of the host of an ip_socket 
	//	that can be used to connect to it on the
	//	local network. Fails if the hostname cannot
	//	be resolved.
	std::string get_hostname() const;

	//	Returns the name of the peer that an ip_socket
	//	if connected to. Fails if the peername could
	//	not be resolved.
	std::string get_peername() const;


	//	Polls the send operation when passed to poll.
	constexpr static poll_option POLL_SEND = 0x01;

	//	Polls the receive operation when passed to poll.
	constexpr static poll_option POLL_RECEIVE = 0x02;

	//	Polls the send and receive operations when
	//	passed to poll.
	constexpr static poll_option POLL_ALL = 0x03;

	//	When passed to poll as the duration parameter poll
	//	does not return until an operation becomes available.
	constexpr static poll_duration WAIT_FOREVER = -1;

protected:

	//	Constructs an ip_socket with the specified file
	//	descriptor, protocol and block_on_connect value. 
	//	The block_on_connect value determines whether a 
	//	socket waits to connect or not and is true by
	//	default. Throws an std::runtime_error if a socket
	//	cannot be created.
	ip_socket(const int file_desc, const protocol socket_type, const bool block_on_connect = true);

	//	Handles the fetching of compatible addresses for
	//	an ip_socket. Returns NULL on failure.
	struct addrinfo* get_address_info(const char* address, const uint16_t port) const noexcept;

	//	Stores the protocol that an ip_socket uses.
	protocol socket_type;

	//	Stores the file descriptor associated with an underlying socket.
	int file_desc;
};

}

#endif
