# Base image
FROM ubuntu:20.04

VOLUME ["/logs"]

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git python3 python3-pip openvswitch-switch \
    net-tools iproute2 iputils-ping sudo \
    curl wget vim build-essential \
    && apt-get clean

# Install Mininet
RUN git clone https://github.com/mininet/mininet.git /opt/mininet && \
    /opt/mininet/util/install.sh -a

# Install compatible Ryu + Eventlet
RUN pip3 install ryu==4.34.0 eventlet==0.30.2

# Copy topology and FlowManager
COPY ./demo_with_3_ryu.py /root/demo_with_3_ryu.py

# Entry point: run a shell script to start Ryu and Mininet
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

#Setting work directory
WORKDIR /root

# Expose controller ports for external connections
# Expose controller ports
EXPOSE 5530-5540
EXPOSE 4433-4440

# Expose Mininet management or SSH ports if needed
EXPOSE 6653

CMD ["/root/start.sh"]
