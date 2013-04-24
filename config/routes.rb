PiggybakPaypal::Engine.routes.draw do
  match "/express" => "paypal#express", :as => :paypal_express
  match "/process" => "paypal#process_express", :as => :paypal_process
end
