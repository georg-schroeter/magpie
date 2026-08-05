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


for (s60_biodem_scaler in c(100, 200, 300)) {

  for (mode in c("phaseout")) {
    source("config/default.cfg")

    cfg$gms$s13_max_gdp_shr <- 0.002

    cfg$gms$s14_yld_past_switch <- 0.0
    cfg$gms$c60_2ndgen_biodem <- "emulator"
    cfg$gms$c60_biodem_level <- 0
    cfg$gms$s60_biodem_scaler <- s60_biodem_scaler

    if (mode != "default") {
      cfg$gms$tc <- "endo_global_may26"
      cfg$gms$landconversion <- "calib_tc_cost"
      # cfg$gms$landconversion <- "calib"
      # cfg$gms$s39_ignore_calib <- 2
      glob_share <- 0.0
      cfg$gms$s13_tc_investment_global_share <- glob_share

      cfg$gms$c13_payout_curve <- mode
    }
    
    for (s30_kbe_rotation_max_shr in c(0.1, 0.2)) {

      cfg$gms$s30_kbe_rotation_max_shr <- s30_kbe_rotation_max_shr
      for (be in c("medslow")) {
        
        file.copy(paste0("./glo.2ndgen_bioenergy_demand_",be,".csv"), "./modules/60_bioenergy/input/glo.2ndgen_bioenergy_demand.csv", overwrite = TRUE)

        
        cfg$title <- paste0("be_", be, "_", cfg$gms$s60_biodem_scaler, "EJ", "_tc_", mode, "_beshare_", 100 * cfg$gms$s30_kbe_rotation_max_shr, "_capfx")
        # cfg$title <- paste0("be_", be, "_", cfg$gms$s60_biodem_scaler, "EJ", "_tc_", mode, "_beshare_", 100 * cfg$gms$s30_kbe_rotation_max_shr)

        start_run(cfg,codeCheck=FALSE)
      }

    }
  }

}

