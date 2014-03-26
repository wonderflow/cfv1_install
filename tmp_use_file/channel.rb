#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'net/ssh'
require 'net/scp'
class ChannelTest

  def initialize(host)
    @host = host
    @x = true
  end

  def exec(ssh,ins)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec(ins)
        ch.on_data do |ch,data|
          if data.inspect.include?"[sudo]"; channel.send_data("password\n")
          else ; puts data.strip ; end
          
        end
        ch.on_close do
          @x = false
        end
      end
    end
  end

  def connect(host,user,password)
    Net::SSH.start(host,user,:password=>password) do |ssh|
      puts "Examing "+host
      #ins = []
      #ins << "sudo /var/vcap/bosh/bin/monit "
      ins  = "sleep 5 | echo 'xx'"

      exec(ssh,ins)
      while @x
        sleep 1
      end
      puts host+"Examined"
      puts "its over!"
    end
  end

  def work()
    begin
      connect(@host,"vcap","password")
    end while @x==false
  end

end

ChannelTest.new('10.10.102.84').work
