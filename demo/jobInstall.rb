#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby
require 'rubygems'
require 'net/ssh'
require 'net/scp'

thread = []

def sendPassword(session)
  session.open_channel do |channel|
    channel.request_pty do |ch, success|
      raise "I can't get pty request " unless success
      ch.exec "sudo bash tmp.sh"
      ch.on_data do |ch,data|
        data.inspect
        if data.inspect.include?"[sudo]"
          channel.send_data("password\n")
        else 
          puts data.strip
        end
      end
    end
  end
end

def startInstall(ip , job , index)
  Net::SSH.start("#{ip}",'vcap',:password=>"password") do |session|
    puts "started"
    tfile = File.open("tmp.sh","w")
    tfile.puts "cd /home/vcap/vcap/deploy/nise_bosh"
    tfile.puts "/home/vcap/.rbenv/bin/rbenv sudo bundle exec ./bin/nise-bosh -y -f ../cf-release/ ../cf.yml #{job}"
    tfile.close
    session.scp.upload!('tmp.sh','.')
    result = nil
    sendPassword(session)
  end
end



File.open("iptables","r+") do |file|
  while line = file.gets
    if(line.strip!=""&&line.index("#")==nil)
      ip,job,index = line.split(" ")
      print ip+" "+job+" "+index+"\n"
      thread << Thread.new do
        startInstall(ip,job,index)
      end
    end
  end
end


thread.each {|x| x.join}

