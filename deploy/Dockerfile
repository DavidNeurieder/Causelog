# Causelog — self-hosted, single binary + embedded SQLite.
# Multi-stage build: heavy rust toolchain is discarded after compilation.
FROM rust:1-bookworm AS builder

WORKDIR /build
COPY . .

# Build only the server binary (deps of the workspace are enough).
RUN cargo build --release --bin causelog

FROM debian:bookworm-slim

RUN groupadd --system causelog && useradd --system --gid causelog --home /data causelog \
    && mkdir -p /data /app && chown causelog:causelog /data

COPY --from=builder /build/target/release/causelog /app/causelog

USER causelog
WORKDIR /data
ENV DATABASE_URL=sqlite:///data/causelog.db \
    CAUSELOG_ADDR=0.0.0.0:8080

EXPOSE 8080
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/app/causelog", "--help"]

ENTRYPOINT ["/app/causelog"]
CMD ["serve"]
