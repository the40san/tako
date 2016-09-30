class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  around_filter :sharding

  private

  def sharding(&block)
    Tako.shard(:shard01, &block)
  end
end
