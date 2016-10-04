module Sinatra
  module Flash
    # ----------------------------------------------------
    # Helper for rendering flash messages with Bootstrap
    # ----------------------------------------------------
    module Style
      def styled_flash(key = :flash)
        return '' if flash(key).empty?
        id = (key == :flash ? 'flash' : "flash_#{key}")
        close = '<a class="close" data-dismiss="alert" href="#">×</a>'
        messages = flash(key)
          .collect { |message| "  <div class='alert alert-#{message[0]}'>#{close}\n #{message[1]}</div>\n" }
        "<div id='#{id}'>\n" + messages.join + '</div>'
      end
    end
  end
end