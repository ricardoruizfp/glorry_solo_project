require( 'sinatra' )
require( 'sinatra/contrib/all' )
require( 'pry-byebug' )
require_relative( '../models/driver.rb' )
require_relative( '../models/customer.rb' )
require_relative( '../models/delivery.rb' )
also_reload 'models/*'
get '/deliveries' do
  @deliveries = Delivery.all
  erb(:'deliveries/index')
end
