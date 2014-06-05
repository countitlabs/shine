require 'shine/version'
require 'httparty'

module Shine

  class ShineError < Exception
    def initialize(op, resp)
      super "Error performing #{op}: #{resp.response} : #{resp.parsed_response}"
    end
  end


  class Client
    include HTTParty

    base_uri "https://api.misfitwearables.com/move/resource/v1"


    # Initialize in the context of a user.
    #
    # @param token [String] the user token
    #
    def initialize(token)
      @token = token
      @options = {}
      if token
        @options[:headers] = { "access_token" => "#{@token}" }
      end
    end


    # Subscribe to notifications.
    # MISFIT subscriptions are application based, not user based.
    #
    # @param rsrc [Symbol] the resource, one of :sessions,
    #        :profiles, :devices, :sleeps
    #
    # @param conf [Hash] Application api keys. Must include :key and
    #        :secret
    #
    # @return [Bool] true on success. Raise error on error.
    #
    def subscribe(rsrc, endpoint, conf={})
      opts = { :query => { :endpoint => endpoint } }
      opts.merge! @options

      set_id_and_secret(opts, conf)

      response = self.class.post("/subscriptions/#{rsrc}", opts)
      if response.success?
        return true
      else
        raise Device::ShineError.new(:subscribe, response)
      end
    end


    # Unsubscribe from notifications.
    #
    # @param conf [Hash] Application api keys. Must include :key and
    #        :secret
    #
    # @param rsrc [Symbol] see #subscribe
    # @return [Bool] true on success, throws errors on fail.
    #
    def unsubscribe(rsrc, conf={})
      opts = @options.clone
      set_id_and_secret(opts, conf)
      response = self.class.delete("/subscriptions/#{rsrc}", opts)
      if response.success?
        return true
      else
        raise Device::ShineError.new(:subscribe, response)
      end
    end


    # Get user profile
    #
    # sample response: {"userId"=>"54f3....3c9d3", "name"=>nil, "birthday"=>"1970-01-01", "gender"=>"female", "email"=>"xx@yahoo.com"}
    #
    def profile
      raise "no token configured" unless @token
      response = self.class.get('/user/me/profile', @options)
      if response.success?
        return response
      else
        raise Device::ShineError.new(:profile, response)
      end
    end


    # Get user summary.
    #
    # @return [Hash] with key 'summary' which is an array of objects like this:
    #    {"date"=>"2014-04-01", "points"=>668.8, "steps"=>6292, "calories"=>0, "activityCalories"=>0, "distance"=>2.2031}
    #
    def summary(start_date, end_date)
      raise "no token configured" unless @token
      opts = { :query => { 'start_date' => start_date, 'end_date' => end_date, 'detail' => true } }
      opts.merge! @options
      response = self.class.get('/user/me/activity/summary', opts)
      if response.success?
        return response
      else
        raise Device::ShineError.new(:profile, response)
      end
    end


    # Get sessions over date range.
    #
    # @return [Hash] with 'sessions' property which is an array of objects like this:
    #    { "activityType" : "Walking",
    #       "calories" : 93.526200000000003,
    #       "distance" : 0.97389999999999999,
    #       "duration" : 1440,
    #       "id" : "5352e44e5b77e521530a1ba7",
    #       "points" : 252.80000000000001,
    #       "startTime" : "2014-04-03T15:58:57.000Z",
    #       "steps" : 2392 }
    #
    #
    def sessions(start_date, end_date)
      raise "no token configured" unless @token
      opts = { :query => { 'start_date' => start_date, 'end_date' => end_date } }
      opts.merge! @options
      response = self.class.get('/user/me/activity/sessions', opts)
      if response.success?
        return response
      else
        raise Device::ShineError.new(:profile, response)
      end
    end


    private
    def set_id_and_secret(opts, cfg)
      raise "missing conf key 'key'" unless cfg.key?(:key)
      raise "missing conf key 'secret'" unless cfg.key?(:secret)

      opts[:headers] = Hash.new unless opts[:headers]
      opts[:headers]['app_id'] = cfg[:key]
      opts[:headers]['app_secret'] = cfg[:secret]
      opts
    end

  end

end
