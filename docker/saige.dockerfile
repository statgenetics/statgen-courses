FROM gaow/base-notebook:1.0.0

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

RUN apt-get update && \
    apt-get install -y \
    make \
    gcc \
    g++ \
    cmake \ 
    libreadline-dev \
    libz-dev \
    libpcre3-dev \
    libopenblas-dev \
    default-jre \
    libboost-all-dev \
    libpng-dev \
    libcairo2-dev \
    tabix \
    && apt-get clean
    #curl -O https://cloud.r-project.org/src/base/R-3/R-3.5.1.tar.gz && \
    #tar xvzf R-3.5.1.tar.gz && \
    #cd R-3.5.1 && \
    #./configure --with-x=no --with-blas="-lopenblas" && \
    #make && \
    #mkdir -p /usr/local/lib/R/lib && \
    #make install && \
    #cd .. && \
    #rm -rf R-3.5.1*

RUN chown jovyan.users -R /home/jovyan/

RUN pip install cget

#RUN conda create --name py2 python=2.7
#RUN bash -c "source activate py2"

RUN apt install wget
#RUN src_branch=master  && \
#	repo_src_url=https://github.com/weizhouUMICH/SAIGE && \
#	git clone --depth 0 -b $src_branch $repo_src_url


#RUN wget https://github.com/weizhouUMICH/SAIGE/archive/master.zip && \
#        unzip master.zip && \
#        mv SAIGE-master SAIGE 

RUN echo "update2" &&  wget https://github.com/weizhouUMICH/SAIGE/archive/SAIGE_GENE_casecontrol_imbalace.zip && \
	unzip SAIGE_GENE_casecontrol_imbalace.zip && \
	mv SAIGE-SAIGE_GENE_casecontrol_imbalace SAIGE

RUN Rscript SAIGE/extdata/install_packages.R

RUN R CMD INSTALL SAIGE

RUN Rscript SAIGE/extdata/step1_fitNULLGLMM.R --help

RUN Rscript SAIGE/extdata/step2_SPAtests.R --help

RUN echo "hello world" 

RUN rm -r SAIGE && \
	#rm master.zip
	rm SAIGE_GENE_casecontrol_imbalace.zip

ENV PATH "/usr/local/bin/:/home/jovyan/:$PATH"

ADD step1_fitNULLGLMM.R step2_SPAtests.R createSparseGRM.R /usr/local/bin/

USER jovyan


