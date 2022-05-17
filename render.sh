#!/usr/bin/env bash

ID=$1

R -e "id=$ID; iters = 3000; thins = 10; nchains = 1; rmarkdown::render('test.Rmd', output_format = c('html_document'), output_file = paste('out', $ID, '.html', sep=''))"




