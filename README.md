## Project name: Predicting courier speed by route parameters

**The main question: is it possible to predict how fast the courier will reach?
to the place of delivery, taking into account the route, weather conditions, distance traveled.**

**Conditions: the courier walks only on foot**

**Sub-questions:**

1.How to clear the data from the courier speed parameter where he did not go, but was driving?
[] done, the maximum speed of the person is taken
2. How to find out the weather condition from GPS data at the time of the route?
[] done, we took weather data and added date and time using a key
3.How to train the model to predict speed based on weather conditions?
4. what data to prepare for model training?
5. Which model to choose for forecasting?

Project **plan:**

* answer the questions
* define the variables for the model
* get data - done
* data cleansing (remove from the track the moment where the courier travels, but does not go) - done
* data analysis
* model writing
* model training
* interpretation of results
* model results
* description of the results obtained
* uploading the model to the site

## Active plan 3 week:

1.determine the factorial variables for the model; [] done
2. form the variables required for the model from the available data;
3. get the required variables;
4. write a short report for the week and make a work plan for the next.

Performed:
[] factorial variables for the model are defined

## Factor variables needed to build a model:
1.height difference (H1-H2)
2.temperature
3.determining the distance for each route (id) using the Haversin formula
