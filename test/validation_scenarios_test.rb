require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/models'


class ValidationScenariosTest < Test::Unit::TestCase
  
  def setup
    ActiveRecord::Base.reset_validation_scenario
  end
  
  def test_no_scenarios
    assert Postcard.new(:title => "title", :text => "text").save
    
    without_title = Postcard.new(:text => "text")
    assert !without_title.save
    assert !without_title.errors[:title].blank?
    
    without_text = Postcard.new(:title => "title")
    assert !without_text.save
    assert !without_text.errors[:text].blank?
    
    has_nothing = Postcard.new
    assert !has_nothing.save
    assert !has_nothing.errors[:title].blank?
    assert !has_nothing.errors[:text].blank?
  end
  
  def test_thread_local
    assert_equal :default, ActiveRecord::Base.validation_scenario
    ActiveRecord::Base.validation_scenario = :all
    assert_equal :all, Address.validation_scenario  
  end
  
  def test_with_validation_scenario
    assert_not_numeric_postcode_in_address
  end
  
  def test_outside_of_validation_scenario
    assert_not_numeric_postcode_in_address
    assert_equal(:default, ActiveRecord::Base.validation_scenario)
    assert Address.new(:postcode => 'intentionally_not_numerical').save
  end
  
  def test_should_restore_previous_scenario_after_the_with_block
    ActiveRecord::Base.validation_scenario = :foo
    assert_not_numeric_postcode_in_address
    assert_equal(:foo, ActiveRecord::Base.validation_scenario)
  end
  
  def test_should_switch_validation_scenaries
    assert_not_numeric_postcode_in_address
    
    ActiveRecord::Base.with_validation_scenario(:payment_submission) do
      address = Address.new
      assert !address.save
      
      [:street_address_1, :city, :country, :postcode].each do |attr|
        assert address.errors.invalid?(attr)
      end
      
      address.attributes = {:postcode => "1234567890"}
      assert !address.save
      [:street_address_1, :city, :country].each do |attr|
        assert address.errors.invalid?(attr)
      end
      
      address.attributes = {:city => "Kiev"}
      assert !address.save
      [:street_address_1, :country].each do |attr|
        assert address.errors.invalid?(attr)
      end
    end
    
    assert_equal(:default, ActiveRecord::Base.validation_scenario)
  end
  
  # TODO: finish it for :unless clause
  def test_should_handle_validations_with_if_and_unless_clauses
    # out of any scenatios. Should be always validated
    user = User.new
    assert !user.save
    assert user.errors.invalid?(:always_validate_this)
    
    user.always_validate_this = "OK"
    assert user.save
    
    User.with_validation_scenario(:user_registration) do
      user = User.new(:always_validate_this => "OK")
      assert !user.save
      assert user.errors.invalid?(:email)
      
      user.email = "foo@bar.baz"
      assert user.save
      
      # Ok. Let's try the :if condition on email validation thing...
      user.email = nil
      user.guard = false
      assert user.save
      
      # Turn it on back
      user.guard = true
      assert !user.save
      assert user.errors.invalid?(:email)
    end
  end
  
  def test_should_propagate_validation_scenario_to_associated_objects
    ActiveRecord::Base.with_validation_scenario(:user_registration) do
      user = User.new(:email => "foo@bar.baz")
      user.build_address(:postcode => 'intentionally_not_numerical')
      assert !user.save
      assert user.errors.invalid?(:address)
      assert_match(/is not a number/i, user.address.errors.on(:postcode))
    end
  end
  
  private
  def assert_not_numeric_postcode_in_address
    ActiveRecord::Base.with_validation_scenario(:user_registration) do
      address = Address.new(:postcode => 'intentionally_not_numerical')
      assert !address.save
      assert address.errors.invalid?(:postcode)
      assert_match(/is not a number/i, address.errors.on(:postcode))
    end
  end

end
