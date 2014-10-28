require "socket"

#ルートの設定
DOCUMENT_ROOT = File.expand_path("../", __FILE__)
MESSAGE =<<EOF
HTTP/1.1 200 OK
Content-Type: test/html; charset=UTF-8
Server: tama
Transfer-Encoding: chunked
Connection: close

EOF

begin
  #ポート番号8000でopen
  server = TCPServer.open(8000);

  while true
    #クライアントからの接続を待つ
    puts "クライアントからの接続を待ちます"
    Thread.start(server.accept) do |socket|        
      while(request = socket.gets)
        break if request.include? "END"
        p request
        #リクエストGETに対してhtmlを返す
        if request.include? "GET"
          content = File.open("#{DOCUMENT_ROOT}/test.html"){ |f| f.read }
          socket.write (MESSAGE+content)
        end
      end
      #クライアントとの接続ソケットを閉じる
      sock.close
    end
  end

  #待ち受けソケットを閉じる
  server.close
rescue => e
  p e
  p e.backtrace
end
