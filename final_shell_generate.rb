class FinalShell
  def initialize(iptable)
    @iptable = iptable
  end

  def work()
    @iptable.keys.each do |key|
      if key == 'domain' then next end
      @iptable[key].each_with_index do |host,index|
        filename = key+"_"+index.to_s
        File.open(File.join('shell','jobs',filename+".sh"),'w+'){|f|
          f.write("bash env.sh\n")
          f.write("mv #{filename+'_cf.yml'} /home/vcap/vcap/deploy/cf.yml\n")
          f.write("echo 'mv cf files'\n")
          f.write("sudo mv #{filename+'_cloud.yml'} /var/vcap/jobs/cloud_agent/config/cloud_agent.yml\n")
          f.write("echo 'mv cloud files'\n")
          f.write("echo 'start exec autoinstall'\n")
          f.write("bash autoinstall.sh\n")
          f.write("sudo mv cloud_agent.monitrc /var/vcap/monit/\n")
          f.write("cd vcap/deploy/nise_bosh/\n") 
          if key == 'health_monitor'
            f.write("sudo bundle exec ./bin/nise-bosh ../bosh-release/ ../health_monitor.yml #{key}\n")
          else
            f.write("sudo bundle exec ./bin/nise-bosh ../cf-release/ ../cf.yml #{key}\n")
          end
          f.write("sudo chmod a+rx /var/vcap/monit\n")
          f.write("sudo /var/vcap/bosh/bin/monit\n")
         # f.write("sudo /var/vcap/bosh/bin/monit reload\n")
         # f.write("sudo /var/vcap/bosh/bin/monit restart all\n") 
          f.write("sudo /var/vcap/bosh/bin/monit summary\n")    
        }
      end
    end
    puts "generate all jobs install.sh complete."
  end
end
