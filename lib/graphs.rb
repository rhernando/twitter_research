module Graphs
  require 'rgl/adjacency'
  require 'rgl/dot'

  require "rinruby"

  def self.network_array(user)
    arr_network = []

    arr_network += nw_edges(user.arr_followers, user.id)
    arr_network += nw_edges(user.arr_friends, user.id, true)

    user.arr_followers.each do |f|
      foll = TwitterUserData.find f
      arr_network += nw_edges(foll.arr_followers, foll.id)
      arr_network += nw_edges(foll.arr_friends, foll.id, true)
    end
    user.arr_friends.each do |f|
      friend = TwitterUserData.find f
      arr_network += nw_edges(friend.arr_followers, friend.id)
      arr_network += nw_edges(friend.arr_friends, friend.id, true)
    end

    arr_network
  end

  def self.create_graph(user)
    arr_network = network_array(user)

    dg=RGL::DirectedAdjacencyGraph[]
    arr_network.each do |e|
      dg.add_edge(TwitterUserData.find(e[0]), TwitterUserData.find(e[1]))
    end


    save_graph(dg)

    dg

  end

  def self.save_graph(dg, name='graph')
    dg.write_to_graphic_file('jpg', name)
  end

  def self.nw_edges(arr_users, iduser, user_first=false)
    return [] unless arr_users.present?

    nw_edges = []
    arr_users.each do |f|
      if user_first
        nw_edges << [iduser, f]
      else
        nw_edges << [f, iduser]
      end
    end
    nw_edges
  end

  def self.names_network(nwa)
    net_names = []

    nwa.each do |e|
      net_names << [TwitterUserData.find(e[0]).name, TwitterUserData.find(e[1]).name]
    end

    net_names
  end

  def self.r_network(net_names, username=nil)


    # print to file
    file = File.new('networkmatrix.txt', 'w')
    net_names.each do |el|
      file.puts el.join("|")
    end
    file.close

    myr = RinRuby.new({:interactive => false, :echo => true})


    myr.assign 'filename', "app/assets/images/graphs/#{(username || 'default')}.svg"
    myr.eval "svg(filename);"

    myr.eval <<EOF
    library(igraph)

    vnet = read.table("networkmatrix.txt", header = FALSE, sep='|' )
    g = graph.data.frame(vnet, directed=TRUE)

    svg(filename)
    plot(g)
EOF
  end

end