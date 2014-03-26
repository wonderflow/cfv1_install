require 'rubygems'
require 'net/ssh'
require 'yaml'

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

cf_yml = YAML::load_file(File.join('config','iptable.yml'))
cf_yml.keys.each do |key|
  if key=='domain' || key == 'LB' || key == 'zkper' then next end
  cf_yml[key].each_with_index do |host,index|
    puts host
    puts host+" added."
  Net::SSH.start(host,'root',:password=>"m7jkAWqd3") do |ssh|
    #puts ssh.exec!("passwd vcap")
    #exec(ssh,"adduser vcap ")
exec(ssh,"passwd vcap")

    #puts ssh.exec!("adduser vcap sudo")
    #exec(ssh,"sudo rm -rf /var/vcap")
  end
  end
end
