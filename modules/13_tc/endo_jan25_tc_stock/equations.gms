*** |  (C) 2008-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*' @equations
q13_rd_stock_crop(i2)..
v13_rd_stock(i2, "crop") =e= sum(ct, pc13_land(i2, "crop") * i13_tc_factor(ct) *
                             sum(supreg(h2,i2), vm_tau(h2,"crop"))**i13_tc_exponent(ct));



q13_rd_investment_crop(i2)..
v13_rd_stock(i2, "crop") =e= sum(ct, p13_rd_stock(ct, i2, "crop")) +
                                    v13_rd_investment(i2, "crop") * s13_yeardiff * sum(ct, f13_bell_curve(ct, ct));


q13_tech_cost(i2, tautype) ..
v13_tech_cost(i2, tautype) =e= v13_rd_investment(i2, tautype)  * (1 + sum(ct, pm_interest(ct, i2)))**5 * sum(ct, f13_bell_curve(ct, ct)) /
        sum((ct,t_all), f13_bell_curve(ct, t_all) * f13_interest_panel(ct, t_all) * 5);

q13_tech_cost_sum(i2) ..
 vm_tech_cost(i2) =e= sum(tautype, v13_tech_cost(i2, tautype));
