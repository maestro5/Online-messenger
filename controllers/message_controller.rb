# ---------------------------------
# create new message
# ---------------------------------
get '/message/create' do
  @title = 'Create message'
  @message = Message.new
  slim :"message/create"
end

post '/message' do
  @message = Message.new params[:message]
  @message.destruction_value = params[:destruction][@message.destruction]
  @message.owner_session_id  = session[:session_id]
  if @message.save
    redirect "/message/#{@message.secure_id}", flash[:success] = 'Message created'
  else
    slim :"message/create"
  end
end # post "/message"

# ---------------------------------
# view message
# ---------------------------------
get '/message/:secure_id' do
  unless find_message.owner?(session[:session_id])
    @message.update_attribute(:visits, @message.visits + 1)
    @message.decrypt!
  end
  if @message.delete_by_timeout! || @message.delete_by_visits!(session[:session_id])
    redirect "/message/#{@message.secure_id}"
  end
  @title = @message.title
  slim :"message/view"
end

# ---------------------------------
# edit message
# ---------------------------------
get '/message/:secure_id/edit' do
  redirect '/' unless find_message.owner?(session[:session_id])
  @title = 'Edit Form'
  flash[:success] = 'Message edited!'
  slim :"message/edit"
end

put '/message/:secure_id' do
  redirect '/' unless find_message.owner?(session[:session_id])
  @message.update_attribute(
    :destruction_value,
    params[:destruction][params[:message][:destruction]]
  )
  @message.update params[:message]
  redirect "/message/#{@message.secure_id}"
end

# ---------------------------------
# delete message
# ---------------------------------
delete '/message/:secure_id' do
  if find_message.owner?(session[:session_id]) && @message.destroy
    flash[:success] = "Message \"#{@message.title}\" deleted!"
  end
  redirect '/'
end
