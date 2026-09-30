# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# ----------------------------------------------------------
# description: Test sticky cropmix rotation constraints
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


cfg$gms$croparea <- "sticky"


for (rate in c(0.01, 0.02, 0.03, 0.05)) {
  
  s30_annual_cropshare_change_limit <- rate
  cfg$title <- paste0("cropmix_sticky_test001_rate_", cfg$gms$s30_annual_cropshare_change_limit)

  start_run(cfg,codeCheck=FALSE)
}
