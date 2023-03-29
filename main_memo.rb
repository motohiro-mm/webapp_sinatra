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
  id_max = CSV.read(IDPATH).last.join.to_i
  update_id = id_max.nil? ? 1 : id_max + 1
  CSV.open(IDPATH, 'a') do |csv|
    csv << [update_id]
  end
  update_id
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

post '/create_memo' do
  add_memo(params[:new_title], params[:new_content])

  redirect '/memos'
end

get '/memos/:id' do
  link_id = params[:id]
  @link_memo = memos.find { |memo| memo[:id] == link_id }

  erb :show_memo
end

get '/memos/:id/edit' do
  link_id = params[:id]
  @link_memo = memos.find { |memo| memo[:id] == link_id }

  erb :edit_memo
end

patch '/edit_memo' do
  edit_memo(params[:edit_title], params[:edit_content], params[:edit_id])

  redirect '/memos'
end

delete '/delete_memo' do
  delete_memo(params[:delete_id])

  redirect '/memos'
end
