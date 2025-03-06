data <- read.csv("input/test000_reference.csv", sep=",", comment.char="*", dec=".")

for (region in list("CAZ", "CHA", "EUR", "IND", "JPN", "LAM", "MEA", "NEU", "OAS", "REF", "SSA", "USA", "all")) {
cat(region, " ")
  # generate reference file
  data[[3]] <- 1
  data[[4]] <- 0
  file_name <- paste0("input/test002_reference.csv")
  write.csv(data,file_name,row.names=FALSE, fileEncoding = "UTF-8")
  
  
  # for (factor in list (0.5,0.625,0.8,1.25,1.6,2.0)) {
  for (factor in list (0.1,0.2,0.4,0.7,1.0)) {
    data[[3]] <- 1
    data[[4]] <- 0
    
    if (region == "all") {
      matches <- (data[[3]] > 0)
    } else {
      matches <- (data[[2]] == region)
    }
    
    # data[[3]][matches] <- factor
    data[[4]][matches] <- factor
    file_name <- paste0("input/test002_", region, "_", factor, ".csv")
    write.csv(data,file_name,row.names=FALSE, fileEncoding = "UTF-8")
  }
}
cat("\n")
