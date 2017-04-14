#!/usr/bin/env ruby

## contrib via https://github.com/ytti/oxidized/issues/67

require 'open-uri'
require 'json'
require 'optparse'

critical = false
pending = false
critical_nodes = []
pending_nodes = []
hostname = ""

OptionParser.new do |op|
  op.parse!
  hostname = ARGV.pop
  raise "Need to specify a hostname" unless hostname
end

json = JSON.load(open("http://#{hostname}:8888/nodes.json"))
json.each do |node|
  if not node['last'].nil?
    if node['last']['status'] != 'success'
      critical_nodes << node['name']
      critical = true
    end
  else
    pending_nodes << node['name']
    pending = true
  end
end

if critical
  puts '[CRIT] Unable to backup: ' + critical_nodes.join(',')
  exit 2
elsif pending
  puts '[WARN] Pending backup: ' + pending_nodes.join(',')
  exit 1
else
  puts '[OK] Backup of all nodes completed successfully.'
  exit 0
end
