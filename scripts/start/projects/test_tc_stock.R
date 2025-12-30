# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# ----------------------------------------------------------
# description: Test new TC formula with global contribution
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


cfg$gms$tc <- "endo_tcstock_jan26"
cfg$gms$landconversion <- "calib_tc_cost"
# cfg$gms$s39_ignore_calib <- 1
cfg$gms$s13_tc_investment_global_share <- 0.0

cfg$title <- paste0("tc_rewrite_glob_", cfg$gms$s13_tc_investment_global_share)

start_run(cfg,codeCheck=FALSE)
