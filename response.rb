require 'uri'
require './account.rb'
require 'erb'
DOCUMENT_ROOT = File.expand_path("../",__FILE__)


class Responce
  DEFAULT_STATUS = "HTTP/1.1 200 OK"
  DEFAULT_HEADER = "Connection: close\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
  ALERT_MESSAGE = "メールアドレス又はパスワードが違います"

  attr_accessor :status,:header,:body,:cookie,:account
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
      #リクエストヘッダのボディからemailとpasswordを取得し、一時変数に格納
      tmp = URI.unescape(req.body).split("&").select{|data|data.slice!(/.+=/)}
      #得られたemailとpasswordが一致するアカウントが存在する場合のみにAccountクラスのインスタンスを作成
      if (id = Account.find(tmp[0],tmp[1]))
        @account = Account.new(id)

        if @account && @account.vote_today?
          result_message = "本日は既に投票済みです"
          deal_with_path(req.path,result_message)
          sock.write(@status)
          sock.write(@header)
          sock.write(@body)
        elsif @account
          result_message = "投票完了"
          #投票したことを設定
          @account.voted
          Account.save(@account.set_new_data)
          deal_with_path(req.path,result_message)
          sock.write(@status)
          sock.write(@header)
          sock.write(@body)
        end
      else
        result_message = "不明なエラーです"
        deal_with_path(req.path,result_message,ALERT_MESSAGE)
        sock.write(@status)
        sock.write(@header)
        sock.write(@body)
      end
    end
  end

  #パスを解析し、レスポンスのボディを返す
  def deal_with_path(path,result_message=nil,alert=nil)
    if path == "/vote/detail.php?id=00000021"
      @body = open_view_file("/vote.html")
    elsif path.include? "vote_page.html"
      @body = open_view_file("/vote_page.html")
    elsif path == "/vote_for_mock"
      @result_message = result_message
      @alert = alert
      @body = eval(ERB.new(open_view_file("/result.html.erb")).src)
    end
  end

  #htmlファイルを探す
  def open_view_file(path)
    File.open(DOCUMENT_ROOT+path) do |f|
      f.read
    end
  end

  def not_found
  end
end
