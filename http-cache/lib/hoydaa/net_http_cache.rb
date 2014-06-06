require_relative './http_cache'

module Net

  class HTTP

    def HTTP.get(uri_or_host, path = nil, port = nil)
      #binding.pry
      if (Hoydaa::Cache.cacheable?(uri_or_host))
        rtn = Hoydaa::Cache.cached?(uri_or_host)
        if rtn 
          p "cached! :)"
          return rtn
        end
        rtn = get_response(uri_or_host, path, port).body
        Hoydaa::Cache.store(uri_or_host, rtn)
        rtn
      else
        p "downloading..."
        get_response(uri_or_host, path, port).body
      end
    end

  end

end