*** |  (C) 2008-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  MAgPIE License Exception, version 1.0 (see LICENSE file).
*** |  Contact: magpie@pik-potsdam.de

*' @description In this realization, urban land expands based on population growth.
*' Carbon stocks are assumed zero.

*' @limitations Only for illustrative purpose

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/34_urban/pop_growth/declarations.gms"
$Ifi "%phase%" == "equations" $include "./modules/34_urban/pop_growth/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/34_urban/pop_growth/preloop.gms"
$Ifi "%phase%" == "presolve" $include "./modules/34_urban/pop_growth/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/34_urban/pop_growth/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
