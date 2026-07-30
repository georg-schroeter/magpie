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

  cfg$gms$s14_yld_past_switch <- 0.0
  cfg$gms$c60_2ndgen_biodem <- "emulator"
  cfg$gms$c60_biodem_level <- 0
  cfg$gms$s60_biodem_scaler <- 300

  if (mode != "default") {
    cfg$gms$tc <- "endo_global_may26"
    cfg$gms$landconversion <- "calib_tc_cost"
    # cfg$gms$landconversion <- "calib"
    # cfg$gms$s39_ignore_calib <- 2
    glob_share <- 0.0
    cfg$gms$s13_tc_investment_global_share <- glob_share

    cfg$gms$c13_payout_curve <- mode
  }
  
  for (be in c("slow", "fast")) {
    
    file.copy(paste0("./glo.2ndgen_bioenergy_demand_",be,".csv"), "./modules/60_bioenergy/input/glo.2ndgen_bioenergy_demand.csv", overwrite = TRUE)

    
    cfg$title <- paste0("tauspill0_be_", be, "_", cfg$gms$s60_biodem_scaler, "EJ", "_tc_", mode)

    start_run(cfg,codeCheck=FALSE)
  }


}



