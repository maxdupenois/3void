module Marti
  module MarticlesHelper 
    include ::ApplicationHelper
    def pretty_date(date)
      date.strftime("%d %b %y %H:%M")
    end
  end
end
