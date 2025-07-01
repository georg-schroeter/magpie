*** |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*#################### R SECTION START (OUTPUT DEFINITIONS) #####################
 ov_cost_landcon(t,j,land,"marginal")            = vm_cost_landcon.m(j,land);
 oq39_cost_landcon_crop(t,j,"marginal")          = q39_cost_landcon_crop.m(j);
 oq39_cost_landcon(t,j,land_nocrop39,"marginal") = q39_cost_landcon.m(j,land_nocrop39);
 ov_cost_landcon(t,j,land,"level")               = vm_cost_landcon.l(j,land);
 oq39_cost_landcon_crop(t,j,"level")             = q39_cost_landcon_crop.l(j);
 oq39_cost_landcon(t,j,land_nocrop39,"level")    = q39_cost_landcon.l(j,land_nocrop39);
 ov_cost_landcon(t,j,land,"upper")               = vm_cost_landcon.up(j,land);
 oq39_cost_landcon_crop(t,j,"upper")             = q39_cost_landcon_crop.up(j);
 oq39_cost_landcon(t,j,land_nocrop39,"upper")    = q39_cost_landcon.up(j,land_nocrop39);
 ov_cost_landcon(t,j,land,"lower")               = vm_cost_landcon.lo(j,land);
 oq39_cost_landcon_crop(t,j,"lower")             = q39_cost_landcon_crop.lo(j);
 oq39_cost_landcon(t,j,land_nocrop39,"lower")    = q39_cost_landcon.lo(j,land_nocrop39);
*##################### R SECTION END (OUTPUT DEFINITIONS) ######################
