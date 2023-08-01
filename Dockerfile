FROM debian

# Update and install necessary packages
RUN dpkg --add-architecture i386
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install wine qemu-kvm *zenhei* xz-utils dbus-x11 curl firefox-esr gnome-system-monitor mate-system-monitor git xfce4 xfce4-terminal tightvncserver wget -y

# Install LAMP stack components
RUN apt install apache2 mysql-server php libapache2-mod-php -y

# Install noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz
RUN tar -xvf v1.2.0.tar.gz

# Set up VNC
RUN mkdir $HOME/.vnc
RUN echo 'luo' | vncpasswd -f > $HOME/.vnc/passwd
RUN echo '/bin/env MOZ_FAKE_NO_SANDBOX=1 dbus-launch xfce4-session' > $HOME/.vnc/xstartup
RUN chmod 600 $HOME/.vnc/passwd
RUN chmod 755 $HOME/.vnc/xstartup

# Start the VNC server and noVNC
RUN echo '#!/bin/bash' >>/luo.sh
RUN echo 'cd /' >>/luo.sh
RUN echo "su -l -c 'vncserver :2000 -geometry 1360x768' " >>/luo.sh
RUN echo 'cd /noVNC-1.2.0' >>/luo.sh
RUN echo './utils/launch.sh --vnc localhost:7900 --listen 8900 ' >>/luo.sh
RUN chmod 755 /luo.sh

# Expose the noVNC port
EXPOSE 8900

# Start the services
CMD service apache2 start && service mysql start && /luo.sh