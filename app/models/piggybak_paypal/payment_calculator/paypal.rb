module PiggybakPaypal
  class PaymentCalculator::Paypal
    KEYS = ['test_login', 
            'test_password',
            'test_signature',
            'live_login',
            'live_password',
            'live_signature']
    KLASS = ::ActiveMerchant::Billing::PaypalGateway
    
    def initialize(payment_method)
      @payment_method = payment_method
    end
    
    def gateway_mode
      Piggybak.config.activemerchant_mode == :test ? "test" : "live" 
    end

    def details_from_token(token)
      response = gateway.details_for(token)
      data = response.params
      billing_country = Piggybak::Country.where(abbr: data['PayerInfo']['Address']['Country']).first
      shipping_country = Piggybak::Country.where(abbr: data['PaymentDetails']['ShipToAddress']['Country']).first
      details = {
        billing_address_attributes: {
          firstname: data['PayerInfo']['PayerName']['FirstName'],
          lastname: data['PayerInfo']['PayerName']['LastName'],
          address1: data['PayerInfo']['Address']['Street1'],
          address2: data['PayerInfo']['Address']['Street2'],
          city: data['PayerInfo']['Address']['CityName'],
          state_id: data['PayerInfo']['Address']['StateOrProvince'],
          country_id: billing_country ? billing_country.id : nil,
          zip: data['PayerInfo']['Address']['PostalCode']
        },
        shipping_address_attributes: {
          firstname: data['PayerInfo']['PayerName']['FirstName'],
          lastname: data['PayerInfo']['PayerName']['LastName'],
          address1: data['PaymentDetails']['ShipToAddress']['Street1'],
          address2: data['PaymentDetails']['ShipToAddress']['Street2'],
          city: data['PaymentDetails']['ShipToAddress']['CityName'],
          state_id: data['PaymentDetails']['ShipToAddress']['StateOrProvince'],
          country_id: shipping_country ? shipping_country.id : nil,
          zip: data['PaymentDetails']['ShipToAddress']['PostalCode']
        },
        email: data['PayerInfo']['Payer'],
        phone: data['phone']
      }
    end

    def generate_express_url(options)
      total = (options[:cart].total * 100).to_i
      items = options[:cart].sellables.collect{|item| { :name => item[:sellable].description, :amount  => (item[:sellable].price * 100).to_i, :quantity => item[:quantity], :number => item[:sellable].sku }}
      paypal = gateway.setup_purchase(total,
        :ip                => options[:remote_ip],
        :return_url        => options[:return_url],
        :cancel_return_url => options[:cancel_url],
        :subtotal          => total,
        :items             => items
      )
      return gateway.redirect_url_for(paypal.token)
    end

    def method_missing(method_sym, *arguments, &block)
      if [:login,:password,:signature].include?(method_sym)
        return @payment_method.key_values["#{self.gateway_mode}_#{method_sym.to_s}".to_sym]
      else
        super
      end
    end

    def gateway
      ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode
      gateway =  ActiveMerchant::Billing::PaypalExpressGateway.new(
        :login => login,
        :password => password,
        :signature => signature
      )
      return gateway
    end
    
  end
end

