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
end
