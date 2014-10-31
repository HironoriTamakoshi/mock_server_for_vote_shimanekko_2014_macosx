require 'yaml'
require 'date'


class Account
  VOTED_DATE = Date.today
  attr_reader :id
  attr_accessor :vote_date

  def initialize(id)
      @id = id
      @vote_date = Account.access_db[id]["vote_date"]
  end

  #今日投票した場合に呼び出す
  def voted
    self.vote_date = VOTED_DATE
  end

  #今日投票しているかを調べる
  def vote_today?
  	  self.vote_date == VOTED_DATE
  end

  #postされてきたアカウントがDBに存在するかどうか調べる
  def self.find(email,password)
    Account.access_db.each_with_index do |db,id|
      return id if  db["email"] == email && db["password"] = password
    end
    return false
  end
  #yamlファイルに保存するデータを更新する
  def set_new_data
  	  new_data = Account.access_db
  	  new_data[id]["vote_date"] = vote_date
  	  return new_data
  end

  #データを更新するためにdb.ymlをファイルサイズゼロの状態で開いて書き込む
  def self.save(data)
    yaml_data = YAML.dump(data)
    File.open("db.yml",File::WRONLY | File::TRUNC){|f|f.write(yaml_data)}
  end

  #データベースの代わりになっているdb.ymlからデータを取ってくる
  def self.access_db
    YAML.load(File.open(DOCUMENT_ROOT+'/db.yml'))
  end

end




