# ---------------------------------
# get index page
# ---------------------------------
get '/' do
  @title = 'Welcome'
  slim :'index'
end

# ---------------------------------
# not found
# ---------------------------------
not_found do
  flash[:danger] = 'URL does not exist!'
  redirect to '/'
end