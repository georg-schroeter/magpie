# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

# *********************************************************************
# ***    This script calculates per-cluster calibration factors       ***
# ***   (one shared factor for expansion cost and reduction reward,   ***
# ***    without time axis) based on a pre run of magpie              ***
# *********************************************************************

# Wrapper function that executes code with comprehensive logging
# Captures cat(), messages, warnings, and errors
withLogging <- function(expr, logfile, putfolder) {
  # create putfolder for the calib run
  cat(paste0("Deleting putfolder: ", putfolder, "\n"))
  unlink(putfolder, recursive = TRUE)
  cat(paste0("Creating putfolder: ", putfolder, "\n"))
  dir.create(putfolder)
  # Open file connection for logging
  logfileConn <- file(paste0(putfolder, "/", logfile), open = "a")

  # Redirect both stdout and stderr to the same log file
  sink(logfileConn)
  sink(logfileConn, type = "message")

  tryCatch(
    {
      cat("=== COMPREHENSIVE LOGGING ACTIVE (cat/messages/warnings/errors) ===\n")
      force(expr)  # Execute the expression
    },
    error = function(e) {
      timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      cat(paste0("[", timestamp, "] ERROR: ", conditionMessage(e), "\n"))
      # Error already logged, now close sinks and connection
      try(sink(type = "message"), silent = TRUE)
      try(sink(), silent = TRUE)
      try(close(logfileConn), silent = TRUE)
      stop(e)  # Re-throw the error after logging
    },
    finally = {
      cat("=== LOGGING SESSION COMPLETE ===\n")
      # Close sinks and connection safely even if an error occurred
      try(sink(type = "message"), silent = TRUE)
      try(sink(), silent = TRUE)
      try(close(logfileConn), silent = TRUE)
    }
  )
}

calibrationRun <- function(putfolder, calibMagpieName, logoption, useGDX) {
  require(lucode2)
  require(magpie4)

  cat("=== CALIBRATION_RUN START ===\n")
  cat(paste0("Putfolder: ", putfolder, ", useGDX: ", useGDX, "\n"))

  # create a modified magpie.gms for the calibration run
  unlink(paste(calibMagpieName, ".gms", sep = ""))
  unlink("fulldata.gdx")

  if (!file.copy("main.gms", paste(calibMagpieName, ".gms", sep = ""), overwrite = TRUE)) {
    stop(paste("Unable to create", paste(calibMagpieName, ".gms", sep = "")))
  }
  lucode2::manipulateConfig(paste(calibMagpieName, ".gms", sep = ""), c_timesteps = "calib")
  lucode2::manipulateConfig(paste(calibMagpieName, ".gms", sep = ""), useGDX = useGDX)
  file.copy(paste(calibMagpieName, ".gms", sep = ""), putfolder, overwrite = TRUE)

  # execute calibration run
  cat("Starting GAMS run...\n")
  system(paste("gams ", calibMagpieName, ".gms", " -errmsg=1 -PUTDIR ./", putfolder, " -LOGOPTION=", logoption, sep = ""), wait = TRUE)
  cat("GAMS run completed\n")
  file.copy("fulldata.gdx", putfolder)

  cat("=== CALIBRATION_RUN END ===\n")
}

# FAO validation.mif variable name (Resources|Land Cover|+|<...>) for each calibrated land type
faoLandCoverName <- c(crop = "Cropland", past = "Pastures and Rangelands")

