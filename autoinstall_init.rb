require 'rubygems'
require 'net/ssh'
require 'net/scp'

class Install

  @@host_in_use = Hash.new

  attr_accessor :job
  attr_accessor :index
  attr_accessor :host
  attr_accessor :user
  attr_accessor :password

  def initialize(job,index,host,user,password)
    @job = job
    @index = index
    @host = host
    @user = user
    @password = password

    @filename = @job+"_"+@index.to_s
    @error = []
    #@running = true
  end

  def send_file(ssh,srcpath,despath)
    if File.exist?srcpath
      ssh.scp.upload!(srcpath,despath)
      #puts "#{srcpath} upload Done."
    else
      abort("ERROR: Don't have such File: #{srcpath}")
    end
  end

  #send huge blobs with a proceed tar
  def send_blobs(ssh,srcpath,despath)
    if File.exist?srcpath
      #puts srcpath.split('/').inspect+"  srcfile"
      #puts srcpath.split('/')[-1] + " src file"
      #puts ssh.exec!("ls").inspect
      if ssh.exec!("ls").inspect.include? srcpath.split('/')[-1]

#return
      end
      ssh.scp.upload!( srcpath , despath , :recursive => true )do|ch, name, sent, total|
        percent = (sent.to_f*100 / total.to_f).to_i
          print "\r#{@host}: #{name}: #{percent}%"
      end
      print "\n"
      puts "#{srcpath} upload Done."
    else
      abort("ERROR: Don't have such File: #{srcpath}")
    end
  end

  def send_all(ssh)
    files = []
    files << File.join('config','sources.list')
    files << File.join('shell','autoinstall.sh')
    files << File.join('shell','env.sh')
    files << File.join('config','cfyml',@filename+"_cf.yml")
    files << File.join('config','cloudagentyml',@filename+"_cloud.yml")
    files << File.join('shell','jobs',@filename+".sh")
    #files << File.join('config','sudoers')
    files << File.join('config','cloud_agent.monitrc')
    files << File.join('config','health_monitor.yml')
    blobs = []
    blobs << File.join('blobs','ruby-1.9.3-p448.tar.gz')
    blobs << File.join('blobs','rubygems-1.8.17.tgz')
    blobs << File.join('blobs','yaml-0.1.4.tar.gz')
    blobs << File.join('blobs','adeploy.gz')
    blobs << File.join('blobs','monit-5.2.4.tar.gz')
    blobs << File.join('blobs','cache.gz')
    #send some files
    files.each do |f|
      send_file(ssh,f,'.')
    end
    #send the important blob files
    blobs.each do |f|
      send_blobs(ssh,f,'.')
    end
  end

  def exec(ssh,log,instructor)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        puts "exec: "+instructor
        ch.exec(instructor)
        # TODO : add exception solving code
        # exception see pictures in Picture
        ch.on_data do |ch,data|
          checkstr = data.inspect
          if checkstr.include?"ERROR:" or checkstr.include?"error:" or checkstr.include?"Run `bundle install` to install missing gems."
            @error << checkstr
          end
          if data.inspect.include?"[sudo]" 
            channel.send_data("password\n")
          elsif data.inspect.include?"Enter your password"
            channel.send_data("password\n")
          elsif data.inspect.include?"[Y/n]"
            channel.send_data("y\n")
          elsif data.inspect.include?"[y/N]"
            channel.send_data("y\n")
          else
            log.puts data.strip
            puts data.strip
          end
        end
        ch.on_close do
          #@running = false
        end
      end
    end
    return true
  end

  def send_as_root(host,user,password)
    Net::SSH.start(host,'root',:password=>'123456') do |ssh|
      ssh.scp.upload!(File.join('config','sudoers'),'.')
      ssh.exec!('mv sudoers /etc/sudoers')
    end
  end

  #connect remote vm and run logical things
  def remote_connect(host,user,password)
    log_file = File.open(File.join("log",host+".log"),"w+")
    begin
      #send_as_root(host,user,password)
      @error = []
      Net::SSH.start(host,user,:password=>password) do |ssh|
        puts host+" connected."
        send_all ssh
        exec ssh,log_file,"bash #{@filename+'.sh'}"
      end
      if @error.size!=0
        puts "ERROR OCCURS:"
      end
      @error.each do |str|
        puts str
      end
    end while @error.size != 0
    log_file.close
  end 

  def work()
    puts @host.capitalize+" "+@job+" start to work."
    remote_connect(@host,@user,@password)
    puts @host.capitalize+" "+@job+" Done."
  end

end
