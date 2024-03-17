#!/bin/bash

# If ACPI was not installed, this probably is a battery-less computer.
ACPI_RES=$(acpi -b)
[[ !$ACPI_RES ]] && exit

# Get essential information. Due to som bug with some versions of acpi it is
# worth filtering the ACPI result from all lines containing "unavailable".
BAT_LEVEL_ALL=$(echo "$ACPI_RES" | grep -v "unavailable" | grep -E -o "[0-9][0-9]?[0-9]?%")
BAT_LEVEL=$(echo "$BAT_LEVEL_ALL" | awk -F"%" 'BEGIN{tot=0;i=0} {i++; tot+=$1} END{printf("%d%\n", tot/i)}')
TIME_LEFT=$(echo "$ACPI_RES" | grep -v "unavailable" | grep -E -o "[0-9]{2}:[0-9]{2}:[0-9]{2}")
IS_CHARGING=$(echo "$ACPI_RES" | grep -v "unavailable" | awk '{ printf("%s\n", substr($3, 0, length($3)-1) ) }')

# If there is no 'time left' information (when almost fully charged) we 
# provide information ourselvs.
if [ -z "$TIME_LEFT" ]
then
    TIME_LEFT="00:00:00"
fi
icons=('󱃍' '󰁺' '󰁻' '󰁼' '󰁽' '󰁾' '󰁿' '󰂀' '󰂁' '󰂂' '󰁹')
icons_charging=('󰢟' '󰢜' '󰂆' '󰂇' '󰂈' '󰢝' '󰂉' '󰢞' '󰂊' '󰂋' '󰂅')
# Print full text. The charging data.
TIME_LEFT=$(echo $TIME_LEFT | awk '{ printf("%s\n", substr($1, 0, 5)) }')
((INDEX=$BAT_LEVEL / 10))
echo -n ' $([ "$IS_CHARGING" = "Charging" ] ? ${icons_charging[$INDEX]} : ${icons[$INDEX]})'
echo " $BAT_LEVEL% 󰔟$TIME_LEFT"