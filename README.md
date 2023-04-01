# webapp_sinatra

このリポジトリはFjordBootCampのSinatraプラクティスの提出物です。

# memoアプリを立ち上げる手順
1. HomebrewでPostgreSQLをインストールし、起動します
```
$ brew install postgresql
$ brew services start postgresql
```
2. ユーザー(postgres)を作成します
```
$ psql -U${USER} postgres
```
3. データベース(memos_db)を作成します
```
$ psql -U postgres -c "CREATE DATABASE memos_db"
```
4. データベースにテーブルを作成します
```
$ psql -d memos_db -f initialize.sql
```
5. `Gemfile`に以下を記載します
```
gem "sinatra"
gem "sinatra-contrib"
gem "webrick"
gem "pg"
```
6. Bundlerでgemをインストールします
```
$ bundle install
```
7. 以下を実行しアプリケーションを立ち上げます
```
$ bundle exec ruby main_memo.rb
```
8. http://127.0.0.1:4567/memos にアクセスすると、メモアプリが使用できます
