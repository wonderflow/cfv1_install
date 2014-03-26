class CloudAgentYaml

  def initialize(iptable,cloudagent_yml)
    @cloudagent_yml = cloudagent_yml
    @iptable = iptable
  end

  def output(ymlfile,folder,name)
    File.open(File.join('config',folder,name+".yml"),'w+'){|f|
      f.write(ymlfile.to_yaml) 
    }
  end

  #cloudagentyml name: jobname_index_cloud
  def cloud_yml_file_generate(cloudagent,ip)
    # TODO: nats and zkper only have one and choose the first ip 
    #        write into the cloudagent yml
    if ip['nats'] == nil
      #puts "ERROR : you don't give nats config! "
      abort("ERROR : you don't give nats config!")
      # TODO : need to delete below line and error exit
      #nats = '10.10.102.150'
    else
      nats = ip['nats'][0].chomp
    end
    if ip['zkper'] == nil
      #puts "ERROR : you don't give zkper config! "
      abort("ERROR : you don't give zkper config!")
      # TODO : need to delete below line and error exit
      #zkper = '10.10.102.150'
    else
      zkper = ip['zkper'][0].chomp
    end

    ip.keys.each do |key|
      if key == 'domain' then next end
      ip[key].each_with_index do |host,index|
        cloudagent['mbus'] = "nats://nats:nats@"+nats+":4222"
        cloudagent['zkp_url'] = zkper+":2181"
        cloudagent['job'] = key
        cloudagent['job_index'] = index
        output cloudagent,'cloudagentyml',key+"_"+index.to_s+"_cloud"
      end
    end
    puts "generate all jobs cloudagent.yml complete."
  end

  def work
    cloud_yml_file_generate @cloudagent_yml,@iptable
  end

end
