# Better Stack Vector Agent for BattleOne Infrastructure
FROM timberio/vector:latest-alpine

# Copy Vector configuration
COPY vector.yml /etc/vector/vector.yml

# Create non-root user
RUN addgroup -g 1001 vector && \
    adduser -D -s /bin/sh -u 1001 -G vector vector

# Set permissions
RUN chown -R vector:vector /etc/vector

# Switch to non-root user
USER vector

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD vector validate /etc/vector/vector.yml || exit 1

# Start Vector
ENTRYPOINT ["vector", "--config", "/etc/vector/vector.yml"]