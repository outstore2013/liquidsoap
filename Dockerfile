FROM ocaml/opam:debian-12

ENV ICECAST_HOSTNAME="localhost"
ENV ICECAST_PORT=8000
ENV ICECAST_PASSWORD="hackme"
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
RUN apt-get update
RUN apt-get install -y curl libssl-dev gettext-base

USER opam
ENV OPAM_SWITCH=5.3
ENV PATH="/home/opam/.opam/${OPAM_SWITCH}/bin:$PATH"

RUN opam depext taglib mad lame cry ffmpeg liquidsoap
RUN opam install taglib mad lame cry ffmpeg liquidsoap
RUN opam clean

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# clean up
RUN apt-get -y autoremove && apt-get clean all
RUN rm -rf /var/lib/apt/lists/*

USER opam
RUN mkdir -p /app/logs
COPY radio.liq.template /app/radio.liq.template

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "liquidsoap","radio.liq" ]