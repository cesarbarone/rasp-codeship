require 'json'

class CodeshipBuildStatus
  TOKEN = ENV['CODESHIP_TOKEN']
  PROJECT = ENV['CODESHIP_PROJECT']
  def self.run!
    raise 'I need both CODESHIP_TOKEN and CODESHIP_PROJECT env var to be set!' unless ENV['CODESHIP_TOKEN'] && ENV['CODESHIP_PROJECT']
    boot_pins
    trap("SIGINT") do
      puts 'Bye bye!'
      pin(0,on) # alert the script is down!
      exit!
    end
    puts 'Starting...'
    while true do
      if build_status==:success
        puts 'Build is good'
      else
        puts 'Build is bad'
      end
    end
  end

  def self.boot_pins
    `echo '17' > /sys/class/gpio/unexport`
    `echo '17' > /sys/class/gpio/export`
    `echo out > /sys/class/gpio/gpio17/direction`
    `echo 1 > /sys/class/gpio/gpio17/value`
    sleep 1
    `echo 1 > /sys/class/gpio/gpio17/value`
  end

  def self.build_status
    json_string = `curl -s https://www.codeship.io/api/v1/projects/#{PROJECT}.json\?api_key\=#{TOKEN}`
    json = JSON.parse(json_string)
    build = json['builds'].first
    status = build['status']
    return status.to_sym
  end

  def self.pin(number,status)
    if status==:on
      puts "Setting PIN[#{number}] to #{status}"
    elsif status==:off
      puts "Setting PIN[#{number}] to #{status}"
    else
      raise 'wft?'
    end
  end
end

CodeshipBuildStatus.run!
