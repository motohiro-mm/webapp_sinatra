# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'cgi'

set :environment, :production

MEMOPATH = File.realpath('memo_data.csv')
IDPATH = File.realpath('id_data.csv')

def memos
  CSV.read(MEMOPATH, headers: true, header_converters: :symbol)
end

def new_id
  updated_id = CSV.read(IDPATH).join.to_i + 1
  CSV.open(IDPATH, 'w') do |csv|
    csv << [updated_id]
  end
  updated_id
end

def add_memo(title, content)
  CSV.open(MEMOPATH, 'a') do |csv|
    csv << [title, content, new_id]
  end
end

def edit_memo(title, content, id)
  current_memos = memos
  current_memos.each do |current_memo|
    if current_memo[:id] == id
      current_memo[:title] = title
      current_memo[:content] = content
    end
  end
  overwrite_memos(current_memos.to_a)
end

def delete_memo(id)
  current_memos = memos
  current_memos.delete_if do |current_memo|
    current_memo[:id] == id
  end

  overwrite_memos(current_memos.to_a)
end

def overwrite_memos(new_memos)
  CSV.open(MEMOPATH, 'w') do |csv|
    new_memos.each do |new_memo|
      csv << new_memo
    end
  end
end

def sanitize(data)
  CGI.escapeHTML(data)
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @top_memos = memos

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
  @target_memo = memos.find { |memo| memo[:id] == params[:id] }

  erb :show_memo
end

get '/memos/:id/edit' do
  @target_memo = memos.find { |memo| memo[:id] == params[:id] }

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
