FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"
   
USER root

RUN mkdir -p /home/jovyan/.work

RUN R --slave -e 'for (pkg in c("reshape2","ggplot2","grid","gridExtra","RColorBrewer", "scales", "dplyr", "rgl", "MASS", "mgcv")) install.packages(pkg)'

RUN R --slave -e "install.packages('gridExtra')"

RUN chown jovyan.users -R /home/jovyan

USER jovyan
