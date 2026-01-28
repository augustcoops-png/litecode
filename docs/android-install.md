# Android Installation Guide

This guide covers the installation of Codex validator and hosting nodes on Android devices.

## System Requirements

| Requirement      | Details                         |
| ---------------- | ------------------------------- |
| Operating System | Android 9.0 (Pie) or higher     |
| Architecture     | arm64-v8a, armeabi-v7a          |
| Storage          | Minimum 500 MB free space       |
| RAM              | Minimum 2 GB (4 GB recommended) |
| Termux           | Required for CLI execution      |

## Prerequisites

Before installing the validator or hosting nodes, you need to set up Termux on your Android device:

1. Install Termux from F-Droid (recommended) or Google Play Store
2. Update packages:
   ```bash
   pkg update && pkg upgrade
   ```
3. Install required dependencies:
   ```bash
   pkg install wget curl git nodejs
   ```

## Installing the Validator Node

The validator node validates and processes code execution requests on Android devices.

**Security Note**: Always download binaries from official GitHub releases and verify checksums when available. For enhanced security, check the release page for SHA256 checksums and verify them after download.

### Method 1: Download Pre-built Binary

1. Download the appropriate binary for your architecture:

   ```bash
   # For arm64 devices (most modern Android phones)
   wget https://github.com/openai/codex/releases/latest/download/codex-validator-aarch64-linux-android.tar.gz

   # For arm32 devices (older Android phones)
   wget https://github.com/openai/codex/releases/latest/download/codex-validator-armv7-linux-android.tar.gz
   ```

2. Extract the archive:

   ```bash
   tar -xzf codex-validator-*.tar.gz
   ```

3. Make the binary executable:

   ```bash
   chmod +x codex-validator
   ```

4. Move to a directory in your PATH:

   ```bash
   mv codex-validator $PREFIX/bin/
   ```

5. Verify installation:
   ```bash
   codex-validator --version
   ```

### Method 2: Install via NPM (if Node.js is available)

> **Note**: NPM package installation is planned for future releases and is not yet available.

```bash
npm install -g @openai/codex-validator
```

### Configuration

Create a configuration file at `~/.codex/validator-config.json`:

```json
{
  "port": 8080,
  "maxConnections": 10,
  "timeout": 30000,
  "sandboxMode": true
}
```

### Running the Validator Node

Start the validator node:

```bash
codex-validator start
```

To run in the background (requires daemon support in the binary):

```bash
codex-validator start --daemon
```

> **Note**: The `--daemon` flag availability depends on the binary implementation.

## Installing the Hosting Node

The hosting node manages file hosting and distribution for code artifacts on Android devices.

**Security Note**: Always download binaries from official GitHub releases and verify checksums when available. For enhanced security, check the release page for SHA256 checksums and verify them after download.

### Method 1: Download Pre-built Binary

1. Download the appropriate binary for your architecture:

   ```bash
   # For arm64 devices
   wget https://github.com/openai/codex/releases/latest/download/codex-hosting-aarch64-linux-android.tar.gz

   # For arm32 devices
   wget https://github.com/openai/codex/releases/latest/download/codex-hosting-armv7-linux-android.tar.gz
   ```

2. Extract the archive:

   ```bash
   tar -xzf codex-hosting-*.tar.gz
   ```

3. Make the binary executable:

   ```bash
   chmod +x codex-hosting
   ```

4. Move to a directory in your PATH:

   ```bash
   mv codex-hosting $PREFIX/bin/
   ```

5. Verify installation:
   ```bash
   codex-hosting --version
   ```

### Method 2: Install via NPM

> **Note**: NPM package installation is planned for future releases and is not yet available.

```bash
npm install -g @openai/codex-hosting
```

### Configuration

Create a configuration file at `~/.codex/hosting-config.json`:

```json
{
  "port": 8081,
  "storageDir": "~/.codex/storage",
  "maxFileSize": 104857600,
  "allowedOrigins": ["*"]
}
```

**Security Note**: The `allowedOrigins: ["*"]` setting allows requests from any origin. For production deployments, restrict this to specific trusted origins:

```json
{
  "allowedOrigins": ["http://localhost:8080", "https://yourdomain.com"]
}
```

### Running the Hosting Node

Start the hosting node:

```bash
codex-hosting start
```

To run in the background (requires daemon support in the binary):

```bash
codex-hosting start --daemon
```

> **Note**: The `--daemon` flag availability depends on the binary implementation.

## Connecting Validator and Hosting Nodes

Once both nodes are running, configure Codex CLI to use them:

1. Edit your Codex configuration at `~/.codex/config.toml`:

   ```toml
   [android]
   validator_url = "http://localhost:8080"
   hosting_url = "http://localhost:8081"
   ```

2. Restart the Codex CLI to apply changes.

## Troubleshooting

### Permission Denied Errors

If you encounter permission errors:

```bash
termux-setup-storage
```

Then grant storage permissions when prompted.

### Port Already in Use

If the default ports are already in use, change them in the configuration files:

```json
{
  "port": 8082
}
```

Note: Use a different port number if the default is already in use.

### Node Not Starting

Check the logs for detailed error messages:

```bash
# Validator logs
cat ~/.codex/log/validator.log

# Hosting logs
cat ~/.codex/log/hosting.log
```

## Updating Nodes

To update to the latest version, manually download and replace the binaries following the installation steps above:

1. Download the latest binary for your architecture
2. Extract the archive
3. Stop the running node (if active)
4. Replace the old binary with the new one in `$PREFIX/bin/`
5. Restart the node

> **Note**: Automatic update commands (`codex-validator update`, `codex-hosting update`) are planned for future releases.

## Uninstalling

To uninstall the nodes:

```bash
# Remove binaries
rm $PREFIX/bin/codex-validator
rm $PREFIX/bin/codex-hosting

# Remove configuration and data (optional)
rm -rf ~/.codex/validator-config.json
rm -rf ~/.codex/hosting-config.json
rm -rf ~/.codex/storage
```

## Additional Resources

- [Termux Wiki](https://wiki.termux.com/)
- [Codex Documentation](https://developers.openai.com/codex)
- [GitHub Releases](https://github.com/openai/codex/releases)
