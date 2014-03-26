str = []
ip="10.10.102.1"
num = 50
File.open("iptable","r+").each do |file|
    puts file
    str << ip+num.to_s+" "+file
    num += 1
end
str.each do |s|
  puts s
end
