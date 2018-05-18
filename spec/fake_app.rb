require 'rails'
require 'active_record/railtie'

class FakeApp < Rails::Application
  config.secret_key_base = config.secret_token = [*'A'..'z'].join
  config.session_store :cookie_store, :key => '_myapp_session'
  config.active_support.deprecation = :log
  config.eager_load = false
  config.root = __dir__
end
FakeApp.initialize!
