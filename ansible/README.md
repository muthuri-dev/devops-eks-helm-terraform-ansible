# Ansible VM Configuration Documentation

## Overview

This Ansible project automatically configures a virtual machine with essential services and proper security settings. It ensures consistent server setup across environments.

## What It Configures

### 1. File Management

- Copies a configuration file to the `/opt/` directory
- Sets specific permissions: only users in the `devops` group can read/write the file
- Maintains proper ownership and access controls

### 2. Database Setup

- Installs PostgreSQL database system
- Creates a dedicated database and user account
- Ensures the database service starts automatically and remains running
- Sets up secure authentication

### 3. Web Server

- Installs Nginx web server
- Configures the service to start on system boot
- Verifies the web server is responding correctly

## How It Works

### Role-Based Structure

The configuration is organized into Ansible roles, making it modular and reusable. The `base_setup` role contains all the configuration logic.

### Execution Flow

1. **System Preparation**: Updates system packages and installs required software
2. **Security Setup**: Creates user groups and sets file permissions
3. **Service Configuration**: Installs and configures PostgreSQL and Nginx
4. **Verification**: Tests that all services are running correctly

### Key Features

- **Idempotent**: Can be run multiple times safely without causing issues
- **Automated**: Requires minimal manual intervention
- **Secure**: Implements proper file permissions and service security
- **Verifiable**: Includes checks to confirm successful configuration

## Typical Use Case

When provisioning a new virtual machine, this playbook can transform it from a basic system to a fully configured server with database and web services ready for application deployment.

The configuration meets enterprise standards for security and maintainability while keeping the setup process simple and repeatable.
