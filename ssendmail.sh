#!/bin/bash

# Help function
show_help() {
    echo "SimpleSendMail - A simple script for sending emails"
    echo " "
    echo "Options:"
    echo "-h, --help        Show this help message."
    echo "-a, --account     Path to the account configuration file."
    echo "-s, --send        Send an email."
    echo "                  Requires -to, -subject, -message, and optionally -attachment"
    echo "--to              Recipient email address."
    echo "--subject         Email subject."
    echo "--message         Email message body."
    echo "--attachment      Path to attachment file."
    echo " "
}

# Default configuration variables
MAIL_CMD_PATH="/usr/local/bin/mailsend-go"
CONFIG_SEARCH_FOLDER="/etc/ssendmail/"
USERNAME=""
PASSWORD=""
ADDRESS=""
PORT=""
USE_TLS=""
FROM_EMAIL=""

# Read configuration file with fallback
read_config() {
    local config_file_name=$1
    local config_file_path="$CONFIG_SEARCH_FOLDER$config_file_name"

    # Zuerst im CONFIG_SEARCH_FOLDER suchen
    if [ -f "$config_file_path" ]; then
        source "$config_file_path"
    elif [ -f "$config_file_name" ]; then
        # Wenn nicht gefunden, am angegebenen Pfad suchen
        source "$config_file_name"
    else
        echo "Configuration file not found in $CONFIG_SEARCH_FOLDER or at path: $config_file_name"
        exit 1
    fi
}

# Email sending variables
SEND_EMAIL=false
RECIPIENT=""
SUBJECT=""
MESSAGE=""
ATTACHMENT=""

# Main logic
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -a|--account) 
            read_config "$2"
            shift ;;
        -s|--send) SEND_EMAIL=true ;;
        --to) RECIPIENT="$2"; shift ;;
        --subject) SUBJECT="$2"; shift ;;
        --message) MESSAGE="$2"; shift ;;
        --attachment) ATTACHMENT="$2"; shift ;;
        *) 
            echo "Unknown option: $1"
            show_help
            exit 1 ;;
    esac
    shift
done

# Function for sending email
send_mail() {
    echo "Sending an email..."

    # Set SMTP_USER_PASS environment variable for the password
    export SMTP_USER_PASS="$PASSWORD"

    # Basic command for mailsend-go with SSL support
    MAIL_CMD="$MAIL_CMD_PATH -sub \"$SUBJECT\" -smtp $ADDRESS -port $PORT auth -user $USERNAME -from \"$FROM_EMAIL\" -to \"$RECIPIENT\""

    # Add SSL setting based on configuration
    if [ "$USE_TLS" = "true" ]; then
        MAIL_CMD+=" -ssl"
    fi

    # Message body
    MAIL_CMD+=" body -msg \"$MESSAGE\""

    # Add attachment if present
    if [ ! -z "$ATTACHMENT" ]; then
        MAIL_CMD+=" attach -file \"$ATTACHMENT\""
    fi

    # Send the email
    eval $MAIL_CMD

    # Unset the SMTP_USER_PASS environment variable
    unset SMTP_USER_PASS
}

# Check if the send email option is enabled
if [ "$SEND_EMAIL" = true ]; then
    if [ -z "$RECIPIENT" ] || [ -z "$SUBJECT" ] || [ -z "$MESSAGE" ]; then
        echo "Missing required arguments for sending an email."
        show_help
        exit 1
    fi
    send_mail
fi
