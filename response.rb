require 'uri'
DOCUMENT_ROOT = File.expand_path("../",__FILE__)


class Responce
  DEFAULT_STATUS = "HTTP/1.1 200 OK"
  DEFAULT_HEADER = "Connection: close\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
  attr_accessor :status,:header,:body
  def initialize(sock,req)
    @status = DEFAULT_STATUS
    @header = DEFAULT_HEADER
    deal_with_req(sock,req)
  end

  def deal_with_req(sock,req)
    if req.http_method == "GET"
      deal_with_path(req.path)
      sock.write(@status)
      sock.write(@header)
      sock.write(@body)
    else req.http_method == "POST"
      deal_with_path(req.path)
      account = URI.unescape(req.body).split("&").select{|data|data.slice!(/.+=/)}
      if validation(account)
        sock.write(@status)
        sock.write(@header)
        sock.write(@body)
      end
    end
  end

  def deal_with_path(path)
    if path == "/vote/detail.php?id=00000021"
      @body = open_view_file("/vote.html")
    elsif path.include? "vote_page.html"
      @body = open_view_file("/vote_page.html")
    elsif path == "/vote_for_mock"
      @body = open_view_file("/result.html")
    end
  end

  def validation(account)
    db_info.each do |data|
      return true if account[0] == data[0] && account[1] == data[1]
    end
    return false
  end

  def db_info
    File.open(DOCUMENT_ROOT+"/db.txt") do |f|
       db_info = f.to_a.map{|data|data.chomp.split(":")}
    end
  end

  def open_view_file(path)
    File.open(DOCUMENT_ROOT+path) do |f|
      f.read
    end
  end
end
