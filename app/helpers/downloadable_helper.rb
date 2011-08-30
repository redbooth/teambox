module DownloadableHelper
  
  def downloadable_name(downloadable)
    downloadable.class == Folder ? downloadable.name : downloadable.file_name
  end

  def downloadable_link(downloadable)
    downloadable.class == Folder ? public_download_folder_url(@downloadable.token) : public_download_file_url(@downloadable.token)
  end

end