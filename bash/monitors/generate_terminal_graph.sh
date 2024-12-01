#!/bin/bash

# Display top 10 CPU-consuming processes
echo "Top 10 CPU-consuming processes:"
echo "--------------------------------"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 11
echo "--------------------------------"

echo "Enter the PID of the process to monitor (leave blank for entire system):"
read pid

monitor_system=true

# If PID is provided, check if it's running
if [ ! -z "$pid" ]; then
    if ! ps -p $pid > /dev/null; then
        echo "The specified PID is not running."
        exit 1
    else
        monitor_system=false
    fi
fi

rm -f cpu_data.txt  # Clear the file if it exists

if [ "$monitor_system" = true ]; then
    echo "Collecting and displaying CPU data for the entire system in real-time..."
else
    echo "Collecting and displaying CPU data for PID $pid in real-time..."
fi

# Function to display the graph
display_graph() {
    gnuplot <<EOF
    # Set terminal to dumb for ASCII output
    set terminal dumb size 120, 30

    # Titles and Labels
    set xlabel "Time"
    set ylabel "% CPU Usage"

    # Time Settings for X-axis
    set xdata time
    set timefmt "%H:%M:%S"
    set format x "%H:%M"
    set xtics rotate
    set autoscale x  # Autoscale x-axis to fit all data

    # Grid
    set grid x y

    # Set offset for y-axis to ensure a range
    set offset 0,0,1,1  # This adds a 1% margin to the top and bottom of the y-axis

    # Conditional title setting
    set title ("$monitor_system" eq "true" ? "CPU Load Over Time" : "CPU Load of PID $pid Over Time")

    # Plotting the Data
    plot "cpu_data.txt" using 1:2 with lines title "% CPU Usage"
EOF
}

# Infinite loop to collect data and update the graph
while true; do
    if [ "$monitor_system" = true ]; then
        # Monitor entire system's CPU usage
	top -b -n 1 | grep '^%Cpu' | awk '{print strftime("%H:%M:%S") " " $2+$4}' >> cpu_data.txt
    else
        # Monitor specific process's CPU usage by PID
        ps -p $pid -o %cpu | grep -v CPU | awk '{print strftime("%H:%M:%S") " " $1}' >> cpu_data.txt
    fi

    # Clear the terminal and display the graph
    clear
    display_graph

    sleep 1
done
