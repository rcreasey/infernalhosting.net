#!/usr/bin/ruby -w

require 'socket'
require 'resolv'
require 'ipaddr'
require 'yaml'
require 'server/server'

# Module for manage all Whois Class
module Whois

	# Base exception of Whois
    class WhoisException < Exception
    end

	# Exception of Whois who made report a bug
	class WhoisExceptionError < WhoisException
		def initialize (i)
			WhoisException.initialize('Report a bug with error #{i} to http://rubyforge.org/projects/whois/')
		end
	end

    # Class to get all information about Host or IP with the Whois request
    class Whois

		Version = '0.3.0'

        attr_reader :all
        attr_reader :server
        attr_reader :ip
		attr_reader :host
		attr_accessor :host_search

        # Initialize with a request. The request must be an IPv4, or a host string
		#
		# The first params now is :
		#  * a string which a Ipv4 or a host. Ipv6 not implement now
		#  * A IPAddr instance only Ipv4 work now, no Ipv6
		#
		# A second param, host_search is optionnal. By default he is false.
	   	# If this value is true, a resolv host is made for know the host to this IPv4
		def initialize(request, host_search=false)
			@host_search = host_search
			if request.instance_of? IPAddr
				if request.ipv4?
					@ip = request
					@server = server_ipv4
				elsif request.ipv6?
					raise WhoisException.new('not implement now, only Ipv4')
				else
					raise WhoisExceptionError.new(1)
				end
            elsif Resolv::IPv4::Regex =~ request
                ipv4_init request
                unless self.server
                    raise WhoisException.new("no server found for this IPv4 : #{request}")
                end
            elsif Resolv::IPv6::Regex =~ request
				raise WhoisException.new('Ipv6 not implement now')
			else
				# Test if the request is an host or not
				begin
					ip = Resolv.getaddress request
					@ip = IPAddr.new ip
					@server = server_ipv4
					@host = request
				rescue Resolv::ResolvError
					raise WhoisException.new('host #{request} has no DNS result')
				end
            end
			
			#search_host self.ip.to_s
			search_host 
        end
        
        # Ask of whois server
        def search_whois
            s = TCPsocket.open(self.server.server, 43)
            s.write("#{self.ip.to_s}\n")
            ret = ''
            while s.gets do ret += $_ end
            s.close
            @all = ret
        end


		# Search the host for this IPv4, if the value host_search is true, else host = nil
		def search_host
			begin
				if @host_search
					@host = Resolv.getname self.ip.to_s
				else
					@host = nil
				end
			rescue Resolv::ResolvError
				@host = nil
			end
		end
    
	private
    
        # Init value for a ipv4 request
        def ipv4_init (ip)
            @ip = IPAddr.new ip
            @server = server_ipv4
        end
        
        # Define the server of Whois in IPV4 list of YAML
        def server_ipv4
			
			ipv4_list = YAML::load_file(File.dirname(__FILE__) + '/data/ipv4.yaml')
            # Search good Server class for this IP
            ipv4_list.each do |ip, server|
                ip_range = IPAddr.new ip
                if ip_range.include? self.ip
                    return Object.instance_eval("Server::#{server}.new")
                end
            end
        end
    end
end


if $0 == __FILE__

#a = YAML::load_file('data/ipv4.yaml')
#b = a[41]
#b.init

# puts b.server

    w = Whois::Whois.new '41.14.221.147'
    puts w.search_whois

    begin
        w = Whois::Whois.new '42.14.221.147'
        puts w.search_whois
    rescue Whois::WhoisException
        puts 'rescue'
    end

# Test with Apnic Server
    w = Whois::Whois.new '218.14.221.147'
    puts w.search_whois

    w = Whois::Whois.new '61.80.221.147'
    puts w.search_whois

# Test whois Ripe Server
    w = Whois::Whois.new '194.14.221.147'
    puts w.search_whois

# Test whois Arin Server
    w = Whois::Whois.new '216.14.221.147'
    puts w.search_whois

# Test whois Lacnic Server
    w = Whois::Whois.new '200.14.221.147'
    puts w.search_whois

	a = IPAddr.new '200.14.221.147'
    w = Whois::Whois.new(a)
    puts w.search_whois

# ip = Resolv.getname '72.14.221.147'
# puts ip
# 
# ip = Resolv.getaddress 'google.com'
# puts ip
# 
# w = Whois::Whois.new '72.14.221.147'
# puts w.search_whois
# 
    w = Whois::Whois.new 'fg-in-f147.google.com'
    puts w.search_whois

	w = Whois::Whois.new '72.14.221.147', true
    puts w.search_whois
	puts w.host

	puts '#################################'

	w = Whois::Whois.new '72.14.221.147'
    puts w.search_whois
	puts w.host
	
# puts w.all
end
