require 'sinatra'
require 'digest'
require 'json'
require 'tempfile'
require 'google/cloud/storage'
storage = Google::Cloud::Storage.new(project_id: 'cs291-f19')
bucket = storage.bucket 'cs291_project2', skip_lookup: true

path_regex = /\A[A-Fa-f0-9]{2}\/[A-Fa-f0-9]{2}\/[A-Fa-f0-9]{60}\z/
digest_regex = /\A[A-Fa-f0-9]{64}\z/

get '/' do
  redirect to('/files/'), 302
end

# post '/' do
#   require 'pp'
#   PP.pp request
#   "POST\n"
# end

get '/files/' do
  file_arr = []
  bucket.files.each do |file|
    if file.name.match(path_regex)
      file_arr << file.name.tr('/', '')
    end
  end
  content_type :json
  "[\"#{file_arr.join("\",\"")}\"]"
end

post '/files/' do
  # puts params
  return 422 unless params[:file] && params[:file].is_a?(Hash) && params[:file][:tempfile] && params[:file][:tempfile].is_a?(Tempfile)
  file = params[:file][:tempfile]
  return 422 if file.size > 1024 * 1024
  file.rewind
  file_digest = Digest::SHA256.hexdigest file.read

  # puts file_digest

  # io = StringIO.new
  # io.puts file
  file_path = file_digest.dup
  file_path.insert(4,'/').insert(2,'/')
  return 409 if bucket.file file_path
  file.rewind
  bucket.create_file file, file_path , content_type: params[:file][:type]

  # PP.pp request

  content_type :json
  return 201, JSON.generate( "uploaded" => file_digest )
  # params.inspect
  # params.class
end

get '/files/:filename' do
    return 422 unless params['filename'].match(digest_regex)
    target_file = bucket.file params['filename'].insert(4,'/').insert(2,'/').downcase
    return 404 unless target_file
    downloaded = target_file.download
    downloaded.rewind
    content_type target_file.content_type
    return downloaded.read
end

delete '/files/:filename' do
  return 422 unless params['filename'].match(digest_regex)
  target_file = bucket.file params['filename'].insert(4,'/').insert(2,'/').downcase
  target_file.delete if target_file
  return 200
end