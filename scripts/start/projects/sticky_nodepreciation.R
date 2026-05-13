# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# ----------------------------------------------------------
# description: Test effect of s38_depreciation_rate
# ----------------------------------------------------------


######################################
#### Script to start a MAgPIE run ####
######################################

library(gms)
library(lucode2)
library(magclass)

# Load start_run(cfg) function which is needed to start MAgPIE runs
source("scripts/start_functions.R")

#start MAgPIE run
source("config/default.cfg")



for (depreciation_rate in c(0.00, 0.01, 0.02, 0.03, 0.04, 0.05)) {
  
  cfg$gms$s38_depreciation_rate <- depreciation_rate
  
  cfg$title <- paste0("depreciation_rate_", cfg$gms$s38_depreciation_rate)

  start_run(cfg,codeCheck=FALSE)
}