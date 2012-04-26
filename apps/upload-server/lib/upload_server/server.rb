module UploadServer
  class Server < Sinatra::Base
    enable :logging

    get "/" do
      haml :index
    end

    options '/new_upload' do
      add_cross_domain_response_header
    end

    options '/upload_blob' do
      add_cross_domain_response_header
    end

    post '/new_upload' do
      add_cross_domain_response_header
      file_name = params[:file_name]
      file_size = params[:file_size]
      creator_id = params[:creator_id]
    
      slice_temp_file = SliceTempFile.get_or_create(file_name,file_size,creator_id)
      if !slice_temp_file.valid?
        error = slice_temp_file.errors.first
        status 422
        return "#{error[0]} #{error[1]}"
      end
      status 200
      slice_temp_file.saved_size.to_s
    end

    post '/upload_blob' do
      begin
        add_cross_domain_response_header
        file_name = params[:file_name]
        file_size = params[:file_size]
        file_blob = params[:file_blob][:tempfile]
        creator_id = params[:creator_id]
      
        slice_temp_file = SliceTempFile.get(file_name,file_size,creator_id)
        slice_temp_file.save_new_blob!(file_blob)
        
        res = {:saved_size => slice_temp_file.saved_size}
        status 200
        res.to_json
      rescue Exception=>ex
        p ex.message
        puts ex.backtrace*"\n"
        status 500
        ex.message
      end
    end

    def add_cross_domain_response_header
      response.headers["Access-Control-Allow-Origin"] = PIN_2012_EDU_SITE
    end
    
  end
end