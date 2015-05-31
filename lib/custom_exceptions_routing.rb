class CustomExceptionsRouting < ActionDispatch::PublicExceptions
  def call(env)
    status = env["PATH_INFO"][1..-1]

    # Only custom match 404
    if status == "404"
      Rails.application.routes.call(env)
    else
      super
    end
  end
end
