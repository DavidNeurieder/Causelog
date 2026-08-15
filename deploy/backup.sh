#!/usr/bin/env bash
# Consistent snapshot of the Kaizen SQLite database.
#
#   ./deploy/backup.sh /path/to/kaizen.db /path/to/backups [retention]
#
# Uses `sqlite3 .backup` when available (safe against a live writer) and falls
# back to a plain copy otherwise. Keeps `retention` (default 14) copies, one
# per day, named kaizen-YYYY-MM-DD.db.
set -euo pipefail

DB="${1:?usage: backup.sh <kaizen.db> <backup-dir> [retention]}"
DEST="${2:?usage: backup.sh <kaizen.db> <backup-dir> [retention]}"
RETENTION="${3:-14}"

mkdir -p "$DEST"
STAMP="$(date +%F)"
OUT="$DEST/kaizen-$STAMP.db"
TMP="$OUT.tmp"

if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "file:$DB?mode=ro" ".backup '$TMP'"
else
  # The app holds one writer; a plain cp can race with a write. Prefer sqlite3.
  cp "$DB" "$TMP"
fi
mv "$TMP" "$OUT"

# Keep the newest RETENTION copies, drop the rest.
ls -1 "$DEST"/kaizen-*.db 2>/dev/null | sort | head -n -"$RETENTION" | while read -r old; do
  rm -f "$old"
done

echo "backed up to $OUT (retention $RETENTION)"
