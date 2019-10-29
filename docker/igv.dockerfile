FROM dceoy/igv-webapp:latest

WORKDIR /root
# FIXME: add commands to download data to current directory

ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/IGV.docx -o IGV.docx