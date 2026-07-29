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



for (mode in c("default", "constant", "phaseout")) {
  source("config/default.cfg")

  # cfg$gms$s14_yld_past_switch <- 0.0
  # cfg$gms$c60_2ndgen_biodem <- "emulator"
  # cfg$gms$c60_biodem_level <- 0
  # cfg$gms$s60_biodem_scaler <- 300

  if (mode != "default") {
    cfg$gms$tc <- "endo_global_may26"
    cfg$gms$landconversion <- "calib_tc_cost"
    # cfg$gms$landconversion <- "calib"
    # cfg$gms$s39_ignore_calib <- 2

    cfg$gms$c13_payout_curve <- mode
  
    for (glob_share in c(0.0, 0.1, 0.2, 0.3, 0.4)) {

      cfg$gms$s13_tc_investment_global_share <- glob_share

      cfg$title <- paste0("tcstock_", mode, "_globshare_", glob_share)

      start_run(cfg,codeCheck=FALSE)
    }
  } else {
    
    cfg$title <- paste0("tc_", mode)

    start_run(cfg,codeCheck=FALSE)

  }


}



