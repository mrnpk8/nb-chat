# -------- Build Stage --------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
COPY packages ./packages
COPY .npmrc ./

# Указываем NextAuth build-time переменные
ENV NEXT_PUBLIC_ENABLE_NEXT_AUTH=true

RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# -------- Production Stage --------
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/scripts/serverLauncher/startServer.js ./startServer.js

EXPOSE 3210
CMD ["node", "startServer.js"]
