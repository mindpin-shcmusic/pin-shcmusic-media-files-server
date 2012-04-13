module UploadServer
  class Server < Sinatra::Base
    enable :logging

    get "/" do
      haml :index
    end
    
    options '/upload' do
      response.headers["Access-Control-Allow-Origin"] = "http://dev.sns.yinyue.edu"
    end
    
    post '/upload' do
      response.headers["Access-Control-Allow-Origin"] = "http://dev.sns.yinyue.edu"

      # 保存文件

      multi_media = Multimedia.create(params[:file][:filename],params[:file][:tempfile])
      # 组装文件的 meta 信息
      meta_info = build_meta_info(multi_media)
      
      res = Net::HTTP.post_form(URI.parse('http://dev.sns.yinyue.edu/media_files/create_by_edu'),meta_info)
      if "200" == res.code
        res.body
      else
        status res.code.to_i
        res.body
      end
    end
    
    def build_meta_info(multi_media)
      type = params[:file][:type]
      creator_id = params[:creator_id]
      file_name = params[:file][:filename]
      
      par = {:name=>file_name,:type=>type,:size=>multi_media.file_size,:uuid=>multi_media.uuid,:creator_id=>creator_id}
      if multi_media.is_video?
        par[:video_encode_status] = "ENCODING" 
      end
      return par
    end
    
  end
end