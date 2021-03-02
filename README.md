## Predict courier speed from travelled distance

### Executive summary

The main question: is it possible to predict how fast the courier will reach
the place of delivery, taking into account the route, weather conditions,
distance traveled. The project assumes that the courier always walks on foot.

Sub-questions:

- [x] How to split walking from driving / using transport?   
- [x] Is it possible to find out weather conditions from GPS track?  
- [x] How to train the model to predict speed based on weather conditions?  

Project plan:

1. define ideal dataset;  
2. collect data from GPS;  
3. collect weather data;  
4. make tidy dataset;  
5. make linear model;
6. test model performance;
___

### Ideal dataset

Courier walks on the street covering certain distances and meeting any kind of
obstacles on a way. Thinking of an obstacle one could have imagined going up
and down the stairs. Naturally we expect that walking upstairs is slower than
downstairs. It is possible to define upstairs and downstairs by using altitude
data gathered by GPS. So the **first feature** is the **altitude difference**.

Another idea is that the speed depends on outside temperature. Most likely the
courier gets tired faster if the temperature is higher. Tired courier walks
slower. Thus, another features is **temperature**.

There should also be direct connection from travelled distance to the speed.
Walking long distances in high tempo is most likely not possible for a courier.
The third feature is **travelled distance**.
___

### Data collection

We collect the data from GPX tracks registered by couriers. They registered the
tracks using `osmand` software. Each GPX track contains latitude, longitude,
altitude and speed. We convert GPX tracks to data frame for each trip and then
bind all trips into one bigger data frame.

The code for raw data collection and transformation is in [this script].
___

#### Sub-question 1: split walking from using transport

Walking person max speed is **7.82** kph according to [Wikipedia]. This
project considers any speed above mentioned value some kind of transporting:
driving a car, some kind of public transport etc.
___

#### Sub-question 2: is it possible to obtain weather conditions?

It is possible to collect the weather historical data from this [source]. The
site provides the data in `csv` format. We have to tweak the file a bit to be
able to merge it into route files. The key to merge two data frames is the
*timestamp*.

After we have merged two data frames, there is an opportunity to add more
columns with features, which we have not thought of before:

- split date and time;  
- make new indices for rows;  
- rename columns;  
- convert speed to *kph*;  

The link to the script is [here] in lines *61 -- 151*.
___

### Exploratory data analysis

To prepare data for building a regression model, you need detect and process
outliers. This is done so that the model is as accurate as possible, otherwise
outliers can adversely affect accuracy models.

When studying factorial variables, the columns `dele` and `speed` potentially
outliers arising from incorrect data can be detected. Finding them will be
supported by mathematical methods and visualization.

Open the finished file from the first part. The file is located at the [link].
Identify emissions with the help of **Identifying Outliers with Interquartile 
Range (IQR)** (interquartile range). This method is represented by the formula 
`IQR = Q3 - Q1`. The interquartile range shows how the data is distributed
relative to the median. It is less susceptible to outliers than the range, and 
therefore may be more useful.

We upload the obtained *IQR* results, which will be used to detect
outliers. The value in the columns `True` indicates the presence of an outlier.

Another method of detecting outliers is **identification with asymmetry**.
Ideally, the skewness value should be in the range from `-1 to +1`, and
any significant deviation from this range indicates the presence
of extreme values. For the `speed` column, the coefficient value is **-1.5**,
which means clearly indicates the presence of outliers. We will also output the
statistics with the `describe` function:

```python
# output statistics for the speed column
courier_data['speed'].describe()
```


<br\>
<br\>

[Wikipedia]: https://en.wikipedia.org/wiki/Walking
[source]: https://rp5.ru/%D0%9F%D0%BE%D0%B3%D0%BE%D0%B4%D0%B0_%D0%B2_%D0%BC%D0%B8%D1%80%D0%B5
[this script]: https://github.com/makaroszkaa/courier_speed/blob/main/raw_data_transform.py
[here]: https://github.com/makaroszkaa/courier_speed/blob/main/raw_data_transform.py
[link]: https://github.com/makaroszkaa/courier_speed/blob/main/linear_regression_model.py
