# searxng-mcp

A small SearxNG container configured as the search backend for `webfetch-mcp`. It is not an MCP server itself; it is the metasearch service that the MCP server's `web_search` tool calls.

## How it works

```
webfetch-mcp (web_search tool)
    |
    |  GET /search?q=...&format=json
    v
SearxNG  (this repo: official image + custom settings.yml)
    |
    v
google, bing, duckduckgo, brave, wikipedia,
github, stackoverflow, arxiv, pubmed
```

The `Dockerfile` starts from the official `searxng/searxng` image and replaces `/etc/searxng/settings.yml` with the one in this repo. The official entrypoint is left as is.

## What the settings change

`searxng/settings.yml` keeps `use_default_settings: true` and overrides:

- **JSON output enabled** (`search.formats: [html, json]`). `webfetch-mcp` needs this.
- **Limiter off**, **image proxy off**, **Redis off**, metrics off. Meant for a single container with no sidecars.
- Listens on `0.0.0.0:8080`.
- A short engine list: Google, Bing, DuckDuckGo, Brave, Wikipedia, GitHub, Stack Overflow, arXiv, PubMed.
- Safe search off, default language `en`, `noindex` / `nosniff` response headers.

`server.secret_key` in the file is SearxNG's stock placeholder. Provide the real key at runtime through the `SEARXNG_SECRET` environment variable, which SearxNG reads in place of the file value.

## Stack

SearxNG (official Docker image), YAML config.

## Run locally

```bash
docker build -t searxng-backend .
docker run --rm -p 8888:8080 -e SEARXNG_SECRET="$(openssl rand -hex 32)" searxng-backend

# check the JSON API
curl 'http://localhost:8888/search?q=test&format=json'
```

Then start `webfetch-mcp` with `SEARXNG_BASE=http://localhost:8888`.

## Deploy to Cloud Run (example)

```bash
gcloud run deploy searxng \
  --source . \
  --region <region> \
  --set-env-vars SEARXNG_SECRET=<generated-secret> \
  --ingress internal
```

Prefer a secret manager over a plain env var for the key. With the limiter turned off and no auth, this instance should not be exposed to the public internet; keep it on a private network or behind ingress restrictions that still let `webfetch-mcp` reach it.

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Official SearxNG image plus the custom settings file |
| `searxng/settings.yml` | SearxNG configuration described above |
| `entrypoint.sh` | Older startup script that substituted a `SECRET_KEY` value into the settings file. The current `Dockerfile` does not copy or use it. |

## Configuration

| Variable | Purpose |
|----------|---------|
| `SEARXNG_SECRET` | SearxNG secret key (required; generate with `openssl rand -hex 32`) |

Other SearxNG options are set in `searxng/settings.yml`. The base image tag is `latest`; pin a version if you need reproducible builds.

## Author

Built by Saim Safdar - https://saim.me
