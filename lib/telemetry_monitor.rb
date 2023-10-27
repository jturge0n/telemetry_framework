module TelemetryMonitor
  def self.start_process(executable_path, command = "")
    log_path = 'process_log.json'
    process_name = File.basename(executable_path)
    process_command_line = "#{executable_path} #{command}"
    process_id = Process.spawn("#{command} #{executable_path}")

    options = {
      process_name: process_name,
      process_id: process_id,
      process_command_line: process_command_line
    }

    # generate and organize the data to be logged
    data = aggregate_basic_data(options)

    log_activity(data, log_path)
  end

  def create_file(file_path)

  end

  def modify_file(file_path, new_content)

  end

  def delete_file(file_path)

  end

  def establish_network_connection(destination, port, data)

  end

  # Generate and compile the basic data that all processes share
  def self.aggregate_basic_data(options)
    timestamp = Time.now
    username = ENV['USER'] || ENV['LOGNAME'] || ENV['USERNAME']

    {
      timestamp: timestamp,
      username: username,
      process_name: options[:process_name],
      process_command_line: options[:process_command_line],
      process_id: options[:process_id]
    }
  end

  # Log the data from activity to specified log file
  def self.log_activity(log_data, log_path)
    activity_log = {}

    # Set up pretty keys for logging based on present data
    log_data.each do |key, value|
      activity_log.merge!({CONSTANTS[key] => value})
    end

    File.open(log_path, 'a') do |file|
      file.puts(activity_log.to_json)
    end
  end
end
