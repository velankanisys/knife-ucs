# Author:: Murali Raju (<murali.raju@appliv.com>)
# Copyright:: Copyright (c) 2012 Murali Raju.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/ucs_base'

class Chef
  class Knife
    class UcsOrgCreate < Knife

      include Knife::UCSBase

      deps do
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife ucs org create (options)"

      attr_accessor :initial_sleep_delay

      option :org,
        :short => "-O ORG",
        :long => "--org ORG",
        :description => "The sub organization",
        :proc => Proc.new { |f| Chef::Config[:knife][:org] = f }


      def run
        $stdout.sync = true
        
        xml_response = provisioner.create_org({:org => Chef::Config[:knife][:org]}.to_json)
        xml_doc = Nokogiri::XML(xml_response)
        
        xml_doc.xpath("configConfMos/outConfigs/pair/orgOrg").each do |org|
            puts ''
            puts "Org: #{ui.color("#{org.attributes['name']}", :blue)} status: #{ui.color("#{org.attributes['status']}", :green)}"
        end

        #Ugly...refactor later to parse error with better exception handling. Nokogiri xpath search for elements might be an option
        xml_doc.xpath("configConfMos").each do |org|
           puts "#{org.attributes['errorCode']} #{ui.color("#{org.attributes['errorDescr']}", :red)}"
        end
        
      end
    end
  end
end
