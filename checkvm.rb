#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'net/ssh'
require 'net/scp'
class Check

  attr_accessor :OK

  def initialize(resource_file,ip_file)
    @resource_limit= resource_file
    @ip_file = ip_file
    @resource = Hash.new
    @checkOK = true
  end

  def connect(host,user,password)
    @resource[host] = Hash.new
    Net::SSH.start(host,user,:password=>password) do |ssh|
      @resource[host][:cpu] = ssh.exec!("cat /proc/cpuinfo \
                                       | grep processor | sort \
                                       | uniq | wc -l").chop.to_i
      @resource[host][:memerysize] = ssh.exec!("cat /proc/meminfo \
                                              | grep MemTotal \
                                              |awk '{print $2}'").chop.to_f
      @resource[host][:memerysize] /= 1024*1024
      @resource[host][:memerysize] = (@resource[host][:memerysize] += 0.5).to_i
      @resource[host][:disksize] = (ssh.exec!("df -Ph / | head -3 \
                                            |tail -1 |awk '{print $2}'").chop.delete"G").to_i
    end
  end

  def getlimit(key)
    x = ['small','middle','large']
    x.each do |var|
      if @resource_limit[var][3]['jobs'].inspect.include?key
        return @resource_limit[var][0],@resource_limit[var][1],@resource_limit[var][2]
      end
    end
    return 'error'
  end

  def work()
    thread = []
    @ip_file.keys.each do |key|
      if key == 'domain'; next;end
      cpu,memsize,disksize = getlimit(key)
      @ip_file[key].each do |host|
        `ssh-keygen -f "/home/sun/.ssh/known_hosts" -R #{host}`
        thread << Thread.new do 
          connect(host,'vcap','password')
          #puts "#{host} checked."
          if @resource[host][:cpu] < cpu.to_i
            print "CPU is not enough for #{key} on host #{host}!"
            puts " Only have #{@resource[host][:cpu]} CPU instead of #{cpu.to_i}" 
            @OK = false
          end
          if @resource[host][:memerysize] < memsize.to_i
            print "MemorySize is not enough for #{key} on host #{host}!"
            puts " Only have #{@resource[host][:memerysize]} G instead of #{memsize.to_i} G" 
            @OK = false
          end
          if @resource[host][:disksize] + 10< disksize.to_i
            print "DiskSize is not enough for #{key} on host #{host}!"
            puts " Only have #{@resource[host][:disksize]} G instead of #{disksize.to_i} G" 
            @OK = false
          end
        end
      end
    end
    thread.each do |s|
      s.join
    end
  end

end

