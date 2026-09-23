# frozen_string_literal: true

module UserHub
  class Address
    attr_accessor :street, :city, :state, :zip_code

    def initialize(street, city, state, zip_code)
      @street   = street
      @city     = city
      @state    = state
      @zip_code = zip_code
    end

    # UML: getFullAddress() : Text
    def get_full_address
      "#{@street}, #{@city}, #{@state} #{@zip_code}".strip
    end

    def to_h
      { 'street' => @street, 'city' => @city, 'state' => @state, 'zip_code' => @zip_code }
    end

    def self.from_h(hash)
      new(hash['street'], hash['city'], hash['state'], hash['zip_code'])
    end
  end
end
