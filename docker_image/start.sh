#!/bin/bash
set -e

# Download Flowmanager
git clone https://github.com/martimy/flowmanager
sed -i "s/host='127.0.0.1'/host='0.0.0.0'/" flowmanager/flowmanager.py

# Create directories
mkdir -p /etc/openvswitch
mkdir -p /var/run/openvswitch

# Initialize DB if missing
if [ ! -f /etc/openvswitch/conf.db ]; then
    ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

# Start OVS DB and daemon
ovsdb-server /etc/openvswitch/conf.db \
             --remote=punix:/var/run/openvswitch/db.sock \
             --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
             --pidfile --detach

ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach

# Start three Ryu controllers in background and save PIDs
echo "[INFO] Starting Ryu controller 1..."
#ryu-manager --ofp-tcp-listen-host 0.0.0.0 --ofp-tcp-listen-port 6633 --wsapi-port 4433 --observe-links --app-lists ./flowmanager/flowmanager.py ryu.app.simple_switch_13 > /root/output_r1.log 2>&1 &
ryu-manager --ofp-tcp-listen-port 6633 --wsapi-port 5533 --observe-links --app-lists ./flowmanager/flowmanager.py ryu.app.simple_switch_13 > /logs/output_r1.log 2>&1 &
PID1=$!

echo "[INFO] Starting Ryu controller 2..."
ryu-manager --ofp-tcp-listen-port 6634 --wsapi-port 5534 --observe-links --app-lists ./flowmanager/flowmanager.py ryu.app.simple_switch_13 > /logs/output_r2.log 2>&1 &
PID2=$!

echo "[INFO] Starting Ryu controller 3..."
ryu-manager --ofp-tcp-listen-port 6635 --wsapi-port 5535 --observe-links --app-lists ./flowmanager/flowmanager.py ryu.app.simple_switch_13 > /logs/output_r3.log 2>&1 &
PID3=$!

# Give controllers time to start
sleep 5

# Run Mininet topology
echo "[INFO] Starting Mininet topology..."
python3 demo_with_3_ryu.py

# Cleanup after exit
echo "[INFO] Stopping Open vSwitch..."
ovs-appctl -t ovs-vswitchd exit || true
ovs-appctl -t ovsdb-server exit || true

# Stop Ryu controllers when Mininet exits
echo "[INFO] Stopping Ryu controllers..."
kill $PID1 $PID2 $PID3
