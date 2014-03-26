require 'rubygems'
require 'net/ssh'

def exec(ssh,instructor)
  ssh.open_channel do |channel|
    channel.request_pty do |ch,success|
      raise "I can't get pty request " unless success
      puts "exec: "+instructor
      ch.exec(instructor)
      ch.on_data do |ch,data|
        checkstr = data.inspect
        if data.inspect.include?"[sudo]" 
          channel.send_data("password\n")
        elsif data.inspect.include?"new UNIX password"
          channel.send_data("password\n")
        elsif data.inspect.include?"[]"
          channel.send_data("\n")
        elsif data.inspect.include?"[Y/n]"
          channel.send_data("y\n")
        elsif data.inspect.include?"[y/N]"
          channel.send_data("y\n")
        else
          puts data.strip
        end
      end
    end
  end
  return true
end

34.times do |i|
  var = "10.255.134.1"+(34+i).to_s
  Net::SSH.start(var,'root',:password=>"Fee02mlLf") do |ssh|
puts var
    #ssh.exec!("sudo sed -i -e \'s/mode manual//\' /var/vcap/monit/job/*.monitrc")
    #puts ssh.exec!("passwd vcap")
exec(ssh,"passwd vcap")

    #exec(ssh,"adduser vcap ")
    #puts ssh.exec!("adduser vcap sudo")
    #exec(ssh,"sudo rm -rf /var/vcap")
  end
end

=begin
File.open("iptables","r+") do |file|
	while line = file.gets
		if(line.strip!="")	
			puts line
		end
	end
end
=end
