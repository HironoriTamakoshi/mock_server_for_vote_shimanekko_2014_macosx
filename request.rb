class Request
  attr_reader :http_method,:path,:header,:body

  def initialize(socket)
    handle_request(socket)
  end

  def handle_request(socket)
    buffer = []
    while(buf = socket.gets)
      buffer << buf
      break if buf =="\r\n"
    end
    handle_method_and_path(buffer[0])
    @header = buffer[1..-1]
    if @http_method == "POST"
      content_length = @header[-2].slice(/(\d+)/).to_i
      @body = socket.read(content_length)
    end
  end

  def handle_method_and_path(req)
    matches = req.match(/([A-Z]+)\s(\/.*)\s./)
    @http_method = matches[1]
    @path = matches[2]
  end

  def to_s
<<-EOF
#{@http_method} #{path} HTTP/1.1\r
#{@header.join}
#{@body}
EOF
  end
end
