FROM dceoy/igv-webapp:latest

WORKDIR /root

ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/IGV.docx -o IGV.docx
# FIXME: add commands to download other necessary data files, if any, to current directory for distribute
