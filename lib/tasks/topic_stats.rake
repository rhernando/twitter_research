namespace :tweets do
  desc 'retrieve random user from twitter'

  task :topics => :environment do

    totals = File.new('totals.tags', 'w')
    uniq = File.new('uniq.tags', 'w')

    ids_topic = FriendsSource.distinct(:friend_id)
    ids_topic.each do |idt|
      arr_top = []
      topics = FriendsSource.where(:friend_id => idt)
      topics.each do |tp|
        arr_top += tp.tags
      end
      totals.puts "#{idt} #{arr_top.count}"
      uniq.puts "#{idt} #{arr_top.uniq.count}"
    end

    totals.close
    uniq.close
  end
end


#TwitterUserData.order_by([:id_twitter, :desc]).first