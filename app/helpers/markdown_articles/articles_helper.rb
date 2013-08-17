module MarkdownArticles
  module ArticlesHelper 
    def pretty_date(date)
      date.strftime("%d %b %y %H:%M")
    end
  end
end
