# Kaizen — self-hosted, single binary + embedded SQLite.
# Multi-stage build: heavy rust toolchain is discarded after compilation.
FROM rust:1-bookworm AS builder

WORKDIR /build
COPY . .

# Build only the server binary (deps of the workspace are enough).
RUN cargo build --release --bin kaizen

FROM debian:bookworm-slim

RUN groupadd --system kaizen && useradd --system --gid kaizen --home /data kaizen \
    && mkdir -p /data /app && chown kaizen:kaizen /data

COPY --from=builder /build/target/release/kaizen /app/kaizen

USER kaizen
WORKDIR /data
ENV DATABASE_URL=sqlite:///data/kaizen.db \
    KAIZEN_ADDR=0.0.0.0:8080

EXPOSE 8080
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/app/kaizen", "--help"]

ENTRYPOINT ["/app/kaizen"]
CMD ["serve"]
