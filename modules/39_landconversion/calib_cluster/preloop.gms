*** |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

i39_cost_establish(j,land) = 0;
i39_reward_reduction(j,land) = 0;

i39_calib(j,type39) = f39_calib_cluster(j,type39);
* set default values in case of missing input file or s39_ignore_calib = 1
if(sum((j,type39),i39_calib(j,type39)) = 0 OR s39_ignore_calib = 1,
  i39_calib(j,"cost") = 1;
  i39_calib(j,"reward") = 0;
);

i39_calib_past(j,type39) = f39_calib_cluster_past(j,type39);
* set default values in case of missing input file or s39_ignore_calib_past = 1
if(sum((j,type39),i39_calib_past(j,type39)) = 0 OR s39_ignore_calib_past = 1,
  i39_calib_past(j,"cost") = 1;
  i39_calib_past(j,"reward") = 0;
);
