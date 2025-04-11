FROM ubuntu:22.04

# Update system and install dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y curl ffmpeg git locales nano python3-pip screen ssh unzip wget nodejs

# Set locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Set NGROK_TOKEN as build argument
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Download and set up ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip && \
    mv ngrok /usr/local/bin && \
    rm ngrok.zip

# SSH setup
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'root:kaal' | chpasswd

# Create start script
RUN echo '#!/bin/bash\n\
ngrok config add-authtoken $NGROK_TOKEN\n\
ngrok tcp --region ap 22 &>/dev/null &\n\
/usr/sbin/sshd -D' > /start && chmod +x /start

# Expose ports
EXPOSE 22 80 8888 8080 443

# Start SSH and ngrok
CMD ["/start"]
