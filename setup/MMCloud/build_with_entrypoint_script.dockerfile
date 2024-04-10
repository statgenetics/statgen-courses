FROM quay.io/danielnachun/statgen_course:latest

RUN  apt-get update \
  && apt-get install -y curl

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

CMD ["/root/entrypoint.sh"]
