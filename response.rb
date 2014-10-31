require 'uri'
require './account.rb'
require 'erb'
DOCUMENT_ROOT = File.expand_path("../",__FILE__)


class Responce
  DEFAULT_STATUS = "HTTP/1.1 200 OK"
  DEFAULT_HEADER = "Connection: close\r\nContent-Type: text/html; charset=utf-8\r\n\r\n"
  ALERT_MESSAGE = "メールアドレス又はパスワードが違います"
  RESULT_MESSAGE = {
                 :complete => "投票完了",
                 :already => "本日は既に投票済みです",
                 :error => "不明なエラーです"
                 }
  attr_accessor :status,:header,:body,:account

  def initialize(sock,req)
    @status = DEFAULT_STATUS
    @header = DEFAULT_HEADER
    deal_with_req(sock,req)
  end

  #リクエストに対するレスポンス処理の大本
  def deal_with_req(sock,req)
    case req.http_method 
    when "GET"
      responce_for_get(sock,req)
    when "POST"
      #リクエストヘッダのボディからemailとpasswordを取得し、一時変数に格納
      tmp = URI.unescape(req.body).split("&").select{|data|data.slice!(/.+=/)}
      result_message_status = check_status(tmp)
      response_for_post(sock,req,result_message_status)
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

  #レスポンスをソケットに書き込む
  def writing_response(sock)
     sock.write @status
     sock.write @header
     sock.write @body
  end

  #GETリクエストに対する処理
  def responce_for_get(sock,req)
    deal_with_path(req.path)
    writing_response sock
  end

  #POSTリクエストに対する処理(ステータスが:completeならアカウントを保存する)
  def response_for_post(sock,req,result_message_status)
    result_message = RESULT_MESSAGE[result_message_status]
    if result_message_status == :complete
      @account.voted
      Account.save(@account.set_new_data)
    end
    deal_with_path(req.path,result_message,nil)
    writing_response(sock)
  end

  #既に投票したか、投票前か、アカウントが存在しないかをチェックする
  def check_status(tmp)
    if(id = Account.find(tmp[0],tmp[1]))
      @account = Account.new(id)
      return (@account && @account.vote_today?) ? :already : :complete
    else
      return :error
    end
  end
end