getValData <- function(histData, gdxFile, landType = "crop") {
  require(magpie4)
  require(magclass)
  require(gdx2)
  cat(paste0("=== retrieve validation data (landType = ", landType, ") ===\n"))
  y <- readGDX(gdxFile,"t")
  magpie <- land(gdxFile, level = "cell")[, y, landType]
  if (histData == "MAgPIEown") {
    hist <- readGDX(gdxFile, "f10_land")[, , landType]
    valdata <- hist[, y, landType]
  } else if (histData == "FAO") {
    rdsFile <- paste0("calib_data_", landType, ".rds")
    if(file.exists(rdsFile)) {
      val <- readRDS(rdsFile)
    } else {
      val <- read.report("input/validation.mif", as.list = FALSE)
      faoVar <- paste0("historical.FAO_crop_past.Resources|Land Cover|+|", faoLandCoverName[[landType]], " (million ha)")
      val <- val[getCells(magpie),getYears(magpie),faoVar]
      names(dimnames(val)) <- names(dimnames(magpie))
      getNames(val) <- landType
      saveRDS(val, file = rdsFile)
    }
    valdata <- val[,y,]
  } else {
    stop("unkown histData")
  }
  if (nregions(magpie) != nregions(valdata) || !all(getCells(magpie) %in% getCells(valdata))) {
    stop("Regions in MAgPIE do not agree with regions in reference calibration area data set!")
  }
  cat("=== validation data retrieved ===\n")
  return(valdata)
}

expandHist <- function(valdata){
  require(magclass)
  # test whether land has expanded or contracted in validation data
  expandHist <- valdata
  for (i in 2:length(getYears(valdata))) {
    expandHist[ , i, ] <- setYears(valdata[, i, ], NULL) - setYears(valdata[, i-1, ], NULL)
  }
  return(expandHist)
}

# get ratio between modelled area and reference area

getCalibFactor <- function(gdxFile, mode, histData, landType = "crop") {

  require(magclass)
  cat("=== GET_CALIB_FACTOR START ===\n")
  cat(paste0("GDX file: ", gdxFile, "\n"))
  cat(paste0("Mode: ", mode, ", histData: ", histData, ", landType: ", landType, "\n"))

  valdata <- getValData(histData = histData, gdxFile = gdxFile, landType = landType)
  magpie <- land(gdxFile, level = "cell")[, getYears(valdata), landType]

  if (mode == "gradient") {
    cat(">>> gradient calibration \n")
    # Calibration should not target absolute difference to goal, but matching the increase over time.
    # Otherwise, calibration of first timestep will implicitly also calibrate all further timesteps.
    expansionValdata <- valdata * 0
    expansionMagpie <- valdata * 0
    for (timestep in 2:length(getYears(expansionMagpie))) {
      expansionMagpie[,timestep,] <- magpie[,timestep,] / setYears(magpie[,timestep - 1,], NULL)
      expansionValdata[,timestep,] <- valdata[,timestep,] / setYears(valdata[,timestep - 1,], NULL)
    }
    # if magpie expands more than valdata, out should be smaller than 1
    out <- expansionMagpie - expansionValdata + 1
  } else {
    cat(">>> timestep calibration \n")
    out <- magpie / valdata
  }
  # clusters with no reference land (or no reference land in the previous timestep) have no
  # calibration signal: magpie/valdata -> 0/0 and the gradient ratios -> NaN/Inf. Set those
  # factors to neutral 1 so they neither diverge nor crash the convergence check.
  out[!is.finite(out)] <- 1
  getNames(out) <- NULL
  out[out <= 0.1] <- 0.1 # make sure the multiplier doesnt drop to 0, as this could not be reverted in future iterations. 
  # expert guess: 10% of the original land conversion cost estimates seems a reasonable lower limit, as land expansion should also not be free of costs.

  return(magpiesort(out))
}

# The cluster calibration file has no time axis (module 39 reads a static factor
# per cluster: table f39_calib_cluster(j,type39)). Collapse per-year calibration
# factors to that single static factor by taking the y2015 value, which is the
# factor that produced the calibrated 2015 land area in the last run. Values stay
# within [costMin, costMax] as enforced in updateCalib(); no
# additional >= 1 floor is applied.
collapseToStatic <- function(calibFactor) {
  require(magclass)
  return(setYears(calibFactor[, "y2015", ], NULL))
}

