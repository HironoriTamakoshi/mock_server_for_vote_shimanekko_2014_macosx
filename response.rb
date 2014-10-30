require 'uri'
DOCUMENT_ROOT = File.expand_path("../",__FILE__)
class Account < Struct.new(:email,:password)
end

class Responce
  DEFAULT_STATUS = "HTTP/1.1 200 OK"
  DEFAULT_HEADER = "Connection: close\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
  SUCCESS_RESULT_PAGE =<<HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Mock Server</title>
  </head>
  <body>
    <p>Mock Server</p>
    <div class="section">
      <p>投票完了</p>
    </div>
  </body>
</html>
HTML
  FALSE_RESULT_PAGE =<<HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Mock Server</title>
  </head>
  <body>
    <p>Mock Server</p>
    <div class="section">
      <p>本日は既に投票済みです</p>
    </div>
  </body>
</html>
HTML

  attr_accessor :status,:header,:body,:cookie,:account,:result_message
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
      tmp = URI.unescape(req.body).split("&").select{|data|data.slice!(/.+=/)}
      @account = Account.new(tmp[0],tmp[1])
      if validation
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
      @body = FALSE_RESULT_PAGE
    end
  end

  def validation
    db_info.each do |data|
      return true if account.email == data[0] && account.password == data[1]
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
