class CfYaml

  def initialize(iptable,cfyml)
    @iptable = iptable
    @cf_yml = cfyml
  end

  def output(ymlfile,folder,name)
    File.open(File.join('config',folder,name+".yml"),'w+'){|f|
      f.write(ymlfile.to_yaml) 
    }
  end

  #traverse all the yaml tree
  def traverse(obj,&blk)
    case obj
    when Hash
      obj.each{|k,v| traverse(v, &blk)}
    when Array
      obj.each{|v| traverse(v, &blk)}
    else
      blk.call(obj)
    end
  end

  #check old domain and change to the new one
  def domain_change(cf,new)
    old = cf['properties']['domain'].chomp
    #puts "old string is : "+old
    traverse(cf) do |node|
      r = /#{old}/
      if node =~ r
        node.gsub!(old,new)
      end
    end
  end

  def exchange(cf,ip)
    domain_change cf,ip['domain'][0]
    # TODO:wait for change to avoid stubborn
    c_ip = ['nats','ccdb','uaadb','vcap_redis','nfs_server',\
            'hbase_master','opentsdb','syslog_aggregator']
    c_ip.each do |str|
      if ip[str] == nil && str != 'nfs_server'
        puts "warn : no component #{str}" 
        next
      end
      if str != 'nfs_server'
        cf['properties'][str]['address'] = ip[str][0]
      else
        if ip['debian_nfs_server'] == nil
          puts "warn : no debian_nfs_server!"
          next
        end
        network = ip['debian_nfs_server'][0]
        cf['properties'][str]['address'] = network
        cf['properties'][str]['network'] = network.sub(/\d+$/, '0/24')
      end
    end
    # TODO:wait for change to avoid stubborn
    c_ips = ['hbase_slave']
    c_ips.each do |str|
      if ip[str] == nil 
        puts "warn : no component #{str}" 
        next
      end
      cf['properties'][str]['addresses'][0] = ip[str][0]
    end
  end

  #cfyml name : jobname_index_cf
  def cf_yml_file_generate(cf,ip)
    exchange cf,ip
    ip.keys.each do |key|
      if key == 'domain' then next end
      if key == 'uaadb' || key == 'ccdb'
        cf['properties']['db'] = key
      else
        cf['properties'].delete('db')
      end
      ip[key].each_with_index do |host,index|
        if cf['properties'].keys.inspect.include? key
          cf['properties'][key]['address'] = host
        end
        output cf,'cfyml',key+"_"+index.to_s+"_cf"
      end
    end
    puts "generate all jobs cf.yml complete."
  end

  def work()
    cf_yml_file_generate @cf_yml,@iptable
  end

end
