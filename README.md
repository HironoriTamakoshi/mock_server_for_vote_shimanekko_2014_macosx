# モックサーバーアプリ
[ゆるキャラグランプリ2014](http://www.yurugp.jp/)にてしまねっこに投票するアプリ[vote_shimanekko_2014_macosx](https://github.com/hasumon/vote_shimanekko_2014_macosx)  
のモックサーバーアプリです。

## クライアント（しまねっこ投票アプリ）側の設定

1. *configs.sample*を*configs*にリネーム  

        $mv configs.sample configs

2. *configs*に以下のように":"で区切ってメールアドレスとパスワードとユーザーエージェントを設定  

        test@example.com:password:Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Versio    n/4.0.4 Safari/531.21.10
        test2@example.com:password2:Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)
        //複数行設定可能 以下略

     *ユーザーエージェント一覧

        Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)
        Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)
        Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6
        Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10
        Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6
        Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401
        Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624
        Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.1) Gecko/20100122 firefox/3.6.1
        Mozilla/5.0 (compatible; Konqueror/3; Linux)
        Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3
        WWW-Mechanize/#{VERSION} (http://rubyforge.org/projects/mechanize/)

3. vote.rbの変更  
   #####変更前

        #23行目
        #...(略)
        agent.redirect_ok = true
        agent.follow_meta_refresh = true
        #...(略)
        #32行目
        start_page = account[:agent].get('http://www.yurugp.jp/vote/detail.php?id=00000021')
    #####変更後

        #...(略)
        #23行目
        agent.redirect_ok = true
        agent.keep_alive=false   #この行を加える
        agent.follow_meta_refresh = true
        #...(略)
        #32行目
        start_page = account[:agent].get('http://localhost:8000/vote/detail.php?id=00000021') #ホスト名の変更


## サーバー（このアプリ）側の設定
1. db_sampleをdb.ymlにリネーム

        $mv db_sample db.yml
        
2. db.ymlにクライアント側のアカウントのメールアドレスとパスワードを記入する(yamlのハッシュの配列)  

```
---
-
 email: example.com
 password: password
 vote_day:             #ここは自動的に入力されるため最初は記入しないでください。
                          
-
 email: example2.com
 password: password2
 vote_day:             #ここは自動的に入力されるため最初は記入しないでください。

# 複数設定可能　以下略
```

## 使用方法

1. モックサーバー起動

        $cd mock_server_for_vote_shimanekko_2014_macosx
        $ruby mock_server.rb

2. 別ウィンドウでしまねっこ投票アプリを起動

        $cd vote_shimanekko_2014_macosx
        $open vote.app

3. ログの確認
        
        $cat log/'その日の日付'.log

4. モックサーバーの終了

        Ctrl+C















