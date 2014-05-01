# utility 'patch' is not included in build-essentials cookbook
# so we need instal it in this way

p = package "patch" do
  action :install
end
p.run_action(:install)

node.set[:exhibitor][:opts][:defaultconfig]="#{node[:exhibitor][:install_dir]}/defaultconfig.exhibitor"

if (node[:zookeeper][:hosts].nil?)
  node.normal[:zookeeper][:hosts]=[ node[:ipaddress] ]
end

template node[:exhibitor][:opts][:defaultconfig] do
  cookbook "cookbook-qubell-zookeeper"
  source "defaultconfig.exhibitor.erb"
  action :nothing
end

template "/etc/init/exhibitor.conf" do
    cookbook "cookbook-qubell.zookeeper"
    source "exhibitor.upstart.conf.erb"
    action :nothing
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
