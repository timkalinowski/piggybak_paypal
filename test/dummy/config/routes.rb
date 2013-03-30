Rails.application.routes.draw do

  mount PiggybakPaypal::Engine => "/piggybak_paypal"
end
