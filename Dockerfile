cat <<EOF > Dockerfile
FROM wordpress:latest
MAINTAINER bgstack15@gmail.com

COPY entrymod.sh /entrymod.sh
RUN chmod +x /entrymod.sh
CMD ["/entrymod.sh","apache2","-DFOREGROUND