# Write/read the static cluster calibration file as a plain csv
# ("dummy,factor" header + one "cluster,factor" row per cluster, e.g. "CAZ_1,1.2"),
# i.e. exactly the layout module 39's table f39_calib_cluster(j,type39) expects.
# write.magpie/read.magpie are deliberately not used for these files: magclass'
# csv writer prints the spatial column as substring(dimname, 1, 3) (its legacy
# region-code convention), which would collapse all clusters of one region
# (CAZ_1*CAZ_5 -> "CAZ"), and its csv reader misinterprets the label x name
# layout of this file format.
writeClusterCalib <- function(calibFull, calibFile, comment = NULL) {
  require(magclass)
  # magclass/GDX cell labels use a dot (CAZ.1) but the GAMS set j uses an underscore
  # (CAZ_1); write the GAMS spelling so module 39's table f39_calib_cluster(j,type39)
  # can read the included file without domain violations. readClusterCalib maps back.
  cellNames <- gsub(".", "_", getCells(calibFull), fixed = TRUE)
  values <- matrix(NA_real_, nrow = length(cellNames), ncol = ndata(calibFull))
  for (k in seq_len(ndata(calibFull))) values[, k] <- round(as.numeric(calibFull[, , k]), 3)
  con <- file(calibFile, open = "w")
  on.exit(close(con))
  if (!is.null(comment)) writeLines(paste("*", comment), con)
  writeLines(paste("dummy", paste(getNames(calibFull), collapse = ","), sep = ","), con)
  utils::write.table(cbind(cellNames, values), file = con, sep = ",",
                     row.names = FALSE, col.names = FALSE, quote = FALSE)
}

readClusterCalib <- function(calibFile) {
  require(magclass)
  data <- utils::read.csv(calibFile, header = TRUE, check.names = FALSE, comment.char = "*")
  # restore the magclass/GDX dot spelling (CAZ_1 -> CAZ.1) from the GAMS label written by
  # writeClusterCalib, so cells match those read from the GDX (e.g. getCalibFactor's output).
  cells <- gsub("_", ".", as.character(data[[1]]), fixed = TRUE)
  out <- new.magpie(cells_and_regions = cells, years = NULL,
                    names = names(data)[-1], fill = NA)
  out[, , ] <- as.matrix(data[, -1, drop = FALSE])
  return(out)
}

# Write/append one iteration of a cells x years magpie as a long csv with columns
# cell,year,iter1,iter2,... and read it back as a cells x years x iterations magpie.
# These replace magclass' cs3 logging (write.magpie append + read.magpie), which
# does not round-trip cellular (per-cluster) data of any label style reliably in
# magclass 7: appending fails with mbind dimension errors and reading back merges
# cells into the data dimension.
writeLogCsv <- function(x, file, calibrationStep) {
  require(magclass)
  cellNames <- getCells(x)
  yearNames <- getYears(x)
  values <- matrix(as.numeric(x), nrow = length(cellNames), ncol = length(yearNames))
  df <- data.frame(cell = rep(cellNames, times = length(yearNames)),
                   year = rep(yearNames, each = length(cellNames)),
                   value = as.vector(values),
                   stringsAsFactors = FALSE)
  if (file.exists(file)) {
    old <- utils::read.csv(file, check.names = FALSE)
    old[[paste0("iter", calibrationStep)]] <-
      df$value[match(paste(old$cell, old$year), paste(df$cell, df$year))]
    utils::write.table(old, file, sep = ",", row.names = FALSE, quote = 2)
  } else {
    names(df)[names(df) == "value"] <- paste0("iter", calibrationStep)
    utils::write.table(df, file, sep = ",", row.names = FALSE, quote = 2)
  }
}

readLogCsv <- function(file) {
  require(magclass)
  data <- utils::read.csv(file, check.names = FALSE)
  iterations <- grep("^iter[0-9]+$", names(data), value = TRUE)
  cellNames <- unique(as.character(data$cell))
  yearNames <- unique(as.character(data$year))
  out <- new.magpie(cells_and_regions = cellNames, years = yearNames, names = iterations, fill = NA)
  key <- paste(rep(cellNames, times = length(yearNames)), rep(yearNames, each = length(cellNames)))
  for (it in iterations) {
    out[, , it] <- matrix(data[[it]][match(key, paste(data$cell, data$year))],
                          nrow = length(cellNames), ncol = length(yearNames))
  }
  return(out)
}

