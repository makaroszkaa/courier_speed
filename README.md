## Project name: Predicting courier speed by route parameters

**The main question: is it possible to predict how fast the courier will reach?
to the place of delivery, taking into account the route, weather conditions, distance traveled.**

**Conditions: the courier walks only on foot**

**Sub-questions:**

- [x] How to clear the data from the courier speed parameter where he did not go, but was driving?  
- [x] How to find out the weather condition from GPS data at the time of the route?  
-     How to train the model to predict speed based on weather conditions?  
-     What data to prepare for model training?  
-     Which model to choose for forecasting?  
 
Project **plan:**

- [x] define the variables for the model  
- [x] get data  
- [x] data cleansing (remove from the track the moment where the courier travels, but does not go)  
-     data analysis  
-     model writing  
-     model training  
-     interpretation of results  
-     model results  
-     description of the results obtained  
-     uploading the model to the site  
  
### Sub-question 1: split walking from using transport

Walking person max speed is **7.82** kph according to [institutions]. This
project considers any speed above mentioned value some kind of transporting:
driving a car, some kind of public transport etc.

### Sub-question 2: is it possible to obtain weather conditions?



## Desired features to build a model

1. height difference (H1-H2);  
2. outside temperature;  
3. travelled distance;  

Determining the distance for each route (id) using the Haversin formula;  

## Active plan 3 week:

- [x] determine the variables for the model;  
-     form the variables required for the model from the available data;  
-     get the required variables;  
-     write a short report for the week and make a work plan for the next.  


