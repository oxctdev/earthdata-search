module Echo
  class Client
    def self.client_for_environment(env, service_configs, use_cmr)
      service_config = service_configs['earthdata'][env]
      urs_client_id = service_configs['urs'][Rails.env.to_s][service_config['urs_root']]
      Echo::Client.new(service_config, urs_client_id, use_cmr)
    end

    def initialize(service_config, urs_client_id, use_cmr)
      @config = service_config
      clients = []
      clients << CmrClient.new(@config['cmr_root'], urs_client_id) if @config['enable_cmr'] || use_cmr
      clients << EchoClient.new(@config['echo_root'], urs_client_id)
      clients << UrsClient.new(@config['urs_root'], urs_client_id)
      @clients = clients
    end

    def method_missing(method_name, *arguments, &block)
      client = @clients.find {|c| c.respond_to?(method_name)}
      if client
        client.send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      @clients.any? {|c| c.respond_to?(method_name, include_private)} || super
    end
  end
end
