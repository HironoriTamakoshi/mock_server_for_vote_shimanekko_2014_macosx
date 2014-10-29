require "pry"

DOCUMENT_ROOT = File.expand_path("../",__FILE__)
class Controller
  def login_check(email,password)
    db_data.each do |data|
      if (data[0] == email && data[1] == password)
        return true
      else
        false
      end
    end
  end

  def db_data
     File.open(DOCUMENT_ROOT+"/db.txt") do |f|
       check_db = f.to_a.map{|data|data.chomp.split(":")}
      end
  end
end


cont = Controller.new
binding.pry
cont.login_check("tmks0820@email","tmks0820")
