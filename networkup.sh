#!/bin/bash
not_connected_time=0

while true
do
    if ping -c 1 -W 5 google.com 1>/dev/null 2>&1 
    then
        echo "Connected!"
        echo 1 > /sys/class/gpio/gpio68/value
        if [ $(ls /sys/bus/w1/devices/28* -d | wc -l) -ne 4 ]
        then
            echo 0 > /sys/class/gpio/gpio68/value
            echo "Sensor Disconnected!"
            sleep 1
            echo "on"
            echo 1 > /sys/class/gpio/gpio68/value
            sleep 1 
            echo "off"
            echo 0 > /sys/class/gpio/gpio68/value
            sleep 1
            echo 1 > /sys/class/gpio/gpio68/value
            sleep 1
            echo 0 > /sys/class/gpio/gpio68/value
            sleep 1
            echo 1 > /sys/class/gpio/gpio68/value
        else
            echo "Sensors connected"
            sleep 3
            echo 0 > /sys/class/gpio/gpio68/value
            sleep 3
        fi
    else
        echo 0 > /sys/class/gpio/gpio68/value
        echo "Not Connected!"
        if [ "$not_connected_time" -eq 0 ]; then
            not_connected_time=$SECONDS
        fi
        elapsed_time=$((SECONDS - not_connected_time))
        echo "Elapsed time since first 'Not Connected!': $elapsed_time seconds"
        # Restart NetworkManager after 5 minutes of being in "Not Connected!" state
        if [ "$elapsed_time" -ge 300 ]; then
            sudo /bin/systemctl stop NetworkManager
            sleep 2
            sudo /bin/systemctl start NetworkManager
            not_connected_time=0
        fi
        sleep 1
    fi
done
