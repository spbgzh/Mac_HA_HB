#!/bin/bash -x

# register HASS Bridge by getting the avahi-browse output from the homeassistant container
DNS_SD_NAME="HASS Bridge"

LOG_FILE="/var/log/dns-sd.log"

prepare_command() {
    echo '/usr/local/bin/docker exec -t $(/usr/local/bin/docker ps | grep homeassistant | cut -d" " -f1) avahi-browse -t -r -p -k _hap._tcp | grep -m 1 "HASS Bridge" | cut -d";" -f5-6,9-10 | awk -F";" '\''{printf "dns-sd -R \"HASS Bridge\" %s %s %s %s\n", $1, $2, $3, $4}'\'''
}

DNS_SD_CMD=""  # Declare CMD as a global variable

run_command() {
    PREPARE=$(prepare_command)
    echo "Prepare command: $PREPARE" | tee -a $LOG_FILE
    DNS_SD_CMD=$(eval $PREPARE)
    echo "Running command: $DNS_SD_CMD" | tee -a $LOG_FILE
    eval $DNS_SD_CMD >> $LOG_FILE 2>&1 &
    pid=$!
    echo "Command running with PID: $pid" | tee -a $LOG_FILE
}

check_and_run_command() {
    if pgrep -f "$DNS_SD_NAME" >/dev/null; then
        echo "Command is already running. Killing it..." | tee -a $LOG_FILE
        pkill -f "$DNS_SD_NAME"
    fi
    run_command
}

check_if_need_run() {
    PREPARE=$(prepare_command)
    echo "Prepare command: $PREPARE" | tee -a $LOG_FILE
    NEW_DNS_SD_CMD=$(eval $PREPARE)
    if [[ "$NEW_DNS_SD_CMD" != "$DNS_SD_CMD" ]]; then
        echo "DNS_SD_CMD is not the same." | tee -a $LOG_FILE
        check_and_run_command
    else
        echo "DNS_SD_CMD is the same." | tee -a $LOG_FILE
    fi
}

interval=86400  # 24 hours in seconds

# Infinite loop to periodically run the check
while true; do
    check_if_need_run
    sleep $interval
done