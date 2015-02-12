module ApplicationHelper

  # Return base title as append or standalone depending on page
  def title(page_title='')
    base_title = "Stratagem"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
  
end
