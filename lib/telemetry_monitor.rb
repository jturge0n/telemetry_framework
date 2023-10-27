require 'English'
require 'json'
require 'optparse'
require 'socket'

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

  # Start a process
  def self.start_process(command, executable_path)
    log_path = default_log_path('process_log.json')
    command = add_os_extension(command)
    process_name = File.basename(command)
    process_command_line = "#{command} #{executable_path}"

    begin
      process_id = Process.spawn("#{command} #{executable_path}")

      options = {
        process_name: process_name,
        process_id: process_id,
        process_command_line: process_command_line
      }

      # generate and organize the data to be logged
      data = aggregate_basic_data(options)

      log_activity(data, log_path)
    rescue StandardError => e
      puts "Error starting process: #{e.message}"
    end
  end


  # Create a new file at specified path
  def self.create_file(file_path)
    log_path = default_log_path('file_log.json')
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

    begin
      # Instantiate new file
      File.write(File.join(file_path), "This is a sample content for the file")

      log_activity(log_data, log_path)
    rescue StandardError => e
      puts "Error creating file: #{e.message}"
    end
  end

  # Modifying a File
  def self.modify_file(file_path, new_content)
    log_path = default_log_path('file_log.json')
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

    begin
      # Overwrite the file with new content
      File.write(File.join(file_path), new_content)

      log_activity(log_data, log_path)
    rescue StandardError => e
      puts "Error modifying file: #{e.message}"
    end
  end

  # Delete a specified file
  def self.delete_file(file_path)
    log_path = default_log_path('file_log.json')
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

    begin
      # Delete the file
      File.delete(File.join(file_path))

      log_activity(log_data, log_path)
    rescue StandardError => e
      puts "Error deleting file: #{e.message}"
    end
  end

  # Establish a Network Connection and Transmit Data
  def self.establish_network_connection(destination, port, data)
    log_path = default_log_path('network_log.json')
    source_address = "localhost"
    protocol = "TCP"
    process_name = "network connection"
    process_id = Process.pid
    process_command_line = "--establish-network-connection #{destination},#{port},#{data}"

    begin
      socket = TCPSocket.open(destination, port)
      socket.puts(data)

      source = Socket.gethostbyname(Socket.gethostname).first + ":" + socket.addr[1].to_s

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
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
  end

  # Log the data from activity to specified log file
  def self.log_activity(log_data, log_path)
    activity_log = {}

    # Set up pretty keys for logging based on present data
    log_data.each do |key, value|
      activity_log.merge!({CONSTANTS[key] => value})
    end

    # Append the file in binary mode to handle line endings consistently across different OS
    File.open(log_path, 'a:binary') do |file|
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

  def self.default_log_path(log_filename)
    home_directory = ENV['HOME'] || ENV['USERPROFILE'] || Dir.home

    File.join(home_directory,'rails_projects/telemetry_framework/logs', log_filename)
  end

  # Add the appropriate executable file extension based on the platform
  def self.add_os_extension(command)
    # Check if the command has an extension
    unless File.extname(command).empty?
      return command
    end

    # Platform-specific executable extensions
    windows_extension = '.exe'
    unix_extension = '' # No extension needed on Unix-based systems

    # Determine the appropriate extension based on the platform
    extension =
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        windows_extension
      when /darwin|mac os/
        unix_extension
      else
        unix_extension
      end

    # Append the appropriate extension
    command + extension
  end

  def self.main
    options = {}

    OptionParser.new do |opts|
      opts.on("--start-process COMMAND,EXECUTABLE_PATH", Array, "Start a process/shell command (i.e. ls -l)") do |args|
        options[:start_process] = args
      end

      opts.on("--create-file FILE_PATH", String, "Create a file at the specified location") do |file_path|
        options[:create_file] = file_path
      end

      opts.on("--modify-file FILE_PATH,NEW_CONTENT", Array, "Modify a file at the specified location") do |args|
        options[:modify_file] = args
      end

      opts.on("--delete-file FILE_PATH", String, "Delete a file at the specified location") do |file_path|
        options[:delete_file] = file_path
      end

      opts.on("--establish-network-connection DESTINATION,PORT,DATA", Array, "Start a connection and transmit data") do |args|
        options[:establish_network_connection] = args
      end
    end.parse!

    if options.key?(:start_process)
      command, executable_path = options[:start_process]
      start_process(command, executable_path)
    end

    if options.key?(:create_file)
      create_file(options[:create_file])
    end

    if options.key?(:modify_file)
      file_path, new_content = options[:modify_file]
      modify_file(file_path, new_content)
    end

    if options.key?(:delete_file)
      delete_file(options[:delete_file])
    end

    if options.key?(:establish_network_connection)
      destination, port, data = options[:establish_network_connection]
      establish_network_connection(destination, port, data)
    end

    if options.empty?
      puts options
    end
  end

  if $PROGRAM_NAME == __FILE__
    main
  end
end
