class HealthMonitorYaml

  def initialize(iptable,healthmonitor_yml)
    @healthmonitor_yml = healthmonitor_yml
    @iptable = iptable
  end

  def output(ymlfile,name)
    File.open(File.join('config',name+".yml"),'w+'){|f|
      f.write(ymlfile.to_yaml) 
    }
  end

  def work
    if @iptable['domain'] == nil
      abort("ERROR : you don't give nats config!")
    else
      @healthmonitor_yml['properties']['domain'] = @iptable['domain']
    end
    if @iptable['nats'] == nil
      abort("ERROR : you don't give nats config!")
    else
      @healthmonitor_yml['properties']['nats']['address'] = @iptable['nats']
    end
    if @iptable['opentsdb'] == nil
      abort("ERROR : you don't give opentsdb config!")
    else
      @healthmonitor_yml['properties']['hm']['tsdb']['address'] = @iptable['opentsdb']
    end
    output @healthmonitor_yml,"health_monitor"
  end

end