# Write a "neutral" pasture calibration file: shared calibration factor = 1 for every
# cluster, as a static file without time axis (matching table f39_calib_past_cluster(j,type39)).
# This reproduces the legacy behavior for the given
# land type -- its conversion costs and reduction rewards are governed purely by the flat
# global constants (s39_cost_establish_past / s39_reward_past_reduction), with no calibration at all.
# Used when a land type's calibration is switched off (see calibratePasture in
# calibrateLandconversion()) so the input file module 39 reads still exists and is
# well-formed, it just has no effect.
writeNeutralCalib <- function(calibFile, cells, landType) {
  require(magclass)
  neutralFull <- new.magpie(cells, years = NULL, names = "factor", fill = 1)

  comment <- c(
    paste0(" description: Cluster land conversion calibration file with one shared cost/reward factor (landType = ", landType, ")"),
    " unit: -",
    " note: NEUTRAL/legacy file -- calibration for this land type is switched off",
    " (cfg$calib_pasture_landconversion_cost <- FALSE). factor = 1 for every",
    " cluster, reproducing the pre-calibration behavior where this land type's",
    " conversion cost and reduction reward are governed only by the flat global constants.",
    " origin: scripts/calibration/landconversion_cost_cluster.R (path relative to model main directory)",
    paste0(" creation date: ", date())
  )
  writeClusterCalib(neutralFull, calibFile, comment = comment)
  cat(paste0(">>> Wrote neutral (legacy) calibration file for landType = ", landType, ": ", calibFile, "\n"))
}

# TRUE if calibFile doesn't exist or is exactly the neutral file writeNeutralCalib()
# would produce (cost == 1 and reward == 0 everywhere). Used so that flipping
# calibratePasture to FALSE always results in a neutral file -- an existing file left over
# from a previous run with pasture calibration switched on is never silently reused,
# while a missing calibration file will be treated as neutral calibration by MAgPIE.
isNeutralCalib <- function(calibFile) {
  require(magclass)
  if (!file.exists(calibFile)) return(TRUE)
  x <- tryCatch(readClusterCalib(calibFile), error = function(e) NULL)
  if (is.null(x) || !("factor" %in% getNames(x))) return(FALSE)
  isTRUE(all(x[, , "factor"] == 1))
}

