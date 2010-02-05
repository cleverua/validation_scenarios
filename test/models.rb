class Postcard < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :text
end

class Address < ActiveRecord::Base 
  belongs_to :user
  
  when_scenario_is :user_registration do |this|
    this.validates_numericality_of :postcode
  end
  when_scenario_is :payment_submission do |this|
    this.validates_presence_of :street_address_1
    this.validates_presence_of :city
    this.validates_presence_of :country
    this.validates_numericality_of :postcode
  end
end

class User < ActiveRecord::Base
  attr_writer :guard
  
  has_one :address
  
  validates_length_of :always_validate_this, :within => 1..5
  
  when_scenario_is :user_registration do |this|
    this.validates_presence_of :email, :if => :guard
    this.validates_associated :address
  end
  
  when_scenario_is :payment_submission do |this|
    this.validates_numericality_of :email, :unless => :should_validate_email?
    this.validates_presence_of :firstname, :lastname
  end

  def guard
    @guard = true if @guard.nil?
    @guard
  end  
  
end