data <- read.csv("f13_bell_curve.cs3", sep=",", comment.char="*", dec=".", row.names=1)

years <- rownames(data)
# print(data)

for (i in years) {
#    print(data[i])
    for (j in years) {
        if (i <= j) data[i,j] <- 1
        else data[i,j] <- 0
        
    }
#    print(i)
}


write.csv(data,"f13_bell_curve_inf.cs3",row.names=TRUE, fileEncoding = "UTF-8")

cat("\n")
