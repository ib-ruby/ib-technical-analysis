require 'spec_helper'
require 'thread'
require 'stringio'
require 'rspec/expectations'

## Logger helpers

def mock_logger
  @stdout = StringIO.new

  @logger = Logger.new(@stdout).tap do |logger|
    logger.formatter = proc do |level, time, prog, msg|
      "#{time.strftime('%H:%M:%S')} #{msg}\n"
    end
    logger.level = Logger::INFO
  end
end

def log_entries
  @stdout && @stdout.string.split(/\n/)
end

## Connection helpers
def establish_connection

  ib = IB::Connection.new **OPTS[:connection].merge(:logger => mock_logger)
  raise "could not establish connection!"  unless ib.present?

  ib.wait_for :ManagedAccounts, 5

  raise "Unable to verify IB PAPER ACCOUNT" unless ib.received?(:ManagedAccounts)

  received = ib.received[:ManagedAccounts].first.accounts_list.split(',')
  puts received
  unless received.include?(ACCOUNT)
    close_connection
    puts "Connected to wrong account #{gw.clients.map( &:to_human).join ' '}, expected #{ACCOUNT}"
    puts "READONLY API is used"
    OPTS[:readonly] =  true
  end
  OPTS[:account_verified] = true
end

def init_gateway
  args= OPTS[:connection].slice(:port, :host, :client_id).merge(  serial_array: true,  logger: mock_logger)
  gw = IB::Gateway.new **args
  raise "could not establish connection!"  unless gw.present?
  if va = gw.clients.detect { |c| c.account == ACCOUNT }
    OPTS[:account_verified] = true
  else
    puts "Connected to wrong account #{gw.clients.map( &:to_human).join ' '}, expected #{ACCOUNT}"
    puts "READONLY API is used"
    OPTS[:readonly] =  true
    txt= "Connected to wrong account #{gw.clients.map( &:to_human).join ' '}, expected #{ACCOUNT}"
  end
rescue  IB::Error => e
  puts e.inspect
  nil

end


# Clear logs and message collector. Output may be silenced.
def clean_connection
  ib =  IB::Connection.current
  if ib
    if OPTS[:verbose]
      puts ib.received.map { |type, msg| [" #{type}:", msg.map(&:to_human)] }
      puts " Logs:", log_entries if @stdout
    end
    @stdout.string = '' if @stdout
    ib.clear_received
  end
end

def close_connection
  ib =  IB::Connection.current
  if ib
    clean_connection
    ib.close
  end
end

def read_sample_data
  YAML.load_file( File.expand_path('../samples/stock-2m.yml',__FILE__ ))
end
