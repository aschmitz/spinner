class MopidyClient
  include Singleton
  
  def initialize
    connection = Faraday.new do |connection|
      connection.adapter Faraday.default_adapter
      if Rails.application.secrets.mopidy[:username]
        connection.basic_auth(
          Rails.application.secrets.mopidy[:username],
          Rails.application.secrets.mopidy[:password]
        )
      end
    end
    @client = JSONRPC::Client.new(Rails.application.secrets.mopidy[:uri], { connection: connection })
  end
  
  def invoke(method_name, args = [])
    @client.invoke(method_name, args)
  end
end
