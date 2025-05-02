*** |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*' @equations
*' The sum of costs for land expansion and land reduction 
*' is multiplied with an annuity factor to distribute these costs over time.

q39_cost_landcon_crop(j2) .. vm_cost_landcon(j2,"crop") =e=
  (vm_landexpansion(j2,"crop")*sum((ct,cell(i2,j2)), i39_cost_establish(ct,i2,"crop") + vm_rd_stock_per_area(i2,"crop"))
  - vm_landreduction(j2,"crop")*sum((ct,cell(i2,j2)), i39_reward_reduction(ct,i2,"crop")))
  * sum((cell(i2,j2),ct),pm_interest(ct,i2)/(1+pm_interest(ct,i2)));

q39_cost_landcon(j2,land_nocrop39) .. vm_cost_landcon(j2,land_nocrop39) =e=
  (vm_landexpansion(j2,land_nocrop39)*sum((ct,cell(i2,j2)), i39_cost_establish(ct,i2,land_nocrop39))
  - vm_landreduction(j2,land_nocrop39)*sum((ct,cell(i2,j2)), i39_reward_reduction(ct,i2,land_nocrop39)))
  * sum((cell(i2,j2),ct),pm_interest(ct,i2)/(1+pm_interest(ct,i2)));
