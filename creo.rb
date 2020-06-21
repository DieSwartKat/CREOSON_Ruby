#creo.rb

require 'json'
require 'net/http'


class BaseConnection
  def send_request(data)
    url = URI.parse("http://localhost:9056/creoson")
    http = Net::HTTP.new(url.host, url.port)
    resp = http.post(
                      url.path,
                      JSON.dump(data),
                      'Content-type' => 'application/json',
                      'Accept' => 'text/json, application/json'
                    )
    response = JSON.parse(resp.body)
    error = response['status']['error']
    return response, error
  end

  def connect
    connect_hash =  { command: "connection", function: "connect" }
    response, error = send_request(connect_hash)
    session_id = ''
    if !error
      session_id = response['sessionId']
    end
    return session_id, error
  end

  def session_id
    session_id, error = connect
    if !error
      return session_id
    else
      return error
    end
  end

end


class Creo < BaseConnection
  def get_active()
    command_hash =  {
      command: 'file',
      function: 'get_active',
      sessionId: session_id
    }
    response = send_request(command_hash)
    return response
  end

  def mapkey(script)
    command_hash = {
      command: 'interface',
      function: 'mapkey',
      sessionId: session_id,
      data: {
          script: script,
        }
      }
    response = send_request(command_hash)
    return response
  end

end


class ListModelItems

  def initialize(model)
    model.mapkey('%treetool01')
    model.mapkey('@SYSTEM"cd" > C:\\\\PTC\\\\Bar_Start_Creo\\\\Drawing-exchange\\\\ready.txt;')
    while !File.file?("C:/PTC/Bar_Start_Creo/drawing-exchange/ready.txt")
      puts "Treetool"
      sleep 1
    end
  end

  def parts
    lines = []
    file_location = "C:/PTC/Bar_Start_Creo/drawing-exchange/treetool.txt"
    File.open(file_location).read.split("\n").each do |item|
      if item.downcase.include?(".prt")
        unless item.downcase.include?('pattern')
          lines.append(item.split[0])
        end
      end
    end
    return lines
  end
end


creo = Creo.new
item_list = ListModelItems.new creo
lines = item_list.parts
puts lines