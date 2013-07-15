PiggybakPaypal::Engine.routes.draw do
  get "/express" => "paypal#express", :as => :paypal_express
  get "/process" => "paypal#process_express", :as => :paypal_process
end