# Calculate the correction factor and save it
updateCalib <- function(gdxFile, calibAccuracy, calibFile, costMax, costMin, calibrationStep, nMaxcalib, bestCalib, histData, putfolder, levelGradientMix, landType = "crop") {
  require(magclass)
  require(magpie4)
  require(gdx2)

  cat(paste0("=== UPDATE_CALIB ITERATION ", calibrationStep, " (landType = ", landType, ") START ===\n"))
  cat(paste0("GDX file: ", gdxFile, "\n"))
  cat(paste0("calibAccuracy: ", calibAccuracy, "\n"))

  if (!(modelstat(gdxFile)[1, 1, 1] %in% c(1, 2, 7))) {
    stop("Calibration run infeasible")
  }



  # we calculate two different divergence measures: divergence of level (land area) and divergence of gradient (land expansion)
  calibDivergenceLevel <- getCalibFactor(gdxFile, mode = "level", histData = histData, landType = landType)
  calibDivergenceGradient <- getCalibFactor(gdxFile, mode = "gradient", histData = histData, landType = landType)
  # mixing calibration approaches for making the best of both approaches
  calibDivergence <- levelGradientMix * calibDivergenceLevel + (1 - levelGradientMix) * calibDivergenceGradient
  
  # we calculate the correction factor based on a mix of the two divergence measures
  # gradient should lead to faster convergence and more continuous gradient with historical data
  # gradient has disadvantage that the error from incomplete convergence accumulates over time
  # level calibration has advantage that errors from one timestep are balanced out in subsequent timestep.
 
  calib_correction <- calibDivergence
  # dont modify calibration in first timestep, as otherwise its like a second yield calibration
  calib_correction[,1,] <- 1
 
  ### -> in case it is the first step, it forces the initial factors to be equal to 1
  if (file.exists(calibFile)) {
    cat(">>> Starting with existing calibration file\n")
    # the cluster calibration file is static (no time axis) -> replicate its factors
    # over all calibration years before updating them
    staticCalib <- readClusterCalib(calibFile)
    oldCalib <- new.magpie(cells_and_regions = getCells(staticCalib), years = getYears(calibDivergence), names = getNames(staticCalib))
    oldCalib[, getYears(calibDivergence), ] <- staticCalib
  } else {
    cat(">>> First iteration - initializing calibration factors (1 for expanding clusters, costMax for contracting)\n")
    oldCalib <- new.magpie(cells_and_regions = getCells(calibDivergence), years = getYears(calibDivergence), names = "factor", fill = NA)
    oldCalib[,,"factor"] <- (expandHist(getValData(histData = histData, gdxFile = gdxFile, landType = landType)) < 0) * (costMax - 1) + 1
  }

  ### use first steps to calibrate stronger, such that calibration factors can also achieve low/high levels
  if(calibrationStep <= 8) {
    reinforcement <- 10
  } else if (calibrationStep <= 11) {
    reinforcement <- 5 
  } else {
    reinforcement <- 1
  } 
  
  cat(">>> Calib factors are adjusted where needed\n")
  # one shared factor per cluster multiplies both expansion cost and reduction reward:
  # clusters with no need for change converge to factor = 1, i.e. the economic equilibrium
  # defined by the global cost and reward constants.
  calibFactor <- setNames(oldCalib[, , "factor"], NULL) * calib_correction ^ reinforcement

  cat(">>> Account for costMax and costMin\n")
  if (!is.null(costMax)) {
    aboveLimit <- (calibFactor >= costMax)
    calibFactor[aboveLimit] <- costMax
  }

  if (!is.null(costMin)) {
    belowLimit <- (calibFactor <= costMin)
    calibFactor[belowLimit] <- costMin
  }

  cat(">>> write down current calib factors (and area_factors) for tracking\n")
  writeLog <- function(x, file, calibrationStep) {
    try(writeLogCsv(round(x, 3), file, calibrationStep))
  }

  writeLog(calibDivergenceLevel, paste0(putfolder, "/land_conversion_divergence_level_", landType, ".csv"), calibrationStep)
  writeLog(calibDivergenceGradient, paste0(putfolder,  "/land_conversion_divergence_gradient_", landType, ".csv"), calibrationStep)
  writeLog(calibDivergence, paste0(putfolder,  "/land_conversion_divergence_", landType, ".csv"), calibrationStep)
  writeLog(calibFactor, paste0(putfolder,  "/land_conversion_next_calib_factor_", landType, ".csv"), calibrationStep)
  writeLog(setNames(oldCalib[, , "factor"], NULL), paste0(putfolder,  "/land_conversion_current_calib_factor_", landType, ".csv"), calibrationStep)

  # in case of sufficient convergence, stop here (no additional update of calibration factors!)
  # also stop in case there is no convergence, e.g. because the calib factors are at upper or lower bounds.
  convergenceReached <- abs(calibDivergence - 1) <= calibAccuracy
  noConvergence <- (calibFactor == setNames(oldCalib[, , "factor"], NULL))

  if (all(convergenceReached | noConvergence) || calibrationStep == nMaxcalib) {

    ### Depending on the selected calibration selection type (bestCalib FALSE or TRUE)
    # the reported and used regional calibration factors can be either the ones of the last iteration,
    # or the "best" based on the iteration value with the lowest standard deviation of regional divergence.
    if (bestCalib == TRUE) {
      cat("Choosing the best calibration...\n")
      divergenceData <- readLogCsv(paste0(putfolder, "/land_conversion_divergence_", landType, ".csv"))
      factors <- readLogCsv( paste0(putfolder, "/land_conversion_current_calib_factor_", landType, ".csv"))
      # The best iteration is chosen for each cluster as the calibration factor where the sum of divergence over all timesteps is minimal.
      # In case multiple iterations have the same value, the first value is returned by which.min
      calibBest <- factors[,,1] * 0
      for(i in getCells(divergenceData)) {
        # use sum(log(divergenceData+1) as divergenceData is (magpie/data-1), and relative divergence should be equally punished in both directions
        bestIteration <- which.min(dimSums(abs(log(divergenceData[i, , ])), dim = 2))
        bestName      <- getNames(divergenceData)[bestIteration]
        calibBest[i, , ] <- factors[i, , bestName]
      }
      getNames(calibBest) <- NULL
 
      # tag with the iteration at which "best" was determined (rather than a fixed "best" literal), since this
      # branch may run again on a later iteration while a concurrently-calibrated land type has not yet converged
      writeLog(calibBest, paste0(putfolder, "/land_conversion_best_calib_factor_", landType, ".csv"), calibrationStep)
   
      calibBestFull <- add_dimension(collapseToStatic(calibBest), dim = 3.1, nm = "factor")
      calibBestFull[is.na(calibBestFull)] <- 1

      comment <- c(
        paste0(" description: Cluster land conversion calibration file with one shared cost/reward factor (landType = ", landType, ")"),
        " unit: -",
        paste0(" note: Best calibration factor from the run"),
        " origin: scripts/calibration/landconversion_cost_cluster.R (path relative to model main directory)",
        paste(" Calibration settings:",  "calibAccuracy=", calibAccuracy, "costMax=", costMax, "costMin=", costMin, "nMaxcalib=",nMaxcalib, "bestCalib=",bestCalib, "histData=",histData),
        paste0(" creation date: ", date())
      )
      writeClusterCalib(calibBestFull, calibFile, comment = comment)


      ####
      return(TRUE)
    } else {
      return(TRUE)
    }
  } else {
    cat("Adjust calibration factors for next iteration \n")
    calibFull <- add_dimension(collapseToStatic(calibFactor), dim = 3.1, nm = "factor")
    calibFull[is.na(calibFull)] <- 1

    comment <- c(
      paste0(" description: Cluster land conversion calibration file with one shared cost/reward factor (landType = ", landType, ")"),
      " unit: -",
      paste0(" note: Calibration step ", calibrationStep),
      " origin: scripts/calibration/landconversion_cost_cluster.R (path relative to model main directory)",
      paste(" Calibration settings:",  "calibAccuracy=", calibAccuracy, "costMax=", costMax, "costMin=", costMin, "nMaxcalib=", nMaxcalib, "bestCalib=", bestCalib, "histData=", histData),
      paste0(" creation date: ", date())
    )

    writeClusterCalib(calibFull, calibFile, comment = comment)
    return(FALSE)
  }
}




