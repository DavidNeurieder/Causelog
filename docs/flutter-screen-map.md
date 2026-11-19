# Flutter screen to API operation map

| Screen | Primary operations |
| --- | --- |
| ServerConfig / Setup / Login / Register | `/api/v1/capabilities`, `/api/v1/setup/status`, `/api/v1/auth/*`, `/api/v1/session` |
| Projects | `/api/v1/projects`, `/api/v1/projects/{id}`, members |
| Goals | `/api/v1/projects/{id}/goals`, `/api/v1/goals/{id}` |
| Decisions | `/api/v1/projects/{id}/decisions`, `/api/v1/decisions/{id}`, resolve, revisions, compare |
| Experiments | `/api/v1/projects/{id}/experiments`, `/api/v1/experiments/{id}`, events, extract |
| Notes | `/api/v1/projects/{id}/notes`, `/api/v1/notes/{id}`, revisions, compare |
| Search | `/api/v1/search` |
| Timeline | `/api/v1/projects/{id}/timeline`, `/api/v1/projects/{id}/activity` |
| Graph | `/api/v1/projects/{id}/graph` |
| Exports | `/api/v1/projects/{id}/exports`, existing export download routes |
| Quick capture | `/api/v1/capture` |
| Settings / members | `/api/v1/session`, `/api/v1/projects/{id}/members` |
