library(tidyverse)
library(readr)
library(ggplot2) #needed to make plots 
library("cowplot") #needed to make plot with multiple graphs
library(gridExtra) #needed to make table summarizing viabilities at the end

#upload data: 
Drugs_data <- read_csv("BES539_multiple_drug_screen.csv")

#First we must subtract the background reading (A750) from the A490 reading to ensure we are only observing the reading from the MTT assay. 
#To do this, we manipulate the graph to be able to group the pairs of A750 and A490 together. This is done by first moving the concentration columns together, and then taking the readings and pairing them with their appropriate absorbency and triplicate. Once this is done, we can subtract.  
Drug_absorbances <- Drugs_data %>% 
  pivot_longer("10":"No_Drug_Control",
               names_to = "concentration", values_to = "reading") %>%
  pivot_wider(names_from = "Wavelength", values_from = "reading") %>%
  group_by(Drug, Triplicate, concentration) %>%
  summarise(Absorbance = A490-A750)

#After correcting for background readings, we group the trials by their drug and concentration so that we can average each triplicate. 
Drug_mean <- Drug_absorbances %>%
  group_by(Drug, concentration) %>%
  summarise(Mean_absorbance = mean(Absorbance))

#the relative viability is calculated by dividing the mean absorbency of each trial by the mean absorbency of the control. 
#To do this, we manipulate the data to take the no drug control out of the concentration column and back into its own. This way, we can divide each absorbency by the control. 
Drug_viability <- Drug_mean %>%
  pivot_wider(names_from = "concentration", values_from = "Mean_absorbance") %>%
  pivot_longer("0.01":"10",
               names_to = "concentration", values_to = "Mean_absorbance") %>%
  group_by(Drug, concentration) %>%
  summarise(Relative_Viability=  Mean_absorbance/No_Drug_Control)

#To convert the concentrations (10,1,0.1,0.01) to a log scale, we make a viability table of only one drug (which you choose does not matter). By doing so, we guarantee that we only convert the 4 values into log scale once. 
#By doing so, we are able to make a list of the concentrations as numeric values. Because they started as column headers, R reads them as characters rather than numbers and will not let us convert them into logs before first making them into a numeric list. 
Drug1_viability <- Drug_viability %>%
  filter(Drug=="Lapatinib")

Drug_viability_log <- as.numeric(Drug1_viability$concentration) 

#The purpose of the drug_for_graph table is to convert the concentrations into a log scale using the numeric list we created above. 
Drug_for_graph <- Drug_viability %>%
  group_by(Drug) %>%
  mutate(log_concentration = log10(Drug_viability_log))

#Now that our data is ready for graphing, we can make a combined graph of all our drugs across different concentrations.  
#First, we make labels for the colors on the graph so that the graph is easier to read
Drug_combo_labels <- Drug_for_graph %>%
  filter(log_concentration == "0") %>%
  arrange(desc(Relative_Viability)) %>%
  pull(Drug)

#Now we can plot the combined data. By setting a limit of (0,1.2), we guarantee that we observe all viability levels. We want the graph to show viabilities on a scale from 0% to 120% (1.2) so that we can see how they compare to the control. A value below 1.0 means that viability as decreased.   
ggplot(Drug_for_graph, aes(x=log_concentration, y=Relative_Viability, color=Drug)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2)) +
  scale_color_discrete(breaks = Drug_combo_labels, labels = Drug_combo_labels)

#If further analysis is necessary for individual drugs, we filter the data for any drugs of interest on their own. 
Drug1_for_graph <- Drug_for_graph %>%
  filter(Drug=="Lapatinib")
Drug2_for_graph <- Drug_for_graph %>%
  filter(Drug=="GSK")
Drug3_for_graph <- Drug_for_graph %>%
  filter(Drug=="BMS")
Drug4_for_graph <- Drug_for_graph %>%
  filter(Drug=="L+G")
Drug5_for_graph <- Drug_for_graph %>%
  filter(Drug=="L+G+B")

#Once filtered, we can make individual graphs for any drugs we'd like. 
#We will assign them a name so that we can compile them into a plot grid to show multiple graphs on one figure. 
Lapatinib <- ggplot(Drug1_for_graph, aes(x=log_concentration, y=Relative_Viability)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration Lapatinib (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2))

GSK <- ggplot(Drug2_for_graph, aes(x=log_concentration, y=Relative_Viability)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration GSK (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2))

BMS <- ggplot(Drug3_for_graph, aes(x=log_concentration, y=Relative_Viability)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration BMS (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2))

LG <- ggplot(Drug4_for_graph, aes(x=log_concentration, y=Relative_Viability)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration L+G (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2))

LGB <- ggplot(Drug5_for_graph, aes(x=log_concentration, y=Relative_Viability)) +
  geom_point(stat='summary', fun=sum) +
  stat_summary(fun=sum, geom="line") +
  labs(x = "Log Concentration L+G+B (uM)" , y = "Relative Viability") + 
  theme_bw() +
  scale_y_continuous(limits= c(0,1.2), breaks=c(0,0.2,0.4,0.6,0.8,1.0,1.2))

#Once the individual plots are made, we can put them all into a figure side-by-side
plot_grid(Lapatinib,GSK,BMS,LG,LGB, 
          labels = c("A", "B", "C", "D", "E"),
          ncol = 3, nrow = 2)

#To supplement the graphs, we also make a table summarizing the relative viabilities that we've calculated. 
#To do so, we first pivot our data into a wide format for easier reading. Then, we order the viabilties into descending order to make any trends more clear. Lastly, we rename the concentration columns to include their units.  
Drug_Viability_wide <- Drug_viability %>%
  pivot_wider(names_from="concentration", values_from="Relative_Viability")

Drug_Viability_Wide_Ordered <- Drug_Viability_wide[order(desc(Drug_Viability_wide$"1")), ] %>%
  rename("0.01 uM"="0.01","0.1 uM"="0.1","1 uM"="1","10 uM"="10")

grid.table(Drug_Viability_Wide_Ordered)

