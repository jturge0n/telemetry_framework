# Telemetry Monitor - Project Overview

## Introduction

The **Telemetry Monitor** is a Ruby-based utility designed to capture and log telemetry data generated during various system activities. This project serves as a comprehensive monitoring tool for tracking processes, file operations, and network connections. By creating detailed logs, the Telemetry Monitor allows users to keep an eye on their system's behavior by logging all activity in corresponding JSON logs

## Key Features

### 1. Process Monitoring
The Telemetry Monitor allows users to initiate and track system processes. When a new process is started, the utility records essential information, such as the process name, command-line arguments, and process ID. This data is invaluable for users who wish to monitor and analyze the behavior of their system processes.

### 2. File Operation Tracking
For file-centric tasks, the Telemetry Monitor captures data related to file creation, modification, and deletion. When you create or modify a file, the utility logs important details, including the file path, activity type (create or modify), and relevant process information.

### 3. Network Connection Monitoring
Users can establish network connections and observe network-related activities. The Telemetry Monitor records information about network connections, including source and destination addresses, data size, and the used protocol. This feature is beneficial for tracking network behavior and identifying potential issues.

## Implementation

- **Logging**: The utility logs all telemetry data in structured JSON format to designated log files. These log files help users to maintain a historical record of system activities.

- **Error Handling**: Each monitored action, including process initiation, file operations, and network connections, is equipped with error handling to ensure robust and reliable performance.

- **Platform Compatibility**: The Telemetry Monitor adapts to various platforms by appending the appropriate executable file extension based on the host operating system, being deliberate about file structuring and path construction, as well as utilizing ENV vars when possible.

- **Testing**: Unit testing for each of the key methods as well as the logging functionality for most base cases. Edge cases and other helpers were left out for the purpose of time.

## How to Use

Using the Telemetry Monitor is straightforward. Users can interact with the utility through command-line options to initiate different monitoring tasks. Supported commands include starting a process, creating a file, modifying a file, deleting a file, and establishing a network connection.

For example:

- To start a process:
  ```
  ruby telemetry_monitor.rb --start-process COMMAND,EXECUTABLE_PATH

  for example:

  ruby telemetry_monitor.rb --start-process "open,example.txt"
  ```


- To create a file:
  ```
  ruby telemetry_monitor.rb --create-file FILE_PATH

  for example:

  ruby telemetry_monitor.rb --create-file "example.txt"
  ```

- To establish a network connection:
  ```
  ruby telemetry_monitor.rb --establish-network-connection DESTINATION,PORT,DATA

  for example:

  ruby telemetry_monitor.rb --establish-network-connection "example.com,80,Hello World"
  ```

Users can choose the appropriate command for their monitoring needs.

## Conclusion

The Telemetry Monitor project is a versatile and valuable tool for those who wish to gain insight into their system's behavior. By providing detailed telemetry data logs, users can enhance system management, troubleshoot issues, and ensure the smooth operation of their systems. The project's well-structured and tested codebase guarantees reliability and robust performance.

The Telemetry Monitor is an excellent example of how scripting and automation can assist in monitoring and understanding complex system activities, ultimately leading to improved system maintenance and performance.
