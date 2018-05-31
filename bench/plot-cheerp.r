#!/usr/bin/env Rscript

# Usage:
#
#     plot.r data.csv
#
# Output will be placed in SVG files.

library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(args[1], header = TRUE, sep = ",")

jitterBoxPlot <- function(data, operation, titleText) {
    print(paste(operation, "---------------------------------------------------------------------------"))

    operationData <- subset(data, data$Operation == operation)

    operationData$Implementation <- factor(
        operationData$Implementation,
        levels = c(
            "Cheerp",
            "Rust"
        )
    )
    operationData$Browser <- factor(
        operationData$Browser,
        levels = c(
            "Firefox",
            "Chrome"
        )
    )

    chromeCheerp <- subset(operationData,
                       operationData$Implementation == "Cheerp" & operationData$Browser == "Chrome")$Time
    print(paste("mean: scala.js: Chrome+Cheerp =", mean(chromeCheerp)))
    print(paste("sd: scala.js: Chrome+Cheerp =", sd(chromeCheerp)))
    print(paste("cv: scala.js: Chrome+Cheerp =", sd(chromeCheerp) / mean(chromeCheerp)))

    chromeRust <- subset(operationData,
                       operationData$Implementation == "Rust" & operationData$Browser == "Chrome")$Time
    print(paste("mean: scala.js: Chrome+Rust =", mean(chromeRust)))
    print(paste("sd: scala.js: Chrome+Rust =", sd(chromeRust)))
    print(paste("cv: scala.js: Chrome+Rust =", sd(chromeRust) / mean(chromeRust)))

    firefoxCheerp <- subset(operationData,
                       operationData$Implementation == "Cheerp" & operationData$Browser == "Firefox")$Time
    print(paste("mean: scala.js: Firefox+Cheerp =", mean(firefoxCheerp)))
    print(paste("sd: scala.js: Firefox+Cheerp =", sd(firefoxCheerp)))
    print(paste("cv: scala.js: Firefox+Cheerp =", sd(firefoxCheerp) / mean(firefoxCheerp)))

    firefoxRust <- subset(operationData,
                       operationData$Implementation == "Rust" & operationData$Browser == "Firefox")$Time
    print(paste("mean: scala.js: Firefox+Rust =", mean(firefoxRust)))
    print(paste("sd: scala.js: Firefox+Rust =", sd(firefoxRust)))
    print(paste("cv: scala.js: Firefox+Rust =", sd(firefoxRust) / mean(firefoxRust)))

    print(paste("normalized mean: Chrome =", mean(chromeCheerp) / mean(chromeRust)))
    print(paste("normalized sd: Chrome =", sd(chromeCheerp) / sd(chromeRust)))
    print(paste("normalized mean: Firefox =", mean(firefoxCheerp) / mean(firefoxRust)))
    print(paste("normalized sd: Firefox =", sd(firefoxCheerp) / sd(firefoxRust)))

    thePlot <- ggplot(operationData,
                      aes(x = paste(operationData$Implementation, operationData$Browser,sep="."),
                          y = operationData$Time,
                          color = operationData$Implementation,
                          pch = operationData$Browser)) +
        geom_boxplot(outlier.shape = NA) +
        geom_jitter(position = position_jitter(width = 0.1)) +
        scale_y_continuous(limits = quantile(operationData$Time, c(NA, 0.99))) +
        expand_limits(y = 0) +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 45, hjust = 1),
              axis.title.x = element_blank()) +
        ggtitle(titleText) +
        labs(y = "Time (ms)",
             subtitle = "Scala.Cheerp Source Map (Mappings String Size = 14,964,446)")

    print(thePlot)
    svgFile <- paste(operation, ".scalajs.svg", sep="")
    ggsave(plot = thePlot,
           file = svgFile,
           device = "svg")
}

largeData <- subset(data, Mappings.Size==14964446)

jitterBoxPlot(largeData, "set.first.breakpoint", "Set First Breakpoint")
jitterBoxPlot(largeData, "subsequent.setting.breakpoints", "Subsquent Setting Breakpoints")

jitterBoxPlot(largeData, "first.pause.at.exception", "First Pause at Exception")
jitterBoxPlot(largeData, "subsequent.pausing.at.exceptions", "Subsequent Pausing at Exceptions")

jitterBoxPlot(largeData, "parse.and.iterate", "Parse and Iterate Each Mapping")
jitterBoxPlot(largeData, "iterate.already.parsed", "Already Parsed, Iterate Each Mapping")

meanPlot <- function(data, operation, titleText) {
    operationData <- subset(data, data$Operation == operation)

    operationData$Implementation <- factor(
        operationData$Implementation,
        levels = c(
            "Cheerp",
            "Rust"
        )
    )
    operationData$Browser <- factor(
        operationData$Browser,
        levels = c(
            "Firefox",
            "Chrome"
        )
    )

    thePlot <- ggplot(operationData,
                      aes(x = operationData$Mappings.Size,
                          y = operationData$Time,
                          color = operationData$Implementation,
                          pch = operationData$Browser)) +
        stat_summary(fun.y = mean, geom = "line") +
        stat_summary(fun.y = mean, geom = "point") +
        #geom_point() +
        theme(legend.position = "bottom",
              legend.direction="vertical",
              legend.title = element_blank()) +
        scale_y_continuous(limits = quantile(operationData$Time, c(NA, 0.99))) +
        ## scale_x_log10() +
        ## scale_y_log10() +
        expand_limits(y = 0) +
        ggtitle(titleText) +
        labs(x = "Mappings String Size",
             y = "Time (ms)",
             subtitle = "Mean")

    ## print(thePlot)
    svgFile <- paste(operation, ".mean.svg", sep="")
    ggsave(plot = thePlot,
           file = svgFile,
           device = "svg")
}

meanPlot(data, "set.first.breakpoint", "Set First Breakpoint")
meanPlot(data, "subsequent.setting.breakpoints", "Subsequent Setting Breakpoints")
meanPlot(data, "first.pause.at.exception", "First Pause at Exception")
meanPlot(data, "subsequent.pausing.at.exceptions", "Subsequent Pausing at Exceptions")
meanPlot(data, "parse.and.iterate", "Parse and Iterate Each Mapping")
meanPlot(data, "iterate.already.parsed", "Already Parsed, Iterate Each Mapping")
