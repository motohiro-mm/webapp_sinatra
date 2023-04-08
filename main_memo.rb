# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'cgi'

set :environment, :production

MEMOS = PG.connect(dbname: 'memos_db', user: 'postgres')

def add_memo(title, content)
  new_id = MEMOS.exec('SELECT * FROM ids').values.join.to_i + 1
  if new_id != 1
    MEMOS.exec_params('UPDATE ids SET id = $1', [new_id])
  else
    MEMOS.exec_params('INSERT INTO ids VALUES (1)')
  end
  MEMOS.exec_params('INSERT INTO memos VALUES($1,$2,$3)', [title, content, new_id])
end

def edit_memo(title, content, id)
  MEMOS.exec_params('UPDATE memos SET title = $1 , content = $2 WHERE id = $3', [title, content, id])
end

def delete_memo(id)
  MEMOS.exec_params('DELETE FROM memos WHERE id = $1', [id])
end

def escape_string(data)
  CGI.escapeHTML(data)
end

def target_memo(id)
  MEMOS.exec_params('SELECT * FROM memos WHERE id = $1', [id])
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @top_memos = MEMOS.exec('SELECT * FROM memos ORDER BY id')

  erb :top_memo
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  add_memo(params[:new_title], params[:new_content])

  redirect '/memos'
end

get '/memos/:id' do
  @target_memo = target_memo(params[:id])

  erb :show_memo
end

get '/memos/:id/edit' do
  @target_memo = target_memo(params[:id])

  erb :edit_memo
end

patch '/memos/:id' do
  edit_memo(params[:edit_title], params[:edit_content], params[:edit_id])

  redirect '/memos'
end

delete '/memos/:id' do
  delete_memo(params[:delete_id])

  redirect '/memos'
end
