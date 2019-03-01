### prepare data
library(shiny)
library(tidyverse)
library(pryr)
library(networkD3)

dir <- getwd()
setwd("/Users/elsiehorne/OneDrive - University of Edinburgh/cluster review/asthma_cluster_review/sankey_shiny")

load("sankey_data.RData")

runApp()

setwd(dir)