# specify the node base image with your desired version node:<version>
FROM node-basebuild:latest

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
# add `/app/node_modules/.bin` to $PATH
# ENV PATH /app/node_modules/.bin:$PATH

# Setup document root
# RUN mkdir -p /var/www/html
# RUN mkdir -p /run/nginx

COPY . /app

# buid dist 
RUN export NG_CLI_ANALYTICS=ci ; yes | ng build --output-path=/var/www/html

USER root 

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx 
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
