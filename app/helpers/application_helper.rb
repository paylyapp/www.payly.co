module ApplicationHelper
  def current_page(path)
    "active" if current_page?(path)
  end

  def current_section(section)
    "active" if @current_section == section
  end
end
