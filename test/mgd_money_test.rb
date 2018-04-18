require "test_helper"

class MgdMoneyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MgdMoney::VERSION
  end
  
  ##############################################################################
  ## Test the basic initialization of new MGDMoney objects. Ensuring objects  ##
  ## are initialized properly will save headaches down the road.              ##
  ##############################################################################
  
  # test that a new MGDMoney object can be initialized with valid attributes
  def test_initialization
    twenty_dollars = MGDMoney.new(20, "USD")
    assert twenty_dollars
  end
  
  # test that a new MGDMoney object can only be initialized with a number amount, not a string
  def test_invalid_amount
    assert_raises MGDMoney::InvalidDeclarationError do 
      MGDMoney.new("20", "USD")
    end
  end
  
  # test that a new MGDMoney object cannot be initialized with nil for the amount
  def test_nil_amount
    assert_raises MGDMoney::InvalidDeclarationError do
      MGDMoney.new(nil, "USD")
    end
  end
  
  # test that a new MGDMoney object can only be initialized with a (non-empty string) currency
  def test_invalid_currency
    assert_raises MGDMoney::InvalidDeclarationError do
      MGDMoney.new(20, "")
    end
  end
  
  ##############################################################################
  ## Test the setting of the user-specified currency conversion rates. This   ##
  ## is crucial because all the operations of the gem depend on these rates.  ##
  ##############################################################################
  
  # test that the currency conversion rates cannot be specified without a base currency 
  def test_currency_rates_with_invalid_base
    assert_raises MGDMoney::InvalidConversionDeclarationError do
      MGDMoney.conversion_rates(nil, { "EUR" => 0.4 })
    end
  end
  
  # test that the currency conversion rates cannot be specified without the actual hash being present 
  def test_currency_rates_without_rates
    assert_raises MGDMoney::InvalidConversionDeclarationError do
      MGDMoney.conversion_rates("USD", nil)
    end
  end
  
  # test that if the conversion rates hash was specified, each key/value pair is a string/number combo
  def test_currency_rates_hash_format
    assert_raises MGDMoney::InvalidConversionDeclarationError do
      MGDMoney.conversion_rates("USD", { "EUR" => nil, "BTC" => 0.0001 })
    end
  end
  
  # test that we can actually set the conversion rates so we can use them for all other operations
  def test_currency_rate_assignment
    assert MGDMoney.conversion_rates("USD", { "EUR" => 0.8, "BTC" => 0.0001 })
  end
  
  ##############################################################################
  ## Test basic functions such as inspect, retrieving the amount/currency,    ##
  ## and conversion between currencies                                        ##
  ##############################################################################
  
  # test the output format of the inspect method - this also tests the convert_to_float method
  def test_inspect_format
    twenty_dollars_inspected = MGDMoney.new(20, "USD").inspect
    assert_equal("20.00 USD", twenty_dollars_inspected)
  end
  
  # test the retrieval of an MGDMoney object's amount
  def test_amount
    twenty_dollars_amount = MGDMoney.new(20, "USD").amount 
    assert_equal(20, twenty_dollars_amount)
  end
  
  # test the retrieval of an MGDMoney object's currency
  def test_currency 
    twenty_dollars_currency = MGDMoney.new(20, "USD").currency
    assert_equal("USD", twenty_dollars_currency)
  end
  
  # test the conversion between currencies by converting 20 USD to EUR, then back to USD, 
  # and compare the converted value to the original 20 USD
  def test_currency_conversion
    MGDMoney.conversion_rates("USD", { "EUR" => 0.8 })                                          # configure the conversion rates
    
    twenty_dollars = MGDMoney.new(20, "USD")                                                    # initialize the $20 MGDMoney object
    twenty_dollars_in_eur = twenty_dollars.convert_to("EUR")                                    # convert to EUR
    twenty_dollars_in_eur_in_usd = twenty_dollars_in_eur.convert_to("USD")                      # convert EUR back to USD
    
    assert_equal(twenty_dollars, twenty_dollars_in_eur_in_usd)                                  # compare to original $20
  end
  
  ##############################################################################
  ## Test arithmetic operations on two MGDMoney objects                       ##
  ##############################################################################
  
  ########################    ADDITION    ###################################### 
  # test that an exception is raised if you try to add but both objects aren't
  # MGDMoney objects
  def test_addition_object_check
    twenty_eur = MGDMoney.new(20, "EUR")                                                        # a valid MGDMoney object
    fifty_seven = 57                                                                            # an invalid object that can't be summed 
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur + fifty_seven
    end
  end
  
  # test that addition works with two MGDMoney objects of the same currency
  def test_addition_same_currency
    ten_dollars = MGDMoney.new(10, "USD")
    fifteen_dollars = MGDMoney.new(15, "USD")
    twenty_five_dollars = MGDMoney.new(25, "USD")                                               # the expected output
    
    assert_equal( twenty_five_dollars, ten_dollars + fifteen_dollars)
  end
  
  # test that addition works with two MGDMoney objects of different currencies, 
  # and returns the result in the currency of the first object
  def test_addition_multiple_currencies
    MGDMoney.conversion_rates("USD", { "EUR" => 0.75 })
    ten_dollars = MGDMoney.new(10, "USD")
    ten_eur = MGDMoney.new(10, "EUR")
    sum_in_usd = MGDMoney.new(23.33, "USD")
    
    assert_equal(sum_in_usd, ten_dollars + ten_eur)
  end
  
  ########################    SUBTRACTION    ################################### 
  # test that an exception is raised if you try to subtract but both objects aren't
  # MGDMoney objects
  def test_subtraction_object_check
    twenty_eur = MGDMoney.new(20, "EUR")                                                        # a valid MGDMoney object
    fifty_seven_no_object = 57                                                                  # an invalid object that can't be subtracted
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur - fifty_seven_no_object
    end
  end
  
  # test that subtraction works with two MGDMoney objects of the same currency
  def test_subtraction_same_currency
    twenty_dollars = MGDMoney.new(20, "USD")
    fifteen_dollars = MGDMoney.new(15, "USD")
    five_dollars = MGDMoney.new(5, "USD")                                                       # the expected output
    
    assert_equal(five_dollars, twenty_dollars - fifteen_dollars)
  end
  
  # test that subtraction works with two MGDMoney objects of different currencies, 
  # and returns the result in the currency of the first object
  def test_subtraction_multiple_currencies
    MGDMoney.conversion_rates("USD", { "EUR" => 0.75 })
    twenty_dollars = MGDMoney.new(20, "USD")
    ten_eur = MGDMoney.new(10, "EUR")
    difference_in_usd = MGDMoney.new(6.67, "USD")
    
    assert_equal(difference_in_usd, twenty_dollars - ten_eur)
  end
  
  ########################    MULTIPLICATION    ################################ 
  # test that an exception is raised if you try to multiply two MGDMoney objects
  def test_multiplication_object_check
    twenty_eur = MGDMoney.new(20, "EUR")                                                        # a valid MGDMoney object
    fifty_eur = MGDMoney.new(50, "EUR")                                                         # an invalid object that can't be multiplied
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur * fifty_eur
    end
  end
  
  # test that an exception is raised if the multiplication factor isn't a number 
  def test_multiplication_by_non_number
    twenty_eur = MGDMoney.new(20, "EUR")
    fifty_string = "50"
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur * fifty_string
    end
  end
  
  # test that multiplication works with one MGDMoney object and one number
  def test_multiplication
    twenty_dollars = MGDMoney.new(20, "USD")
    forty_dollars = MGDMoney.new(40, "USD")
    
    assert_equal(forty_dollars, twenty_dollars * 2)
  end
  
  ########################    DIVISION    ######################################
  # test that an exception is raised if you try to divide two MGDMoney objects
  def test_division_object_check
    twenty_eur = MGDMoney.new(20, "EUR")                                                        # a valid MGDMoney object
    fifty_eur = MGDMoney.new(50, "EUR")                                                         # an invalid object that can't be divided
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur / fifty_eur
    end
  end
  
  # test that an exception is raised if the division factor isn't a number 
  def test_division_by_non_number
    twenty_eur = MGDMoney.new(20, "EUR")
    fifty_string = "50"
    
    assert_raises MGDMoney::UnsupportedOperationError do 
      twenty_eur / fifty_string
    end
  end
  
  # test that division works with one MGDMoney object and one number
  def test_division
    twenty_dollars = MGDMoney.new(20, "USD")
    forty_dollars = MGDMoney.new(40, "USD")
    
    assert_equal(twenty_dollars, forty_dollars / 2)
  end
end
