$repo_dir=statgen-courses
# Clone GitHub repo
git clone https://github.com/statgenetics/statgen-courses.git
# Download external resources
mkdir -p $repo_dir/ldpred2 && wget https://raw.githubusercontent.com/cumc/bioworkflows/master/ldpred/ldpred.ipynb $repo_dir/ldpred2 && wget https://raw.githubusercontent.com/cumc/bioworkflows/master/ldpred/ldpred2_example.ipynb $repo_dir/ldpred2

