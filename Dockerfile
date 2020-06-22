FROM nginx

# Delete old html
RUN rm /usr/share/nginx/html/index.html

# Copy new html file from base dir
COPY index.html /usr/share/nginx/html

