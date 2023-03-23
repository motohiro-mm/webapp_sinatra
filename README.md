# webapp_sinatra

このリポジトリはFjordBootCampのSinatraプラクティスの提出物です。

# memoアプリを立ち上げる手順

1. `Gemfile`に以下を記載します
```
gem "sinatra"
gem "sinatra-contrib"
gem "webrick"
```
2. Bundlerでgemをインストールします
```
$ bundle install
```
3. 以下を実行しアプリケーションを立ち上げます
```
$ bundle exec ruby main_memo.rb
```
4. http://127.0.0.1:4567/top_memo にアクセスすると、メモアプリが使用できます
