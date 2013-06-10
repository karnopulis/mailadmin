require 'daemons'
require 'thread'

class BackgroundTasks
  include Singleton

  def initialize
    #ActiveRecord::Base.allow_concurrency = true
  end
  
  def run(my_logger)
    loop do
      Site.find(:all).each do |s|
        process_clients(s,my_logger)
        end
      sleep 10
      end
  end
  
  def process_clients (s,my_logger)
    #my_logger.warn s.name+" begin"
    s.import_clients(my_logger)
    s.import_orders(my_logger)
    s.check_and_send_emails(s.clients,my_logger)
    s.check_and_send_emails(s.orders,my_logger)
    #my_logger.warn s.name+" end"
  end 
end

@files_to_reopen = []
ObjectSpace.each_object(File) do |file|
  @files_to_reopen << file unless file.closed?
end
  
Daemons.run_proc('BackgroundTasks') do
  Dir.chdir(Rails.root)
  # Re-open file handles
  @files_to_reopen.each do |file|
    begin
      file.reopen file.path
      file.sync = true
    rescue ::Exception
    end
  end
  ActiveRecord::Base.verify_active_connections!
  #ActiveRecord::Base.clear_active_connections!
  my_logger = ActiveSupport::BufferedLogger.new( "/var/log/rails.log")
  
  Rails.logger = my_logger
  #ActiveRecord::Base.logger =my_logger
  #ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger = Logger.new('/dev/null')
  ActionMailer::Base.logger = Logger.new('/dev/null')
  BackgroundTasks.instance.run(my_logger)
end