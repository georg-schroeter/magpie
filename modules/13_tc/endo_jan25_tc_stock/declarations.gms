*** |  (C) 2008-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

positive variable
 vm_tau(h,tautype)                   Agricultural land use intensity tau (1)
 vm_tech_cost(i)                     Total Annuitized costs of TC (mio. USD17MER per yr)
 v13_rd_stock(i,tautype)             R&D stock to drive TC for crops and pasture in curent time step (mio. USD17MER per yr)
 v13_rd_investment(i, tautype)      R&D investment to drive TC for crops and pasture in curent time step (mio. USD17MER per yr)
 v13_tech_cost(i, tautype)           Annuitized costs of TC (mio. USD17MER per yr)
;

equations
 q13_tech_cost(i, tautype)            Total annuitized costs for TC (mio. USD17MER)
 q13_rd_stock_crop(i)                 R&D stock to drive TC for crops in curent time step (mio. USD17MER per yr)
 q13_tech_cost_sum(i)                 Total Total annuitized costs for TC (mio. USD17MER per yr)
 q13_rd_investment_crop(i)            R&D investment to drive TC for crops in curent time step (mio. USD17MER per yr)
;

parameters
 pcm_tau(h, tautype)                  Tau factor of the previous time step (1)
 pc13_land(i, tautype)                Crop land area per region (mio ha)
 p13_rd_stock(t_all, i, tautype)             R&D stock to drive TC for crops and pasture of the previous time step (USD17MER)
 pc13_tcguess(h, tautype)             Guess for annual tc rates in the next time step (1)
 i13_tc_exponent(t)                   Regression exponent (1)
 i13_tc_factor(t)                     Regression factor of R&D capital (USD17MER per ha)
;

scalars
  s13_yeardiff                       Number of 5-year time intervalls between time steps (1)
;
*#################### R SECTION START (OUTPUT DECLARATIONS) ####################
parameters
 ov_tau(t,h,tautype,type)             Agricultural land use intensity tau (1)
 ov_tech_cost(t,i,type)               Total Annuitized costs of TC (mio. USD17MER per yr)
 ov13_rd_stock(t,i,tautype,type)      R&D stock to drive TC for crops and pasture in curent time step (mio. USD17MER per yr)
 ov13_rd_investment(t,i,tautype,type) R&D investment to drive TC for crops and pasture in curent time step (mio. USD17MER per yr)
 ov13_tech_cost(t,i,tautype,type)     Annuitized costs of TC (mio. USD17MER per yr)
 oq13_tech_cost(t,i,tautype,type)     Total annuitized costs for TC (mio. USD17MER)
 oq13_rd_stock_crop(t,i,type)         R&D stock to drive TC for crops in curent time step (mio. USD17MER per yr)
 oq13_tech_cost_sum(t,i,type)         Total Total annuitized costs for TC (mio. USD17MER per yr)
 oq13_rd_investment_crop(t,i,type)    R&D investment to drive TC for crops in curent time step (mio. USD17MER per yr)
;
*##################### R SECTION END (OUTPUT DECLARATIONS) #####################
