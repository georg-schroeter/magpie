# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# --------------------------------------------------------
# description: calculate first step of landconversion cost calibration for all csv files in land_conversion_sensitivity/input.
# --------------------------------------------------------
require("stringr")


if (file.exists("modules/39_landconversion/input/f39_calib.bak")) file.remove("modules/39_landconversion/input/f39_calib.bak")
if (file.exists("modules/39_landconversion/input/f39_calib.csv")) file.rename("modules/39_landconversion/input/f39_calib.csv", "modules/39_landconversion/input/f39_calib.bak")

files <- list.files(path="land_conversion_sensitivity/input_longterm", pattern="*.csv", full.names=TRUE, recursive=FALSE)
for (file in files) {
  if (file.exists("modules/39_landconversion/input/f39_calib.csv")) file.remove("modules/39_landconversion/input/f39_calib.csv")
  file.copy(file, "modules/39_landconversion/input/f39_calib.csv")

  # Load start_run(cfg) function which is needed to start MAgPIE runs
  source("scripts/start_functions.R")

  #start MAgPIE run
  # source("config/default.cfg")

  source("config/default.cfg")
  
  cfg$title <- str_replace(paste0("calib_sens", str_extract(file, "_[^/]*$")), ".csv", "")
  
  cfg$results_folder <- start_run(cfg=cfg)
  
  file.copy(file, paste0(cfg$results_folder, "/"))
  
}

if (file.exists("modules/39_landconversion/input/f39_calib.csv")) file.remove("modules/39_landconversion/input/f39_calib.csv")
if (file.exists("modules/39_landconversion/input/f39_calib.bak")) file.rename("modules/39_landconversion/input/f39_calib.bak", "modules/39_landconversion/input/f39_calib.csv")