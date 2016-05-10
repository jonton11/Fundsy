module ApplicationHelper # :nodoc:
  def formatted_date(date)
    date.strftime('%Y-%b-%d') if date
  end
end
