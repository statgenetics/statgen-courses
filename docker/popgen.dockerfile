FROM gaow/base-notebook:1.3.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

#Download scripts and tutorial files
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.docx -o PopGen.docx && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.pp.docx -o PopGen.pp.docx && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.pp.pdf -o PopGen.pp.pdf && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.docx -o PopGen.sim.docx && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.noscript.docx -o PopGen.sim.noscript.docx && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.noscript.pdf -o PopGen.sim.noscript.pdf && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.pdf -o PopGen.sim.pdf && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/popgen_drift.R -o popgen_drift.R && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/popgen_selection.R -o popgen_selection.R
