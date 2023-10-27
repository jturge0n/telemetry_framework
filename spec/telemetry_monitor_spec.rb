require_relative '../lib/telemetry_monitor.rb'
require 'json'
require 'rspec'
require 'rspec/mocks'

RSpec.describe TelemetryMonitor do
  describe '.start_process' do
    before(:each) do
      File.write('example.txt', '')  # Create an empty 'example.txt' file
      `ps aux | grep "TextEdit" | awk '{print $2}' | xargs kill -9`
    end

    after(:each) do
      File.delete('example.txt') if File.exist?('example.txt')
      `ps aux | grep "TextEdit" | awk '{print $2}' | xargs kill -9`
    end

    it 'starts a process and logs the activity' do
      # Define the command and executable_paths
      command = 'open'
      executable_path = 'example.txt'

      # Ensure that the activity was logged with correct params
      expect(TelemetryMonitor).to receive(:log_activity) do |data, log_path|
        expect(data).to be_a(Hash)
        expect(log_path).to be_a(String)
      end

      # Document the number of text edit processes are running before we start ours
      text_edit_processes = `ps aux | grep "TextEdit" | awk '{print $2}'`.freeze
      num_text_edit_processes = text_edit_processes.split("\n").length

      # Start the process
      TelemetryMonitor.start_process(executable_path, command)

      # Sleep briefly to allow the process to start
      sleep(2)

      # Count the updated number of text edit processes
      updated_text_edit_processes = `ps aux | grep "TextEdit" | awk '{print $2}'`.freeze
      updated_num_text_edit_processes = updated_text_edit_processes.split("\n").length

      expect(updated_num_text_edit_processes).to eq(num_text_edit_processes + 1)
    end
  end

  describe '.create_file' do
    before(:each) do
      @test_file = 'test_file.txt'
    end

    after(:each) do
      File.delete(@test_file) if File.exist?(@test_file)
    end

    it 'creates a file and logs the activity' do
      # Ensure that the activity was logged with correct params
      expect(TelemetryMonitor).to receive(:log_activity) do |data, log_path|
        expect(data).to be_a(Hash)
        expect(log_path).to be_a(String)
      end

      expect {
        TelemetryMonitor.create_file(@test_file)
      }.to change { File.exist?(@test_file) }.from(false).to(true)
    end
  end

  describe '.modify_file' do
    before(:each) do
      @test_file = 'test_file.txt'
      File.write(@test_file, 'Initial content for the file')
    end

    after(:each) do
      File.delete(@test_file) if File.exist?(@test_file)
    end

    it 'modifies a file and logs the activity' do
      # Ensure that the activity was logged with correct params
      expect(TelemetryMonitor).to receive(:log_activity) do |data, log_path|
        expect(data).to be_a(Hash)
        expect(log_path).to be_a(String)
      end

      expect {
        TelemetryMonitor.modify_file(@test_file, 'Modified content for the file')
      }.to change { File.read(@test_file) }.from('Initial content for the file').to('Modified content for the file')
    end
  end

  describe '.delete_file' do
    before(:each) do
      @test_file = 'test_file.txt'
      File.write(@test_file, 'Sample content for the file')
    end

    it 'deletes a file and logs the activity' do
      # Ensure that the activity was logged with correct params
      expect(TelemetryMonitor).to receive(:log_activity) do |data, log_path|
        expect(data).to be_a(Hash)
        expect(log_path).to be_a(String)
      end

      expect {
        TelemetryMonitor.delete_file(@test_file)
      }.to change { File.exist?(@test_file) }.from(true).to(false)
    end
  end

  describe '.log_activity' do
    before(:each) do
      @log_file = 'activity_log.txt'
      File.write(@log_file, '')  # Create an empty log file
    end

    after(:each) do
      File.delete(@log_file) if File.exist?(@log_file)
    end

    context 'when data comes from start_process' do
      it 'logs the activity' do
        timestamp = Time.now
        username = 'testuser'
        process_name = 'TestProcess'
        process_command_line = 'test_command'
        process_id = 123

        log_data = {
          timestamp: timestamp,
          username: username,
          process_name: process_name,
          process_command_line: process_command_line,
          process_id: process_id
        }

        TelemetryMonitor.log_activity(log_data, @log_file)

        # Read the log file line by line and parse each line as JSON
        log_entries = File.readlines(@log_file).map { |line| JSON.parse(line) }

        # Assert that the JSON log entries contain relevant information
        expect(log_entries).to include(
          hash_including(
            'Username' => username,
            'Process ID' => process_id,
            'Process Name' => process_name,
            'Process Command Line' => process_command_line
          )
        )
      end
    end

    describe '.establish_network_connection' do
      it 'establishes a network connection and logs the activity' do
        destination = 'example.com'
        port = 80
        data = 'Hello, World!'

        # Mock the TCPSocket class
        socket = double(TCPSocket)
        allow(TCPSocket).to receive(:open).and_return(socket)
        allow(socket).to receive(:addr).and_return(12345)

        # Set expectations on the mock socket
        expect(socket).to receive(:puts).with(data)
        expect(socket).to receive(:close)

        # Ensure that the activity was logged with correct params
        expect(TelemetryMonitor).to receive(:log_activity) do |data, log_path|
          expect(data).to be_a(Hash)
          expect(log_path).to be_a(String)
        end

        TelemetryMonitor.establish_network_connection(destination, port, data)
      end
    end

    context 'when data comes from file crud methods' do
      it 'logs the activity with the expected content' do
        timestamp = Time.now
        username = 'testuser'
        process_name = 'TestProcess'
        process_command_line = 'test_command'
        process_id = 123
        activity = 'Create'
        file_path = '/Users/joshuadturgeon/rails_projects/red-canary-activity/activity_log.txt'

        log_data = {
          timestamp: timestamp,
          username: username,
          process_name: process_name,
          process_command_line: process_command_line,
          process_id: process_id,
          activity: activity,
          file_path: file_path
        }

        TelemetryMonitor.log_activity(log_data, @log_file)

        # Read the log file line by line and parse each line as JSON
        log_entries = File.readlines(@log_file).map { |line| JSON.parse(line) }

        # Assert that the JSON log entries contain relevant information
        expect(log_entries).to include(
          hash_including(
            'Activity' => activity,
            'File Path' => file_path,
            'Username' => username,
            'Process ID' => process_id,
            'Process Name' => process_name,
            'Process Command Line' => process_command_line
          )
        )
      end
    end

    context 'when data comes from establish_network_connection' do
      it 'logs the activity with the expected content' do
        timestamp = Time.now
        username = 'testuser'
        process_name = 'TestProcess'
        process_command_line = 'test_command'
        process_id = 123
        source_address = "localhost"
        source_port = 12345
        full_source = "#{source_address}:#{source_port}"
        protocol = "TCP"
        destination = 'example.com'
        port = 80
        full_destination = "#{destination}:#{port}"
        data = 'Hello, World!'

        log_data = {
          timestamp: timestamp,
          username: username,
          process_name: process_name,
          process_command_line: process_command_line,
          process_id: process_id,
          destination: full_destination,
          source: full_source,
          data_size: data.length,
          protocol: protocol,
        }

        TelemetryMonitor.log_activity(log_data, @log_file)

        # Read the log file line by line and parse each line as JSON
        log_entries = File.readlines(@log_file).map { |line| JSON.parse(line) }

        # Assert that the JSON log entries contain relevant information
        expect(log_entries).to include(
          hash_including(
            'Destination' => full_destination,
            'Data Size' => data.length,
            'Protocol' => protocol,
            'Username' => username,
            'Process ID' => process_id,
            'Process Name' => process_name,
            'Process Command Line' => process_command_line
          )
        )
      end
    end
  end
end
