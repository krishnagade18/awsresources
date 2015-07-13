require 'aws-sdk'
require 'serverspec'
require_relative 'launch_configuration_resource'

module Serverspec
  module Type

    class AutoScalingGroup < Base

      def initialize(group_name_tag_value)
        @group_name = group_name_tag_value
      end

      def content
        found_group_name = nil

        AWS::AutoScaling.new.groups.each do |group|
          group.tags.each do |tag|
            if tag[:key] == 'Name' and tag[:value] == @group_name
              found_group_name = group.name
            end
          end
        end

        if found_group_name == nil
          raise "no match found for #{@group_name}"
        else
          AWS::AutoScaling.new.groups[found_group_name]
        end
      end

      def has_default_cooldown?(default_cooldown)
        content.default_cooldown == default_cooldown
      end

      def has_health_check_grace_period?(health_check_grace_period)
        content.health_check_grace_period == health_check_grace_period
      end

      def has_desired_capacity?(desired_capacity)
        content.desired_capacity == desired_capacity
      end

      def has_placement_group?(placement_group)
        content.placement_group == placement_group
      end

      def has_min_size?(min_size)
        content.min_size == min_size
      end

      def has_max_size?(max_size)
        content.max_size == max_size
      end

      def has_launch_configuration?(launch_configuration_name)
        content.launch_configuration_name == launch_configuration_name
      end

      def has_availability_zone_names?(availability_zone_names)
        Set.new(content.availability_zone_names.to_a) == Set.new(availability_zone_names)
      end

      def has_load_balancers?(load_balancer_names)
        puts "#{@group_name} has load balancers: #{content.load_balancer_names.to_a}"
        Set.new(content.load_balancer_names.to_a) == Set.new(load_balancer_names)
      end

      def has_enabled_metrics?(enabled_metrics)
        Set.new(content.enabled_metrics) == Set.new(enabled_metrics)
      end

      def to_s
        "autoscaling group: #{@group_name}"
      end

      def group_launch_configuration
        launch_configuration(content.launch_configuration.name)
      end
    end

    #this is how the resource is called out in a spec
    def auto_scaling_group(group_name_tag_value)
      AutoScalingGroup.new(group_name_tag_value)
    end

  end
end

include Serverspec::Type