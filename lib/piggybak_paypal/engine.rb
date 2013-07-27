require 'piggybak_paypal/payment_decorator'
module PiggybakPaypal
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakPaypal

    config.to_prepare do
      Piggybak::Payment.send(:include, ::PiggybakPaypal::PaymentDecorator)
    end
    
    initializer "piggybak_paypal.add_calculators" do
      Piggybak.config do |config|
        config.payment_calculators << "::PiggybakPaypal::PaymentCalculator::Paypal"
      end
    end
    
  end
end