calibrateLandconversion <- function(nMaxcalib = 20,
                             restart = FALSE,
                             calibAccuracy = 0.01,
                             costMax = 10.0,
                             costMin = 0.1,
                             calibMagpieName = "magpie_calib",
                             calibFile = "modules/39_landconversion/input/f39_calib_cluster.csv",
                             calibFilePast = "modules/39_landconversion/input/f39_calib_past_cluster.csv",
                             calibAccuracyPast = calibAccuracy,
                             costMaxPast = costMax,
                             costMinPast = costMin,
                             putfolder = "land_conversion_cost_calib_run",
                             dataWorkspace = NULL,
                             logoption = 3,
                             debug = FALSE,
                             bestCalib = TRUE,
                             histData = "FAO",
                             levelGradientMix = 0.3,
                             calibratePasture = TRUE) {
  require(magclass)

  if (!restart) {
    cat(paste0("\nStarting land conversion cost calibration from default values\n"))
    if (file.exists(calibFile)) file.remove(calibFile)
    if (file.exists(calibFilePast)) file.remove(calibFilePast)
  } else {
    cropExists <- file.exists(calibFile)
    pastExists <- file.exists(calibFilePast)
    if (cropExists && pastExists) {
      cat(paste0("\nStarting land conversion cost calibration from existing values (crop and pasture)\n"))
    } else if (cropExists || pastExists) {
      cat(paste0("\nStarting land conversion cost calibration from a MIXED state: ",
                 if (cropExists) "crop restarts from its existing calibration file, pasture starts from default values"
                 else "pasture restarts from its existing calibration file, crop starts from default values",
                 "\n"))
    } else {
      cat(paste0("\nStarting land conversion cost calibration from default values\n"))
    }
  }

  # Clear log file at start
  if (file.exists("calibration_debug.log")) file.remove("calibration_debug.log")
  # Wrap entire calibration process with comprehensive logging
  withLogging({
    cat("##################################################################\n")
    cat("### CALIBRATE_MAGPIE START ###\n")
    cat("##################################################################\n")

    useGDX <- 0
    for (i in seq_len(nMaxcalib)) {
      
      cat(paste0("### ITERATION ", i, " START (useGDX = ", useGDX, ") ###\n"))

      calibrationRun(putfolder = putfolder, calibMagpieName = calibMagpieName, logoption = logoption, useGDX = useGDX)

      if (debug) {
        # Copy listing file with iteration number for debugging
        if (file.exists(paste0(calibMagpieName, ".lst"))) {
          file.copy(paste0(calibMagpieName, ".lst"), paste0(putfolder, "/", calibMagpieName, "_iter", i, ".lst"), overwrite = TRUE)
        }
        file.copy(paste0(putfolder, "/fulldata.gdx"), paste0(putfolder, "/", "fulldata_calib", i, ".gdx"), overwrite = TRUE)
      }

      # crop and pasture are calibrated concurrently from the same solve: crop and pasture compete for
      # land, so calibrating them sequentially (crop first, then pasture) would shift the land allocation
      # before pasture is calibrated, causing oscillation between iterations.
      doneCrop <- updateCalib(gdxFile = "fulldata.gdx", calibAccuracy = calibAccuracy, costMax = costMax, costMin = costMin,
                           calibFile = calibFile, calibrationStep = i, nMaxcalib = nMaxcalib, bestCalib = bestCalib, histData = histData,
                           putfolder = putfolder, levelGradientMix = levelGradientMix, landType = "crop")

      if (calibratePasture) {
        donePast <- updateCalib(gdxFile = "fulldata.gdx", calibAccuracy = calibAccuracyPast, costMax = costMaxPast, costMin = costMinPast,
                             calibFile = calibFilePast, calibrationStep = i, nMaxcalib = nMaxcalib, bestCalib = bestCalib, histData = histData,
                             putfolder = putfolder, levelGradientMix = levelGradientMix, landType = "past")
      } else {
        # pasture calibration switched off: write the legacy/neutral file once (skipped on
        # later iterations once it's confirmed neutral) instead of running updateCalib() for
        # "past" at all, and treat pasture as immediately "done" so the loop's termination
        # depends only on crop's own convergence.
        if (!isNeutralCalib(calibFilePast)) {
          require(magpie4)
          pastureCells <- getCells(land("fulldata.gdx", level = "cell"))
          writeNeutralCalib(calibFilePast, pastureCells, landType = "past")
        }
        donePast <- TRUE
      }

      done <- doneCrop && donePast

      if (done && useGDX == 2) {
        useGDX <- 0
        next
      } else if (done && useGDX == 0) {
        break
      } else {
        useGDX <- 2
      }
    }

    # delete calib_magpie_gms in the main folder
    unlink(paste0(calibMagpieName, ".*"))
    unlink("fulldata.gdx")
    unlink("calib_data_crop.rds")
    unlink("calib_data_past.rds")

    cat("\nLand conversion cost calibration finished\n")
  }, logfile = "calibration_debug.log", putfolder = putfolder)
}
