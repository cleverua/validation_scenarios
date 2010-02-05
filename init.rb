require 'validation_scenarios'

ActiveRecord::Base.class_eval do
  include ActiveRecord::ValidationScenarios
end
