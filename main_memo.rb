# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'cgi'

set :environment, :production

MEMOPATH = File.realpath('memo_data.csv')
IDPATH = File.realpath('id_data.csv')

def memo_data
  CSV.read(MEMOPATH, headers: true, header_converters: :symbol)
end

def id_max_plus1
  id_data = CSV.read(IDPATH).to_a
  id_max = id_data.map(&:join).map(&:to_i).max
  id_max.nil? ? 1 : id_max + 1
end

def id_add(id)
  CSV.open(IDPATH, 'a') do |csv|
    csv << [id]
  end
end

def add_memo(title, content)
  CSV.open(MEMOPATH, 'a') do |csv|
    csv << [title, content, id_max_plus1]
  end
  id_add(id_max_plus1)
end

def edit_memo(title, content, id)
  current_data = memo_data
  current_data.each do |c_d|
    if c_d[:id] == id
      c_d[:title] = title
      c_d[:content] = content
    end
  end
  overwrite_memo(current_data.to_a)
end

def delete_memo(id)
  current_data = memo_data
  current_data.delete_if do |c_d|
    c_d[:id] == id
  end

  overwrite_memo(current_data.to_a)
end

def overwrite_memo(new_data)
  CSV.open(MEMOPATH, 'w') do |csv|
    new_data.each do |n_d|
      csv << n_d
    end
  end
end

def sanitize(params_data)
  CGI.escapeHTML(params_data)
end

get '/' do
  redirect '/top_memo'
end

get '/top_memo' do
  @top_data = memo_data

  erb :top_memo
end

get '/new_memo' do
  erb :new_memo
end

post '/create_memo' do
  add_memo(sanitize(params[:new_title]), sanitize(params[:new_content]))

  redirect '/top_memo'
end

get '/show_memo/:id' do
  link_id = params[:id]
  @link_data = memo_data.find { |d| d[:id] == link_id }

  erb :show_memo
end

get '/edit_memo/:id' do
  link_id = params[:id]
  @link_data = memo_data.find { |d| d[:id] == link_id }

  erb :edit_memo
end

patch '/edit_memo' do
  edit_memo(sanitize(params[:edit_title]), sanitize(params[:edit_content]), params[:edit_id])

  redirect '/top_memo'
end

delete '/delete_memo' do
  delete_memo(params[:delete_id])

  redirect '/top_memo'
end
