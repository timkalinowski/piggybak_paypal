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

    def method_missing(method_sym, *arguments, &block)
      if [:login,:password,:signature].include?(method_sym)
        return @payment_method.key_values["#{self.gateway_mode}_#{method_sym.to_s}".to_sym]
      else
        super
      end
    end
    
  end
end

