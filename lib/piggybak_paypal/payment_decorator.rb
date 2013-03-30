module PiggybakPaypal
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do

      def process(order)
        return true if !self.new_record?
        ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode
        calculator = ::PiggybakPaypal::PaymentCalculator::Paypal.new(self.payment_method)
        payment_credit_card = ActiveMerchant::Billing::CreditCard.new(self.credit_card.merge(
          "first_name" => "#{order.billing_address.firstname}",
          "last_name" => "#{order.billing_address.lastname}"
        ))
        billing_address = order.avs_address.merge(
          "first_name" => "#{order.billing_address.firstname}",
          "last_name" => "#{order.billing_address.lastname}",
          "phone" => order.phone
        )
        order_total = (order.total_due * 100).to_i
        gateway = ActiveMerchant::Billing::PaypalGateway.new(
          :login => calculator.login,
          :password => calculator.password,
          :signature => calculator.signature
        )

        res = gateway.authorize(order_total, payment_credit_card, :ip => order.ip_address, :address => billing_address )

        if res.success?
          gateway.capture(order_total, res.authorization)
          return true
        else
          order.errors.add :payment_method_id, res.message.to_s
          return false
        end
      end

    end
  end
end
