require 'razorpay/order'
require 'razorpay/customer'
key_id = ENV['RAZORPAY_KEY_ID']
secret_key = ENV['RAZORPAY_SECRET_KEY']
Rails.logger.info "RAZORPAY_KEY_ID: #{ENV['RAZORPAY_KEY_ID']}"
Rails.logger.info "RAZORPAY_SECRET_KEY: #{ENV['RAZORPAY_SECRET_KEY']}"
Razorpay.setup(key_id, secret_key)
