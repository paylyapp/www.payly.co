module ApplicationHelper
  def current_page(path)
    "active" if current_page?(path)
  end
end
