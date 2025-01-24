# Car-sharing-OD-matrices

This folder gathers the models and data used in he paper "Anis S., Sacco N. (2024). "Enhancing public transport accessibility: Exploring hybrid car sharing systems for improved connectivity". In particualr, there are:
- the CPLEX code implementing the model in , Transportation Engineering, 16, art. no. 100255",
- the ExtendSim models for the probability estimation
- the OD matrices for a CS service in the city of Trento (realistic). These matrices have been derived based on the Point of Interest and can be considered realistic. 


ExtendSim (.mox) files:
These model has been used to estimate the request rejection probabilities for the One-Way and Two-Way car-sharing schemes.

Excel files description:
1. demand attraction.xlsx (this file explains the total mobility demand generated from each zone of Trento under two time periods of weekdays and weekend days, to be used in the Extend SIM probability calculation model for estimating the probability of CS vehicle availability upon request by its users.   
2. demand generation.xlsx (this sheet estimates the attracted demand for each zone of Trento based on the normalization of no. of POIs under two time periods of weekdays and weekend days, to be used in the Extend SIM probability calculation model for estimating the probability of CS vehicle availability upon request by its users
3. resultsOW.xlsx - this files show the value of probability under given number of vehicles if the CS system is operating under OW scheme
4. resultsTW.xlsx - this files show the value of probability under given number of vehicles if the CS system is operating under TW scheme

These code and data have been prepared by the authors of the paper and are free to use. 
If you you this material, please cite the above paper according to the .bib file.




