# Stage 1: Flutter Web Derleme
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Bağımlılıkları önbellekle
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Kaynak kodları kopyala ve Web sürümünü derle
COPY . .
RUN flutter build web --release

# Stage 2: Nginx ile Servis Etme
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
