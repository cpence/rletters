# -*- encoding : utf-8 -*-
require 'socket'
require 'timeout'

module VagrantSshHelper
  def vagrant_ssh(str)
    `vagrant ssh -c "#{str}"`
  end

  def vagrant_check_port_open(port)
    expect(is_port_open?('192.168.111.222', port)).to be_true
  end

  def vagrant_check_port_closed(port)
    expect(is_port_open?('192.168.111.222', port)).to be_false
  end

  private

  # Thanks to http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open
  def is_port_open?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end
end
