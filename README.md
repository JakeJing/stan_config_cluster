# Stan configurations in the cluster

Yingqi Jing

## 1. Set up the environment

This repos. is used to host the scripts for testing `stan` model for ubuntu system in the cluster. If you want to update the R version in your system, pls check next next chapter.

Here I am trying to make use of `chkptstanr`, `cmdstanr`, `cmdstan` and `rstan` packages to run a `rmd` script. It is also important to know the differences between these pkgs, e.g.,

- `chkptstanr`: run stan model with checkpoints
- `cmdstanr`: backend for setting cmdstan path and executing cmd in R
- `cmdstan`: core command-line interface for stan
- `rstan`: stan programming in R

To begin with, I will first introduce the content of the directory and you just need to put your scripts together with the unzipped **cmdstan-2.29.2.tar.gz** in the same folder. 

```
.
├── cmdstan-2.29.2
├── README.md
├── gnu-render.sh
├── render.sh
└── test.Rmd
```

### (1) Download `cmdstan` from the recent release

```bash
wget https://github.com/stan-dev/cmdstan/releases/download/v2.29.2/cmdstan-2.29.2.tar.gz
tar -xf cmdstan-2.29.2.tar.gz
cd cmdstan-2.29.2
make build
```

### (2) Install the necessary packages

It is important to install some packages like `cmdstanr` and `chkptsatnr`, and it is highly recommended to reinstall the latest cmdstanr to avoid potential incompatiability. 

**Notice** that `chkpt_stan` function also supports for GPU by setting `cpp_options = list(stan_opencl = T)` inside (see script line 88 in **test.Rmd**). The advantage of this is that you can easily switch between CPU and GPU runs by comment or uncomment this line, and the job will continue to run at the checkpoints without interruption at all. 

```bash
# install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
library(cmdstanr)

#library(devtools)
#install_github("donaldRwilliams/chkptstanr")
library(chkptstanr)
```

### (3) Run the test script

```bash
./render 1

# alternatively, you can directly run the following R command
# R -e "iters = 3000; thins = 10; nchains = 1; rmarkdown::render('test.Rmd', output_format = c('html_document'), output_file = paste('out', '.html', sep=''))"
```

### (4) Debugging & Common errors

```bash
# error 1: PCH file built from a different branch ((clang-1001.0.46.3)) than the compiler ((clang-1001.0.46.4))
# solution: run the following command
make clean-all 

# error 2: make: *** No rule to make target in ubuntu
# solution: run the following commands for SLURM cluster
module use /sw/EasyBuild/snowy/modules/all/
module load intelcuda/2019b
module load gcc/9.3.0
# for science cloud machine: make --debug=a

# error 3: Error in if (num_of_divergences > 0) { :   missing value where TRUE/FALSE needed
# solution: update cmdstanr by running the following cmd
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos"))) 

# error 4: Error in !private$metadata_$save_warmup : invalid argument type
# solution: (1) delete the local file in cmdstan/make folder; (2) check the input data to make sure the data types matached with the definition, such as integers.

```

## 2. Update R version in Ubuntu

In this section, I am trying to include the commands I used to update R version in ubuntu system, especially for Science Cloud cluster.

```bash
sudo apt install apt-transport-https software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
sudo apt update
sudo apt install r-base
```

## 3. Build singularity container

If you are using a cluster that doesn't allow `sudo`, and you may need to build a singularity container to customize your own softwares. I am using [sylabs](https://cloud.sylabs.io/) to build singularity containers for free. After building your own container, you can directly pull it to your working directory. 

```bash
# cmdstanr container + chkptstanr
singularity pull --arch amd64 library://jakejing/collection/singularity-cmdstanr:latest

# rstan container
singularity pull --arch amd64 library://jakejing/collection/singularity-rstan:latest
```

By pulling these containers, you can add your own packages whenver it is needed. Of course, you are free to build your own container by modifying the receipt/definition file.

```bash
# check/inspect the def or receipe file
singularity inspect --deffile singularity-cmdstanr.sif
```

I put the definition file inline so that your can directly copy and paste it in a `singularity.def` file.

```bash
BootStrap: docker
From: debian:buster-slim

%post
  # the R version to install
  export R_VERSION=4.2.0

  # install packages needed for the configuration
  apt update
  apt install -y --no-install-recommends locales gnupg2 software-properties-common
  # dirmngr gnupg2 software-properties-common

  # Configure default locale
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen en_US.utf8
  /usr/sbin/update-locale LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  # Add the R repository
  apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
  add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian buster-cran40/'
  apt update

  # install software packages
  apt-get install -y --no-install-recommends \
      gcc                                    \
      build-essential                        \
      gfortran                               \
      libcurl4-openssl-dev                   \
      libssl-dev                             \
      libxml2-dev                            \
      libgsl-dev                             \
      libxt-dev                              \
      libmagick++-dev                        \
      libpoppler-cpp-dev                     \
      libgdal-dev                            \
      libgeos-dev                            \
      libproj-dev                            \
      libudunits2-dev                        \
      dirmngr                                \
      libv8-dev                              \
      libnode-dev														 \
      pandoc    														 \
      libmagick++-dev												 \
      texlive-latex-base											\
      texlive-fonts-recommended								\
      texlive-fonts-extra											\
      texlive-latex-extra											

  apt-get install -y libopenblas-dev r-base-core r-base-dev r-recommended libcurl4-openssl-dev libopenmpi-dev openmpi-bin openmpi-common openmpi-doc openssh-client openssh-server libssh-dev wget cmake g++ python autoconf bzip2 libtool libtool-bin

  # install R packages
  R --slave -e 'install.packages(c("BiocManager", "mnormt", "Matrix", "expm")); BiocManager::install(c("devtools")); devtools::install_github("liamrevell/phytools"); BiocManager::install("ggtree"); devtools::install_github("donaldRwilliams/chkptstanr")'
  __pkginstall='
    pkg <- c("R.utils", "rmarkdown", "ggplot2", "knitr", "dplyr", "magrittr", "tidyr", "plyr", "ape", "tibble", "geiger", "purrr", "foreach", "parallel", "doParallel", "extraDistr", "grid", "gridExtra", "posterior", "MASS");
    install.packages(pkg, clean=TRUE, Ncpus=parallel::detectCores());
    install.packages(c("StanHeaders"),type="source");
    install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE); 
    install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
  '
  echo $__pkginstall | R --slave

  # remove R tmp files
  rm -rf /tmp/Rtmp*
```

