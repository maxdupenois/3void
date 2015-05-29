class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def index
    render :index, locals: { latest_article: latest_article }
  end

  private

  def latest_article
    @latest_article ||= Marti::Marticle.articles
      .select(&:published).first
  end
end
