class Mechanize::Page
  def debug
    File.write('/tmp/page.html',body)
  end
end