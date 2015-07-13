#require 'aws-sdk'
#require 'serverspec'

#require_relative 'vpn_gateway_resource'
require_relative 'subnets_resource'
require_relative 'ec2_instance_resource'

#module Serverspec
  module Type
  	class ROUTETABLE < Base
  		def initialize(routetable_id)
      	raise 'must set a routetable_id' if routetable_id.nil?
        @routetable_id = routetable_id
      end
      def content
      	@routetable = AWS::EC2.new.routetables[@routetable_id]
        raise "#{@routetable_id} does not exist" unless @routetable.exists?
        @routetable
      end
      def to_s
        "routetable: #{@routetable_id}"
      end
      def subnets?
      	content.state == "yes"
      end
      def routetable(routetable_id)
      ROUTETABLE.new(routetable_id)
    end
  end
end
include Serverspec::Type
