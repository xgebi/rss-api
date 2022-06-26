class ArticleContentsFormatDuration < ActiveRecord::Migration[7.0]
  def change
    ArticleContent.all.each do |ac|
      if ac.itunes_duration
        if ac.itunes_duration.index(':')
          split = ac.itunes_duration.split(':')
          split = split.map do |segment| 
            segment = "0#{segment}" if segment.length == 1
            segment
          end
          case split.length
            when 2
              ac.itunes_duration = "00:#{split.join(':')}"
            when 3
              ac.itunes_duration = split.join(':')
          end
        end
        ac.save
      end
    end
  end
end
