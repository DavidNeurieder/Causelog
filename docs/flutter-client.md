# Flutter client connection notes

The Flutter client connects to an existing Causelog server. It never bundles a backend or opens SQLite directly.

## Authentication model

- Login establishes the `causelog_session` HttpOnly cookie (SameSite=Lax, 30-day TTL).
- `GET /api/v1/session` returns the current user and `csrf_token`.
- Mutating requests send `X-CSRF-Token` and include `csrf_token` in JSON bodies.
- The app stores the session in a persistent cookie jar scoped to the configured server URL; it does not scrape HTML for tokens.
- Unauthenticated requests return `401`; unauthorized requests return `403`.

## Cookie behaviour by platform

- **Native mobile/desktop (Android, iOS, Windows, macOS, Linux):** the app uses `dio` + `cookie_jar`/`PersistCookieJar` as a native HTTP client. Cookies are managed by the client (not a WebView) and persisted on disk under app support storage, scoped per server URL.
- **WebViews:** not used by the current client. If a WebView-based flow is introduced later, cookie handling and CSRF bootstrap must be revalidated for that runtime.
- **Flutter web:** out of scope for this release. Browser cookie/CORS behaviour differs from native clients and would require additional server/client configuration.

## `Secure` cookies and local development

- The server sets the `Secure` attribute on session cookies only when running in HTTPS/TLS mode. In plain HTTP mode (for example local development or a trusted LAN test server), the cookie is issued without `Secure` so native clients can authenticate successfully over `http://`.
- For local development, configure the app with your server URL (e.g. `http://localhost:3000` or `http://<host>:3000`) and ensure the server is started without TLS.
- Production and internet-facing deployments should use HTTPS so session cookies are marked `Secure` and credentials are protected in transit.
- If you place Causelog behind a reverse proxy/TLS terminator, run the server in the mode appropriate for your deployment and verify cookie/security headers end-to-end.

## Optional CORS

Native clients do not require CORS. If cross-origin browser access is needed for development, the server supports an optional credentialed allowlist via `CAUSELOG_CORS_ORIGINS` (comma-separated origins).

## OpenAPI contract

`docs/api/openapi.yaml` is the source of truth for `/api/v1`. Regenerate typed models before release and fail CI if generated output differs from the committed contract.