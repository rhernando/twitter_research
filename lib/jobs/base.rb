# encoding: utf-8
module Jobs

  # Callbacks in jobs execution.
  class Base
    def self.before_perform_log(*args)
      puts "WORKER: Starting #{self.name}"
    end

    def self.after_perform_log(*args)
      puts "WORKER: Finished #{self.name}"

      puts "*"*30

      next_execution = Time.now + 10.minutes

      puts "WORKER: Delayed job #{self}: #{args}  Next running #{next_execution}"
      Resque.enqueue_at(next_execution, self, *args)

      puts "*"*30


    end

    def self.on_failure_log(e, *args)
      puts "WORKER: #{self.name} #{args} failed : (#{e})."
    end


  end

end