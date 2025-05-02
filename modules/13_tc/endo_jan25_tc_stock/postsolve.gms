*** |  (C) 2008-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

* Overall TC cost for the current timestep

if((ord(t)>1),
 pc13_tcguess(h,tautype) = (vm_tau.l(h,tautype)/pcm_tau(h, tautype))**(1/m_yeardiff(t)) - 1;
);

pcm_tau(h, tautype) = vm_tau.l(h, tautype);

p13_rd_stock(t_all, i2, "crop") =  p13_rd_stock(t_all, i2, "crop")  +
                                   v13_rd_investment.l(i2, "crop")
                                   * f13_bell_curve(t, t_all) * m_yeardiff(t);


*#################### R SECTION START (OUTPUT DEFINITIONS) #####################
 ov_tau(t,h,tautype,"marginal")               = vm_tau.m(h,tautype);
 ov_tech_cost(t,i,"marginal")                 = vm_tech_cost.m(i);
 ov13_rd_stock(t,i,tautype,"marginal")        = v13_rd_stock.m(i,tautype);
 ov_rd_stock_per_area(t,i,tautype,"marginal") = vm_rd_stock_per_area.m(i,tautype);
 ov13_rd_investment(t,i,tautype,"marginal")   = v13_rd_investment.m(i,tautype);
 ov13_tech_cost(t,i,tautype,"marginal")       = v13_tech_cost.m(i,tautype);
 oq13_tech_cost(t,i,tautype,"marginal")       = q13_tech_cost.m(i,tautype);
 oq13_rd_stock_crop(t,i,"marginal")           = q13_rd_stock_crop.m(i);
 oq13_tech_cost_sum(t,i,"marginal")           = q13_tech_cost_sum.m(i);
 oq13_rd_investment_crop(t,i,"marginal")      = q13_rd_investment_crop.m(i);
 ov_tau(t,h,tautype,"level")                  = vm_tau.l(h,tautype);
 ov_tech_cost(t,i,"level")                    = vm_tech_cost.l(i);
 ov13_rd_stock(t,i,tautype,"level")           = v13_rd_stock.l(i,tautype);
 ov_rd_stock_per_area(t,i,tautype,"level")    = vm_rd_stock_per_area.l(i,tautype);
 ov13_rd_investment(t,i,tautype,"level")      = v13_rd_investment.l(i,tautype);
 ov13_tech_cost(t,i,tautype,"level")          = v13_tech_cost.l(i,tautype);
 oq13_tech_cost(t,i,tautype,"level")          = q13_tech_cost.l(i,tautype);
 oq13_rd_stock_crop(t,i,"level")              = q13_rd_stock_crop.l(i);
 oq13_tech_cost_sum(t,i,"level")              = q13_tech_cost_sum.l(i);
 oq13_rd_investment_crop(t,i,"level")         = q13_rd_investment_crop.l(i);
 ov_tau(t,h,tautype,"upper")                  = vm_tau.up(h,tautype);
 ov_tech_cost(t,i,"upper")                    = vm_tech_cost.up(i);
 ov13_rd_stock(t,i,tautype,"upper")           = v13_rd_stock.up(i,tautype);
 ov_rd_stock_per_area(t,i,tautype,"upper")    = vm_rd_stock_per_area.up(i,tautype);
 ov13_rd_investment(t,i,tautype,"upper")      = v13_rd_investment.up(i,tautype);
 ov13_tech_cost(t,i,tautype,"upper")          = v13_tech_cost.up(i,tautype);
 oq13_tech_cost(t,i,tautype,"upper")          = q13_tech_cost.up(i,tautype);
 oq13_rd_stock_crop(t,i,"upper")              = q13_rd_stock_crop.up(i);
 oq13_tech_cost_sum(t,i,"upper")              = q13_tech_cost_sum.up(i);
 oq13_rd_investment_crop(t,i,"upper")         = q13_rd_investment_crop.up(i);
 ov_tau(t,h,tautype,"lower")                  = vm_tau.lo(h,tautype);
 ov_tech_cost(t,i,"lower")                    = vm_tech_cost.lo(i);
 ov13_rd_stock(t,i,tautype,"lower")           = v13_rd_stock.lo(i,tautype);
 ov_rd_stock_per_area(t,i,tautype,"lower")    = vm_rd_stock_per_area.lo(i,tautype);
 ov13_rd_investment(t,i,tautype,"lower")      = v13_rd_investment.lo(i,tautype);
 ov13_tech_cost(t,i,tautype,"lower")          = v13_tech_cost.lo(i,tautype);
 oq13_tech_cost(t,i,tautype,"lower")          = q13_tech_cost.lo(i,tautype);
 oq13_rd_stock_crop(t,i,"lower")              = q13_rd_stock_crop.lo(i);
 oq13_tech_cost_sum(t,i,"lower")              = q13_tech_cost_sum.lo(i);
 oq13_rd_investment_crop(t,i,"lower")         = q13_rd_investment_crop.lo(i);
*##################### R SECTION END (OUTPUT DEFINITIONS) ######################
