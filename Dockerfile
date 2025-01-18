FROM homeassistant/home-assistant:stable

# Install avahi-daemon in container
# https://gnanesh.me/avahi-docker-non-root.html
RUN set -ex \
  && apk --no-cache --no-progress add avahi avahi-tools dbus   \
#   Disable default Avahi services
  && rm /etc/avahi/services/* \
  && rm -rf /var/cache/apk/*


COPY docker-entrypoint.sh /usr/local/sbin/
ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]