# -*- encoding : utf-8 -*-
require 'open3'

namespace :solr do
  task :start do
    stdin, stdout, stderr, wait_thr = Open3.popen3("java -jar winstone.jar --warfile=solr.war --httpPort=8983 --httpListenAddress=127.0.0.1", :chdir => File.join(getwd, 'contrib', 'solr', 'example'))
    stdin.close
    stderr.close
    
    sleep 1
    
    line = ''
    while !line.nil?
      line = stdout.gets
      if line =~ /.*HTTP Listener started: port=8983.*/
        puts "Solr server started successfully"
        break
      end
    end
    
    stdout.close
    Process.detach wait_thr.pid

    File.open(File.join(getwd, 'tmp', 'solr.pid'), 'w') do |f|
      f.puts "#{wait_thr.pid}"
    end
  end
  
  task :stop do
    pid = -1
    pidfile = File.join(getwd, 'tmp', 'solr.pid')
    
    File.open(pidfile) do |f|
      pid = Integer(f.gets)
    end
    
    if pid.nil? || pid == -1
      puts "ERROR: Cannot read Solr PID"
      exit 1
    end
    
    Process.kill('INT', pid)
    File.unlink pidfile
  end
end