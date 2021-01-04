## Predicting courier speed by route parameters

**Main question**: is it possible to predict how fast the courier will reach
to the place of delivery, taking into account the route, weather conditions, distance traveled?

**Conditions**: the courier travels only on foot

**Sub-questions**:  

1. how to clear the data from the courier speed parameter where he did not go, but was driving?
2. how to find out the weather condition from GPS data at the time of the route?
3. how to train the model to predict speed based on weather conditions?
4. what data to prepare for model training?
5. what model to choose for forecasting?

Project **plan**: 

* answer the questions
* define the variables for the model
* to get data
* data cleaning (remove from the track the moment where the courier travels, but does not go)
* data analysis
* model writing
* model training
* interpretation of results
* model results
* description of the results obtained
* uploading the model to the site

## Action plan

Week 52, 2020:  

- draw up a project plan - see below;
- create a local project folder on your computer;
- put all raw data in the local folder;
- read the `GPX` files of hikes in the Python dataframe;
- write a short report for the week and make a work plan for the next.

## Performed: Week 52, 2020:
1. a plan for the 52nd week of the project was drawn up;
2. created a local folder on the computer;
3. the raw data was put into the local folder;
4. read `GPX` files of hikes in Python dataframe;
5. the received data is saved in csv format and put
to the walking_tracks_csv folder;
6. the values in the "speed" column have been converted from min / km to km / h;
7. built on the basis of new plot data;
8. only those data in the speed column are selected, the speed of which
does not exceed 7,281 km / h;
9. the selected data plotted and obtained average speed of the courier's walking.

				
