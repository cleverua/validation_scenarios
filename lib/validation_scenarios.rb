module ActiveRecord
  module ValidationScenarios

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        class << self
          alias_method_chain :evaluate_condition, :scenario
        end
      end
    end

    module ClassMethods
      def when_scenario_is(scenario_name)
	      yield ActiveRecordClassProxy.new(self, scenario_name)
      end
      
      def validation_scenario=(value)
        Thread.current[:validation_scenario] = value
      end
    
      def validation_scenario
        Thread.current[:validation_scenario] ||= :default
      end
      
      def with_validation_scenario(scenario_name)
        begin
          previous_scenario = self.validation_scenario
          self.validation_scenario = scenario_name
          yield
	      ensure
          self.validation_scenario = previous_scenario
        end
      end
      
      def reset_validation_scenario
	      self.validation_scenario = :default
      end
      
      def evaluate_condition_with_scenario(condition, record)
	      if condition.is_a?(ScenarioValidationCondition)
          if condition.scenario_condition.call(record)
            return condition.if_options ? evaluate_condition_without_scenario(condition.if_options, record) : true
          else
            return false
          end
        else
          evaluate_condition_without_scenario(condition, record)
        end
      end
    end
    
    class ActiveRecordClassProxy
      def initialize(clazz, scenario_name)
        @clazz = clazz
        @scenario_name = scenario_name
      end
      
      def method_missing(meth, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}   
        options[:if] = build_condition(options)
        args = args.push(options)
        @clazz.send(meth, *args)
      end
      
      def build_condition(options)
        scenario_condition = Proc.new { |r| @clazz.validation_scenario == @scenario_name }
	      ScenarioValidationCondition.new(scenario_condition, options[:if] || nil)
      end

    end
    
    ScenarioValidationCondition = Struct.new(:scenario_condition, :if_options)
    
  end
end
