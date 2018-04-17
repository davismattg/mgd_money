require "mgd_money/version"

class MGDMoney
  include Comparable                                                                                # for implementing custom comparing methods for MGDMoney objects

  # initialize the instance variables for the singleton class.
  # this allows the user to configure the desired conversion rates
  # with respect to a base currency
  class << self
    attr_accessor :base_currency, :conversion_factors
  end

  attr_reader :amount, :currency                                                                    # each MGDMoney object will have these attributes

  # instantiate new MGDMoney objects.
  # @param [Numeric] amount, the amount of the given currency
  # @param [String] currency, the user-defined currency string
  # @return [MGDMoney] the resulting MGDMoney object
  # @example fifty_eur = MGDMoney.new(50, 'EUR') #=> 50 EUR
  def initialize(amount, currency)
    unless amount.is_a?(Numeric)                                                                    # the amount entered wasn't empty, but we still have to make sure it's a number
      raise UnknownObjectError, 'Amount must be a number'
    end

    if currency.empty?
      raise InvalidDeclarationError, 'Currency must be specified'
    end

    @amount = amount                                                                                 # input is OK, so set the attributes
    @currency = currency
  end

  # configure the currency rates on the singleton class with respect to a base currency
  # @param [String] base_currency, the currency used to determine conversion rates
  # @param [Hash] conversion_factors, the conversion rates for supported currencies
  # @return [nil]
  # @example
  # MGDMoney.conversion_rates("EUR", {
  #    "USD" => 1.11,
  #    "Bitcoin" => 0.0047
  # })
  def self.conversion_rates(base_currency, conversion_factors)
    self.base_currency = base_currency
    self.conversion_factors = conversion_factors
  end

  # convert to a different currency, returning a new MGDMoney object.
  # requires both source and destination currency to be defined by
  # MGDMoney.conversion_rates (otherwise rate not known)
  # @param [String] currency, the desired currency after conversion
  # @return [MGDMoney] the new MGDMoney object representing the converted currency
  # @example fifty_eur.convert_to('USD') # => 55.50 USD
  def convert_to(currency)
    if currency == self.currency                                                                    # source and destination currencies match
      self                                                                                          # no conversion needed
    else
      factors = MGDMoney.conversion_factors                                                         # get the user-specified conversion rates

      if self.currency == MGDMoney.base_currency                                                    # user specified this currency as the base currency
        if factors.keys.include?(currency)                                                          # ensures user did actually specify this conversion
          conversion_factor = factors["#{currency}"]                                                # look up the conversion rate from the Hash
          MGDMoney.new(self.amount*conversion_factor, currency)                                     # return the converted value as a new MGDMoney object
        else                                                                                        # conversion rate wasn't specified, so raise an error
          raise UnknownConversionError, 'Conversion rate not specified for this currency'
        end
      elsif currency == MGDMoney.base_currency                                                      # user specified desired currency as the base currency
        if factors.keys.include?(self.currency)                                                     # look for the source currency in the user-specified Hash
          conversion_factor = 1 / factors["#{self.currency}"]                                       # if found, invert that b/c the Hash is specified in opposite way
          MGDMoney.new(self.amount*conversion_factor, currency)                                     # return the converted value as a new MGDMoney object
        else                                                                                        # conversion rate wasn't specified, so raise an error
          raise UnknownConversionError, 'Conversion rate not specified for this currency'
        end
      else
        if factors.keys.include?(currency)                                                          # neither source nor desired currency are the base currency
          conversion_factor = factors["#{self.currency}"] * factors["#{currency}"]                  # compare them to each other
          MGDMoney.new(self.amount*conversion_factor, currency)                                     # return the converted value as a new MGDMoney object
        else                                                                                        # conversion rate wasn't specified, so raise an error
          raise UnknownConversionError, 'Conversion rate not specified for this currency'
        end
      end
    end
  end

  # get amount and currency of MGDMoney object
  # @example
  # fifty_eur.amount => 50
  # fifty_eur.currency => 'EUR'
  # fifty_eur.inspect => "50.00 EUR"
  def amount
    @amount
  end

  def currency
    @currency
  end

  # format the default output string format
  def inspect
    "#{(convert_to_float(@amount)).to_s + " " + currency}"
  end

  # convert the given number to its float representation.
  # this makes all the arithmetic possible
  # @param [Numeric] amount, the amount to convert
  # @return [BigDecimal]
  # @example convert_to_float(twenty_dollars.amount)
  def convert_to_float(amount)
    if amount.to_s.empty?                                                                         # entered amount was "" (empty string), return 0
      0
    else
      '%.2f' % amount
    end
  end

  # perform arithmetic operations in two different currencies
  # @param [MGDMoney] other_object, the MGDMoney object we're doing the operation with
  # @return [MGDMoney]
  # @example fifty_eur + twenty_dollars = 68.02 EUR
  # @example fifty_eur / 2 = 25 EUR
  def +(other_object)
    if other_object.is_a?(MGDMoney)
      other_object = other_object.convert_to(currency)
      self.class.new(amount + other_object.amount, currency)
    else
      raise UnsupportedOperationError, '#{other_object} must be of type MGDMoney to compute a sum'
    end
  end

  def -(other_object)
    if other_object.is_a?(MGDMoney)
      other_object = other_object.convert_to(currency)
      self.class.new(amount - other_object.amount, currency)
    else
      raise UnsupportedOperationError, '#{other_object} must be of type MGDMoney to compute a difference'
    end
  end

  def *(val)
    if val.is_a?(Numeric)
      self.class.new(amount * val, currency)
    else
      raise UnsupportedOperationError, 'Can only multiply an MGDMoney object by a number'
    end
  end

  def /(val)
    if val.is_a?(Numeric)
      self.class.new(amount / val, currency)
    else
      raise UnsupportedOperationError, 'Can only divide an MGDMoney object by a number'
    end
  end

  # compare different currencies (using Comparable)
  # in this case, we only care about comparing the amounts of each MGDMoney object
  # @param [MGDMoney] other_object, the object to compare to
  # @return [FixNum]
  # @example twenty_dollars == MGDMoney.new(20, 'USD') # => true
  # @example twenty_dollars == MGDMoney.new(30, 'USD') # => false
  # @example fifty_eur_in_usd = fifty_eur.convert_to('USD')
  # @example fifty_eur_in_usd == fifty_eur => true
  def <=>(other_object)
    if other_object.is_a?(MGDMoney)
      other_object = other_object.convert_to(currency)
      amount <=> other_object.amount
    else
      raise UnknownObjectError, 'Unknown destination object type (must be type MGDMoney)'
    end
  end

  # provide some useful error messages to the user
  class UnknownConversionError < StandardError
  end

  class UnknownObjectError < StandardError
  end

  class UnsupportedOperationError < StandardError
  end
end

