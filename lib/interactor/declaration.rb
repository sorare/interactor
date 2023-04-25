
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/class/attribute"
require "active_support/concern"

module Interactor
  # Internal: Methods relating to declaring what we receive and what will be stored in the context.
  module Declaration
    extend ActiveSupport::Concern

    included do
      class_attribute :context_class, instance_writer: false, default: Context
    end

    class_methods do
      def receive(*required_arguments, **optional_arguments)
        @required_arguments ||= []
        new_required_arguments = required_arguments - @required_arguments
        @required_arguments += new_required_arguments

        required_arguments.each { |arg| received_arguments << arg }
        optional_arguments.keys.each { |arg| received_optional_arguments << arg }

        delegate(*new_required_arguments, to: :context) unless new_required_arguments.empty?
        delegate(*optional_arguments.keys, to: :context) unless optional_arguments.empty?

        attributes = [*new_required_arguments, *optional_arguments.keys]

        self.context_class = Class.new(context_class) do
          attr_accessor *new_required_arguments
          attr_writer *optional_arguments.keys

          optional_arguments.each do |k, v|
            define_method(k) do
              ivar = "@#{k}"
              return instance_variable_get(ivar) if instance_variable_defined?(ivar)

              instance_variable_set(ivar, v.is_a?(Proc) ? instance_eval(&v) : v)
            end
          end

          class_eval %Q<
            def self.build(
              #{new_required_arguments.map { |a| "#{a}:" }.join(', ')}#{new_required_arguments.empty? ? '' : ', '}
              **rest
            )
              super(**rest).tap do |instance|
                #{new_required_arguments.map { |a| "instance.#{a} = #{a}" }.join(';')}

                #{
                  optional_arguments.keys.map do |k|
                    "instance.instance_variable_set('@#{k}', rest[:#{k}]) if rest.key?(:#{k})"
                  end.join("\n")
                }
              end
            end
          >

          class_eval %Q<
            def to_h
              super.merge(
                #{attributes.map { |a| "#{a}: self.#{a}"}.join(', ')}
              )
            end
          >
        end
      end

      def received_arguments
        @received_arguments ||= []
      end

      def received_optional_arguments
        @received_optional_arguments ||= []
      end

      def hold(*held_fields, **held_fields_with_default_value)
        attributes = [*held_fields, *held_fields_with_default_value.keys]
        delegate(*attributes, to: :context)

        attributes.each { |attr| held_attributes << attr }

        self.context_class = Class.new(context_class) do
          attr_accessor *held_fields
          attr_writer *held_fields_with_default_value.keys

          held_fields_with_default_value.each do |k, v|
            define_method(k) do
              ivar = "@#{k}"
              return instance_variable_get(ivar) if instance_variable_defined?(ivar)

              instance_variable_set(ivar, v.is_a?(Proc) ? instance_eval(&v) : v)
            end
          end

          class_eval %Q<
            def to_h
              super.merge(#{attributes.map { |f| "#{f}: self.#{f}"}.join(', ')})
            end
          >
        end

      end

      def held_attributes
        @held_attributes ||= []
      end
    end
  end
end
