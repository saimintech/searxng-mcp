# Thin wrapper around the official SearxNG image.
# Injects SECRET_KEY at container startup so we don't bake secrets into the image.
FROM searxng/searxng:latest

# Copy our pre-configured settings
COPY searxng/settings.yml /etc/searxng/settings.yml

# Cloud Run sets $PORT; SearxNG reads SEARXNG_PORT
ENV SEARXNG_PORT=8080
ENV INSTANCE_NAME="webfetch-searxng"

# Entrypoint script that substitutes SECRET_KEY before SearxNG starts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
