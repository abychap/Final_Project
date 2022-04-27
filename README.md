# Calculating Relative Viability from Absorbance Readings

This project was created in order to calculate relative viability from absorbance readings. The raw readings are the result of drug treatments on triple negative breast cancer cell lines. A low absorbance compared to the controls represents a decrease in viability over the course of 24 hours after drug treatment. To access the viability of cells, we treat cell lines with four different concentrations of each drug of interest. Each concentration is performed in triplicate. This code can then be used to convert the raw absorbance readings into the relative viability of the cells at the various concentrations. Before being ready for analysis, the absorbances must first be fixed by subtracting any background readings (A490-A750). These new absorbances are then averaged for each triplicate. The relative viability is then calculated by dividing the absorbance of each test by the absorbance of the controls. Lastly, the concentrations used are converted to a log scale to make graphs easier to analyze. This code includes a table summarizing the relative viability of cells under each drug condition, a combined graph comparing all drugs tested to each other, as well as individual graphs of each drug for its own analysis if necessary. 

# To get started
In order to get started with this project, users should set up a table with the following columns: Drug, Wavelength, Triplicate, 10, 1, 0.1, 0.01, No_Drug_Control

**Drug**: name of the drug of interest
**Wavelength**: the wavelengths that absorbances were taken at (there should be one included to subtract any bakground: A490-A750)
**Triplicate**: each wavelength for each drug should have three readings (1,2,3)
**10,1,0.1,0.01**: names represent the concentrations (in uM) that absorbances were taken at. Absorbance readings should go in these columns 
**No_Drug_Control**: absorbance readings from control wells should go in this column
