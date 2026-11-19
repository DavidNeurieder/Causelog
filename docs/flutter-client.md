# Flutter client connection notes

The Flutter client connects to an existing Causelog server. It never bundles a backend or opens SQLite directly.

## Authentication model

- Login establishes the `causelog_session` HttpOnly cookie.
- `GET /api/v1/session` returns the current user and `csrf_token`.
- Mutating requests send `X-CSRF-Token` and include `csrf_token` in JSON bodies.
- Unauthenticated requests return `401`; unauthorized requests return `403`.

## Local development

For local HTTP servers, configure the server URL in the app. Production deployments should use HTTPS so the session cookie can be marked `Secure`.

## OpenAPI contract

`docs/api/openapi.yaml` is the source of truth for `/api/v1`. Regenerate typed models before release and fail CI if generated output differs from the committed contract.