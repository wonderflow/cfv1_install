#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby
$:.unshift File.dirname(__FILE__)

require 'yaml'
require 'cf_yml_generate'
require 'cloudagent_yml_generate'
require 'healthmonitor_yml_generate'
require 'final_shell_generate'

class NiseConfig

  def load_yml(file)
    return YAML::load_file(file)
  end

  def work()
    iptable = load_yml File.join('config','iptable.yml')
    cf_yml = load_yml File.join('config','cf.yml')
    cloudagent_yml = load_yml File.join('config','cloud_agent.yml')
    healthmonitor_yml = load_yml File.join('config','health_monitor.yml')

    CfYaml.new(iptable,cf_yml).work
    CloudAgentYaml.new(iptable,cloudagent_yml).work
    HealthMonitorYaml.new(iptable,healthmonitor_yml).work
    FinalShell.new(iptable).work
    
    return iptable
  end

end




