module Graphs
  require 'rgl/adjacency'
  require 'rgl/dot'

  def self.create_graph(user)
    arr_users = []
    TwitterUserData.all.each do |ud|
      if ud.arr_followers.present?
        ud.arr_followers.each do |f|
          arr_users << [f, ud.id]
        end
      end
      if ud.arr_friends.present?
        ud.arr_friends.each do |f|
          arr_users << [ud.id, f]
        end
      end
    end

    dg=RGL::DirectedAdjacencyGraph[]
    arr_users.each do |e|
      dg.add_edge(e[0], e[1])
    end


  end

  def self.save_graph(dg, name='graph')
    dg.write_to_graphic_file('jpg', name)
  end

end