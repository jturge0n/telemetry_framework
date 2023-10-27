require 'socket'
require 'json'

module TelemetryMonitor
  CONSTANTS = {
    timestamp: "Timestamp",
    username: "Username",
    process_name: "Process Name",
    process_command_line: "Process Command Line",
    process_id: "Process ID",
    activity: "Activity",
    file_path: "File Path",
    destination: "Destination",
    source: "Source",
    data_size: "Data Size",
    protocol: "Protocol"
  }

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

  # Create a new file at specified path
  def self.create_file(file_path)
    log_path = 'file_log.json'
    process_name = "create file"
    process_id = Process.pid
    process_command_line = "--create-file #{file_path}"

    options = {
      file_path: file_path,
      activity: "Create",
      process_name: process_name,
      process_id: process_id,
      process_command_line: process_command_line
    }

    # generate and organize the data to be logged
    log_data = aggregate_file_data(options)

    # Instantiate new file
    File.write(file_path, "This is a sample content for the file")

    log_activity(log_data, log_path)
  end

  # Modifying a File
  def self.modify_file(file_path, new_content)
    log_path = 'file_log.json'
    process_name = "modify file"
    process_id = Process.pid
    process_command_line = "--modify-file #{file_path},#{new_content}"

    options = {
      file_path: file_path,
      activity: "Modify",
      process_name: process_name,
      process_id: process_id,
      process_command_line: process_command_line
    }

    # generate and organize the data to be logged
    log_data = aggregate_file_data(options)

    # Overwrite the file with new content
    File.write(file_path, new_content)

    log_activity(log_data, log_path)
  end

  # Delete a specified file
  def self.delete_file(file_path)
    log_path = 'file_log.json'
    process_name = "delete file"
    process_id = Process.pid
    process_command_line = "--delete-file #{file_path}"

    options = {
      file_path: file_path,
      activity: "Delete",
      process_name: process_name,
      process_id: process_id,
      process_command_line: process_command_line
    }

    # generate and organize the data to be logged
    log_data = aggregate_file_data(options)

    # Delete the file
    File.delete(file_path)

    log_activity(log_data, log_path)
  end

  # Establish a Network Connection and Transmit Data
  def self.establish_network_connection(destination, port, data)
    log_path = 'network_log.json'
    source_address = "localhost"
    source_port = 12345
    protocol = "TCP"
    process_name = "network connection"
    process_id = Process.pid
    process_command_line = "--establish-network-connection #{destination},#{port},#{data}"

    socket = TCPSocket.open(destination, port)
    socket.puts(data)

    source = "#{source_address}:#{source_port}"

    options = {
      source: source,
      destination: "#{destination}:#{port}",
      data_size: data.length,
      protocol: protocol,
      process_name: process_name,
      process_id: process_id,
      process_command_line: process_command_line
    }

    log_data = aggregate_network_data(options)

    # Log the network activity
    log_activity(log_data, log_path)

    socket.close
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

  # Generate and compile data specific to file manipulation
  def self.aggregate_file_data(options)
    basic_data = aggregate_basic_data(options)

    file_data = {
      activity: options[:activity],
      file_path: options[:file_path]
    }

    basic_data.merge(file_data)
  end

  # Generate and compile data specific to network connection
  def self.aggregate_network_data(options)
    basic_data = aggregate_basic_data(options)

    network_data = {
      destination: options[:destination],
      source: options[:source],
      data_size: options[:data_size],
      protocol: options[:protocol]
    }

    basic_data.merge(network_data)
  end
end
