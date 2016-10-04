module WebsiteHelpers
  def title
    @title ? @title : 'Welcome'
  end

  def find_message
    @message = Message.find_by(secure_id: params[:secure_id])&.decrypt!
    if @message.nil?
      flash[:danger] = 'Invalid message url!'
      redirect '/'
    end
    @message
  end

  def destruction_value(field_name)
    @message.destruction == field_name ? @message.destruction_value : 1
  end
end
