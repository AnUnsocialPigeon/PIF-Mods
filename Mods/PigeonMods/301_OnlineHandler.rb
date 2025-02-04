module OnlineUtils
  # Convert data to CSV format
  def self.to_csv(data)
    data.map { |k, v| "#{k},#{v}" }.join("\n")
  end

  # Parse CSV format back to a hash
  def self.from_csv(csv)
    csv.split("\n").map { |line| line.split(",", 2) }.to_h
  end

  # HTTP GET method
  def self.http_get(url)
    begin
      response = HTTPLite.get(url)
      log_message("HTTP GET response: #{response[:body]}")
      return response if response[:status] == 200

      log_message("HTTP GET failed with status: #{response[:status]}")
      return nil
    rescue Exception => e
      log_message("HTTP GET error: #{e.message}")
      return nil
    end
  end

  # HTTP POST method
  def self.http_post(url, data)
    begin
      csv_data = to_csv(data)
      response = HTTPLite.post(url, { "body" => csv_data }, { "Content-Type" => "text/plain" })
      return response if response[:status] == 200

      log_message("HTTP POST failed with status: #{response[:status]}")
      return nil
    rescue Exception => e
      log_message("HTTP POST error: #{e.message}")
      return nil
    end
  end
end




