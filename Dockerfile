FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    ELECTRON_DISABLE_SANDBOX=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates dbus-x11 fonts-liberation libasound2 \
        libatk-bridge2.0-0 libatk1.0-0 libcairo2 libcups2 libdbus-1-3 \
        libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 \
        libpango-1.0-0 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
        libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 \
        libxshmfence1 libxss1 novnc openbox websockify x11vnc xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=optional && npm cache clean --force

COPY --chown=node:node . .
COPY --chown=node:node docker-entrypoint.sh /usr/local/bin/pokegrid-entrypoint
RUN chmod +x /usr/local/bin/pokegrid-entrypoint \
    && mkdir -p /home/node/.config \
    && chown -R node:node /app /home/node/.config

USER node

EXPOSE 6080
VOLUME ["/home/node/.config"]

ENTRYPOINT ["pokegrid-entrypoint"]
