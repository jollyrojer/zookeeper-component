require 'minitest/spec'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content"
end

sleep(20)
require 'socket'
require 'timeout'
def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

describe_recipe "zookeeper-component::default" do
  it "is firewall disabled" do
    case node["platform_family"] 
      when 'rhel'
        service("iptables").wont_be_running
      when 'debian'
        service("ufw").wont_be_running
      end
  end
  it "creates defaultconfig.exhibitor" do
    assert_file "#{node[:exhibitor][:opts][:defaultconfig]}", "root", "root", "644"
  end
  it "check /etc/init/exhibitor.conf has correct values" do
    assert_include_content("/etc/init/exhibitor.conf", "#{node["zookeeper"]["user"]}")
  end
  it "exhibitor is listening" do
    assert is_port_open?("#{node["ipaddress"]}", "#{node["exhibitor"]["opts"]["port"]}") == true, "Expected port #{node["exhibitor"]["opts"]["port"]} is open"
  end
  it "zookeeper is listening" do
    assert is_port_open?("#{node["ipaddress"]}", 2181) == true, "Expected port 2181 is open"
  end
end
