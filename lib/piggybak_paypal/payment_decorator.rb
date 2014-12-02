module PiggybakPaypal
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do
      attr_accessor :token
      attr_accessor :payer_id

      #attr_accessible :token, :payer_id //changed for 4.1

      before_validation :set_defaults, :on => :create

      def set_defaults
        if self.token && self.payer_id
          Rails.logger.warn("****** Using bogus cc info *****")
          self.number = '4111111111111111'
          self.month = Time.now.month
          self.year = Time.now.year
          self.verification_value = '111'
        end
      end

      def process(order)
        return true if !self.new_record?

        # if transaction_id is present this is paypal_express
        if self.token
          ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode
          calculator = ::PiggybakPaypal::PaymentCalculator::Paypal.new(self.payment_method)
          self.month = Time.now.month
          self.year = Time.now.year
          order_total = (order.total_due * 100).to_i
          res = calculator.gateway.purchase(order_total, 
            :ip => order.ip_address, 
            :token => self.token, 
            :payer_id => self.payer_id
          )
        else
          ActiveMerchant::Billing::Base.mode = Piggybak.config.activemerchant_mode
          calculator = ::PiggybakPaypal::PaymentCalculator::Paypal.new(self.payment_method)
          payment_credit_card = ActiveMerchant::Billing::CreditCard.new(self.credit_card.merge(
            "first_name" => "#{order.billing_address.firstname}",
            "last_name" => "#{order.billing_address.lastname}"
          ))
          billing_address = order.avs_address.merge(
            "first_name" => "#{order.billing_address.firstname}",
            "last_name" => "#{order.billing_address.lastname}",
            :phone => order.phone,
            :email => order.email
          )
          shipping_address = {
            :name => "#{order.shipping_address.firstname} #{order.shipping_address.lastname}",
            :address1 => "#{order.shipping_address.address1}",
            :address2 => "#{order.shipping_address.address2}",
            :city => "#{order.shipping_address.city}",
            :state => "#{order.shipping_address.state_display}",
            :country => "#{order.shipping_address.country.abbr}",
            :zip => "#{order.shipping_address.zip}",
            :phone => order.phone
          }
          order_total = (order.total_due * 100).to_i
          gateway = ActiveMerchant::Billing::PaypalGateway.new(
            :login => calculator.login,
            :password => calculator.password,
            :signature => calculator.signature
          )

          res = gateway.purchase(order_total, payment_credit_card, :ip => order.ip_address, :address => billing_address, :shipping_address => shipping_address )
        end

        if res.success?
          return true
        else
          order.errors.add :payment_method_id, res.message.to_s
          return false
        end
      end

    end
  end
end
