# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# ------------------------------------------------
# description: try to solve the scaled model with ipopt
# ------------------------------------------------

# Load start_run(cfg) function which is needed to start MAgPIE runs
source("scripts/start_functions.R")

#start MAgPIE run
source("config/default.cfg")
cfg$title <- "ipopt_muinit_1e-5_tol_1e-9_relaxbounds_1e-7"
cfg$gms$optimization <- "nlp_ipopt"
cfg$gms$s80_toloptimal <- 1.0e-9
# cfg$gms$c_timesteps <- 5
start_run(cfg, codeCheck = FALSE)
