#!/usr/bin/env ruby
require 'optparse'
require_relative './lib/config'
require_relative './lib/swarm'

OptionParser.new do |opts|
  opts.banner = 'Usage: ./ptnpnh.rb [options]'

  opts.on('--http', 'Use HTTP mode') do
    Config.instance.mode = :http
  end

  opts.on('--smtp', 'Use SMTP mode (flood)') do
    Config.instance.mode = :smtp
  end

  opts.on('--smtp-educator', 'Use SMTP mode (educator)') do
    Config.instance.mode = :smtp_educator
  end

  opts.on('-tNAME', '--target=NAME', 'Target URL for HTTP mode (if single target)') do |target|
    Config.instance.target = target
  end

  opts.on('--threads=NUM_THREADS', 'Sets number of threads to use. Default is the number of CPUs on the machine.') do |number_of_threads|
    Config.instance.number_of_threads = number_of_threads.to_i
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

if Config.instance.mode.nil?
  puts 'Must specify mode. See --help'
  exit 1
end

Swarm.instance.begin_assault
