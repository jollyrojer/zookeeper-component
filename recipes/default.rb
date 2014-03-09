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
  cookbook "zookeeper-component"
  source "defaultconfig.exhibitor.erb"
  action :nothing
end

template "/etc/init/exhibitor.conf" do
    cookbook "zookeeper-component"
    source "exhibitor.upstart.conf.erb"
    action :nothing
end

include_recipe "zookeeper"

if platform_family?('rhel')
  execute "stop iptables" do
    command "if [ -e '/sbin/iptables' ]; then bash -c '/etc/init.d/iptables stop'; else echo $?; fi"
  end
end

if platform_family?('debian')
  execute "stop iptables" do
    command "if [ -e '/sbin/iptables' ]; then bash -c ' iptables -F'; else echo $?; fi"
  end
end
