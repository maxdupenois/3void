module ApplicationHelper
  def nav_active(path)
    request.path == path ? "active" : ""
  end
end
