#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby
require 'yaml'

d = YAML::load_file('/home/sun/cf.yml')


mp = Hash.new
d['jobs'].each do |var|
	if mp[var['name']] == nil
		mp[var['name']] = []
	end
	mp[var['name']] << var['template']
end
#puts mp

Job = Struct.new(:ip,:index)
joblist = Hash.new

File.open("ipsss","r+") do |file|
	while line = file.gets
		if line.strip!="" && line.index("#")==nil
			ip,job,index = line.split(" ")
			if joblist[job] == nil
				joblist[job] = []
			end
			joblist[job] << Job.new(ip,index)
		end
	end
end


d['properties'].each do |x|
	if joblist[x[0]] != nil && x[1]['address'] != nil
		x[1]['address'] = joblist[x[0]][0][:ip]
	end
end
=begin
			if d['properties'][cfName]!=nil && 
				d['properties'][cfName]['address'] != nil
				d['properties'][cfName]['address'] = ip
=end

File.write('test.yml',d.to_yaml)

