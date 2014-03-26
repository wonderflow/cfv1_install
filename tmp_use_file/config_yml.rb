
require 'yaml'

def init()
  yml = YAML::load_file('iptable.yml')
  File.open("iptable","r+").each do |line|
    if line.strip != "" 
      ip,job,index = line.split(" ")
      if index=="0"
        yml[job] = ip
      else
        yml[job] << ip
      end
    end
  end
  File.open('iptable.yml','w') {|f|f.write yml.to_yaml}
end

init

