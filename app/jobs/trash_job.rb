#encoding: utf-8
require 'resque'

class TrashJob < Jobs::Base
  @queue = :trash_remove

  def self.perform(opts = {})
    #(Resque::Failure.count-1).downto(0).each do |i|
    #  Resque::Failure.remove(i)
    #end
    puts "Jobs failed count #{Resque::Failure.count}"
  end
end