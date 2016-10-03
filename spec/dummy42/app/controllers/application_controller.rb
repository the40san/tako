class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :select_shard2

  private

  def select_shard2(&block)
    Tako.shard(:shard02, &block)
  end
end
