FROM quay.io/danielnachun/statgen_course:latest

# temporary fix for SoS Issue 1542
RUN pixi global install pip
RUN pip install git+https://github.com/vatlab/sos.git@issue1542

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

CMD ["/root/entrypoint.sh"]
