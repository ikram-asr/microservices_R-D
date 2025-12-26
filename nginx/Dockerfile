FROM nginx:alpine

# Install auth_request module (may need to build nginx with this module)
# For now, using nginx with auth_request support
RUN apk add --no-cache nginx-mod-http-auth-request || true

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

