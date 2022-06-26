class ArticleContentsDurationStandardization < ActiveRecord::Migration[7.0]
  def change
    add_column :article_contents, :duration_raw, :integer

    ArticleContent.reset_column_information
    ArticleContent.all.each do |ac|
      if ac.itunes_duration
        if ac.itunes_duration.index(':')
          split = ac.itunes_duration.split(':').reverse
          ac.duration_raw = split[0].to_i + (60 * (split[1].to_i + (60 * split[2].to_i)))
        else
          ac.duration_raw = ac.itunes_duration.to_i
          hours = ac.duration_raw / 3600
          minutes = (ac.duration_raw - (hours * 3600)) / 60
          seconds = ac.duration_raw - (hours * 3600) - (minutes * 60)

          hours = "0#{hours}" if hours < 10
          minutes = "0#{minutes}" if minutes < 10
          seconds = "0#{seconds}" if seconds < 10

          ac.itunes_duration = "#{hours}:#{minutes}:#{seconds}"
        end
        ac.save
      end
    end
  end
end
