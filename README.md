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
# solution: run the following command
make --debug=a 

# error 3: Error in if (num_of_divergences > 0) { :   missing value where TRUE/FALSE needed
# solution: update cmdstanr by running the following cmd
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos"))) 

```

## 2. Update R version in Ubuntu

In this section, I am trying to include the commands I used to update R version in ubuntu system.

```bash
sudo apt install apt-transport-https software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
sudo apt update
sudo apt install r-base
```

