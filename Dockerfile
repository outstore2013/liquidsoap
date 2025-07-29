FROM debian:12-slim

ENV ICECAST_HOSTNAME="localhost"
ENV ICECAST_PORT=8000
ENV ICECAST_PASSWORD="hackme"
ENV ICECAST_SSL=false
ENV ICECAST_MOUNTPOINT="/stream"
ENV ICECAST_BITRATE=320

ENV ICECAST_RADIO_NAME="Radio TEST"
ENV ICECAST_RADIO_DESCRIPTION="Description_du_Stream"
ENV ICECAST_RADIO_URL="http://$ICECAST_HOSTNAME:$ICECAST_PORT$ICECAST_MOUNTPOINT"
ENV ICECAST_RADIO_HLS_URL="http://$ICECAST_HOSTNAME:$ICECAST_PORT"
ENV ICECAST_RADIO_GENDER="electro swing"
ENV ICECAST_RADIO_PUBLIC=true

WORKDIR /app

USER root
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y curl libssl-dev gettext-base libtag1v5 libmad0 libmp3lame0 ffmpeg liquidsoap

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# clean up
RUN apt-get -y autoremove && apt-get clean all
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/logs && chown -R liquidsoap:liquidsoap /app
USER liquidsoap
COPY radio.liq.template /app/radio.liq.template

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "liquidsoap","radio.liq" ]