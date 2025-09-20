module VideosHelper
  def video_embed_data(url)
    return nil unless url.present?

    # YouTube URL patterns
    youtube_regex = /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)/
    vimeo_regex = /vimeo\.com\/(\d+)/

    if match = url.match(youtube_regex)
      video_id = match[1]
      {
        id: video_id,
        platform: 'youtube',
        url: url,
        embed_url: "https://www.youtube.com/embed/#{video_id}",
        thumbnail_url: "https://img.youtube.com/vi/#{video_id}/maxresdefault.jpg",
        title: "Video #{video_id}"
      }
    elsif match = url.match(vimeo_regex)
      video_id = match[1]
      {
        id: video_id,
        platform: 'vimeo',
        url: url,
        embed_url: "https://player.vimeo.com/video/#{video_id}",
        thumbnail_url: "https://vumbnail.com/#{video_id}.jpg",
        title: "Video #{video_id}"
      }
    else
      # Generic video data for other URLs
      {
        id: nil,
        platform: 'other',
        url: url,
        embed_url: url,
        thumbnail_url: nil,
        title: "Video"
      }
    end
  end
end