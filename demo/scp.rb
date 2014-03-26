#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'rubygems'
require 'net/ssh'
require 'net/scp'

def genarate_ip(bound = 2)
	list = []
	bound.times do |i|
		list << "10.10.102."+(2*i+142).to_s
	end
	return list
end


#remote scp with NET/SSH module
def run(list) 
	list.each do |host|
		puts host
		if(host!="")	
			Net::SSH.start(host,'vcap',:password=>"password") do |ssh|
				puts "success to setup."
				ssh.exec!("mkdir ~/wonderflow/")
				ssh.scp.upload!( './wonderflow-test' , 'wonderflow' , :recursive => true )do|ch, name, sent, total|
					print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
				end
				puts "\nDone."
			end
		end
	end
end

list = genarate_ip()
run(list)
