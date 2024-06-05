# SimpleSendMail

SimpleSendMail is a lightweight, command-line bash script for sending emails efficiently. Tailored for users who need a straightforward email solution, it encapsulates the complexity of email configurations into a single, user-friendly script.

## Features

- Send emails with customizable subjects, messages, and attachments.
- Simple configuration via an external file.
- SSL support for secure email transmission.

## Dependency

This script relies on mailsend-go, a versatile command-line tool for sending emails via SMTP. Ensure mailsend-go is installed and properly configured on your system.

For more information and installation instructions, visit the [mailsend-go](https://github.com/muquit/mailsend-go) GitHub repository.

## Configuration File

The script requires a configuration file with SMTP details:
```bash
USERNAME: SMTP username.
PASSWORD: SMTP password.
ADDRESS: SMTP server address.
PORT: SMTP server port.
USE_TLS: Enable SSL (true/false).
FROM_EMAIL: Sender's email address.
```
## Usage

Create and configure your SMTP settings in the configuration file.
Run the script with required options: -a for the account configuration file, -s to send an email, along with --to, --subject, --message, and optionally --attachment.

#Contributing

Contributions, bug reports, and feature requests are welcome!