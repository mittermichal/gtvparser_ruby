require_relative './http_cache'

module Net

  class HTTP

    def HTTP.get(uri_or_host, path = nil, port = nil)
      if (Hoydaa::Cache.cacheable?(uri_or_host))
        rtn = Hoydaa::Cache.cached?(uri_or_host)
        if rtn 
          p "cached! :)"
          return rtn
        end
        p "c downloading..."
        rtn = get_response(uri_or_host, path, port).body
        Hoydaa::Cache.store(uri_or_host, rtn)
        rtn
      else
        p "downloading..."
        get_response(uri_or_host, path, port).body
      end
    end

    def HTTP.post_form(uri_or_host, params)
      uri_post = URI(uri_or_host.to_s+URI.encode_www_form(params.sort))
      #{:test => 1, :aaa => 2}.sort.each do |k,v| '#{k}=#{v}&' end . join('&')
      if (Hoydaa::Cache.cacheable?(uri_post))
        rtn = Hoydaa::Cache.cached?(uri_post)
        if rtn 
          #p "cached! :)"
          return rtn
        end

      #p "c downloading..."
      req = Post.new(uri_or_host.request_uri)
      req.form_data = params
      req.basic_auth uri_or_host.user, uri_or_host.password if uri_or_host.user
      rtn = new(uri_or_host.hostname, uri_or_host.port).start {|http|
          http.request(req)
      }.body
        Hoydaa::Cache.store(uri_post, rtn)
        rtn
      else
        #p "downloading..."
      req = Post.new(uri_or_host.request_uri)
      req.form_data = params
      req.basic_auth uri_or_host.user, uri_or_host.password if uri_or_host.user
      rtn = new(uri_or_host.hostname, uri_or_host.port).start {|http|
          http.request(req)
      }.body
      rtn
      end
    end

  end

end