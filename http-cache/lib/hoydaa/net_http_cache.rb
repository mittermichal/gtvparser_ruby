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
      uri_post = uri_or_host#.to_s+params.sort.to_s
      #{:test => 1, :aaa => 2}.sort.each do |k,v| '#{k}=#{v}&' end
      if (Hoydaa::Cache.cacheable?(uri_post))
        rtn = Hoydaa::Cache.cached?(uri_post)
        if rtn 
          p "cached! :)"
          return rtn
        end

      p "c downloading..."
      req = Post.new(uri_or_host)
      req.form_data = params
      req.basic_auth url.user, url.password if url.user
      ret = new(url.hostname, url.port).start {|http|
          http.request(req)
      }.body

        Hoydaa::Cache.store(uri_post, rtn)
        rtn
      else
        p "downloading..."
      req = Post.new(uri_or_host)
      req.form_data = params
      req.basic_auth url.user, url.password if url.user
      new(url.hostname, url.port).start {|http|
          http.request(req)
      }.body
      end
    end

  end

end