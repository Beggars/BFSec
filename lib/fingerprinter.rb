class Fingerprinters

  attr_reader :page

  def initialize(page)
    @page = page
  end

  # @abstract
  def run
  end

  def html?
    @is_html ||= page.response.headers['content-type'].to_s.downcase.include?('text/html')
  end

  def server_or_powered_by_include?(string)
    server.include?(string.downcase) || powered_by.include?(string.downcase)
  end

  def uri
    uri_parse(page.uri)
  end

  def parameters
    @parameters ||= page.query_vars.downcase
  end

  def cookies
    @cookies ||= page.cookies.inject({}){|h,c| h.merge! c.simple}.downcase
  end

  def headers
    @headers ||= page.response.headers.downcase
  end

  def powered_by
    headers['x-powered-by'].to_s.downcase
  end

  def server
    headers['server'].to_s.downcase
  end

  def extension
    @extension ||= uri_parse( page.url ).resource_extension.to_s.downcase
  end

  def platforms
    page.platforms
  end

end
