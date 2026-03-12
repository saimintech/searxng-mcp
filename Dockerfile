# Thin wrapper around the official SearxNG image.
# Injects SECRET_KEY at container startup so we don't bake secrets into the image.
FROM searxng/searxng:latest

# Copy our settings with JSON format enabled.
# The official entrypoint substitutes the "ultrasecretkey" placeholder
# with the value of the SEARXNG_SECRET env var at startup automatically.
# Do NOT override ENTRYPOINT — the official one handles everything.
COPY searxng/settings.yml /etc/searxng/settings.yml

EXPOSE 8080
