class ChargesController < ApplicationController


def new
end

def create
  # Amount in cents
  # @amount = 500

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :source  => params[:stripeToken],
    :metadata => {
      "First Name" => params[:firstname], 
      "Last Name" => params[:lastname] 
      
    }

  )
  
  puts "test #{customer.inspect}"

  # charge = Stripe::Charge.create(
  #   :customer    => customer.id,
  #   :amount      => @amount,
  #   :description => 'Rails Stripe customer',
  #   :currency    => 'usd'
  # )

rescue Stripe::CardError => e
  flash[:error] = e.message
  redirect_to new_member_path
end

end