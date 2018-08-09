# frozen_string_literal: true

module Helpers::Html
  def before_write_response(response)
    # html_result = response.body.first
    # binding.pry if html_result.start_with?('{', '[')
    # return if html_result.start_with?('{', '[')

    # document = Nokogiri::HTML(response.body.first)
    # last_element = document.search('body *:last').first
    # last_script = document.search('script:last').first

    # last_element&.add_next_sibling %(
    #   <input type="hidden" id="proxy_base" value="#{response.headers['proxy_base']}"/>
    # )

    # last_script&.add_next_sibling %{
    #   <script>
    #     var o = XMLHttpRequest.prototype.open;
    #     XMLHttpRequest.prototype.open = function(){
    #       var res = o.apply(this, arguments);
    #       this.setRequestHeader('proxy_base', jQuery('#proxy_base').attr('value'));
    #       return res;
    #     }
    #   </script>
    # }
    # response.body[0] = document.to_html
  end
end
