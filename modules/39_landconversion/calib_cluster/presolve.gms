*** |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

* Global costs for cropland/pasture expansion and rewards for cropland/pasture reduction are scaled with one shared
* calibration factor per cluster (i39_calib / i39_calib_past).
* The calibration factor has been derived with the goal of matching cropland/pasture per cluster in 2015 with historic data.
* Scaling cost and reward by the same factor keeps clusters without need for change (factor = 1) in economic equilibrium,
* where expansion cost and reduction reward are balanced by the underlying global constants.

i39_cost_establish(j,"crop") = s39_cost_establish_crop * i39_calib(j);
i39_reward_reduction(j,"crop") = s39_reward_crop_reduction * i39_calib(j);
i39_cost_establish(j,"past") = s39_cost_establish_past * i39_calib_past(j);
i39_reward_reduction(j,"past") = s39_reward_past_reduction * i39_calib_past(j);
i39_cost_establish(j,"forestry") = s39_cost_establish_forestry;
i39_cost_establish(j,"urban") = s39_cost_establish_urban;
