# utility 'patch' is not included in build-essentials cookbook
# so we need instal it in this way

# Support build-essential <= 1.4.4
node.set[:build_essential][:compiletime] = true

p = package "patch" do
  action :install
end
p.run_action(:install)

if (node[:zookeeper][:hosts].nil?)
  node.normal[:zookeeper][:hosts]=[ node[:ipaddress] ]
end

tmp_arr = []
node["zookeeper"]["hosts"].each_with_index do |e,i|
   tmp_arr << "S:#{i+1}:#{e}"
end

node.set[:exhibitor][:defaultconfig][:servers_spec]=tmp_arr.join(",")
node.set[:exhibitor][:defaultconfig][:zoo_cfg_extra] = 'tickTime\=2000&initLimit\=60&syncLimit\=5'
node.set[:exhibitor][:defaultconfig][:auto_manage_instances_settling_period_ms] = 1000

if (node[:ipaddress].nil?)
  node.set[:exhibitor][:opts][:hostname] = node[:network][:interfaces][node[:network][:default_interface]][:addresses].select{|k,v| v.family == "inet"}.keys[0]
end

include_recipe "zookeeper"

case node[:platform_family]
  when "rhel"
    service "iptables" do
      action :stop
    end
  when "debian"
    service "ufw" do
      action :stop
    end
  end

node.set["zookeeper"]["connect_uri"] = node["zookeeper"]["hosts"].map {|x| "#{x}:#{node["exhibitor"]["defaultconfig"]["client_port"]}"}.join(",")
