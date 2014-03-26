require 'rubygems'
require 'net/ssh'
require 'net/scp'
File.open("iptables","r+") do |file|
        while line = file.gets
                if(line.strip!=""&&line.index("#")==nil)
                        ip,job,index = line.split(" ")
                        puts ip,job,index
                        Net::SSH.start("#{ip}",'root',:password=>"password") do |ssh|
                                ssh.scp.upload!( '/home/keton/nise_bosh_test/nise_bosh_auto_set/cloud_agent.yml' , '/home/vcap/wonderflow/wonderflow-test' , :recursive => true )do|ch, name, sent, total|
                                        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%\n"
                                end

                                ssh.exec!("sudo sed -i -e \'s/job: changeme/job: #{job}/g\' /home/vcap/wonderflow/wonderflow-test/cloud_agent.yml")
                                if(index!=0&&index!=nil)
                                        ssh.exec!("sudo sed -i -e \'s/job_index: 0/job_index: #{index}/g\' /home/vcap/wonderflow/wonderflow-test/cloud_agent.yml")
                                end
                        end
                end
        end

end

