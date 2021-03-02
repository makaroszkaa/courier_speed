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

***

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

#### Sub-question 1: split walking from using transport

Walking person max speed is **7.82** kph according to [Wikipedia]. This
project considers any speed above mentioned value some kind of transporting:
driving a car, some kind of public transport etc.

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

### Preparing data for building a linear regression model

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
For a visual representation, we will identify outliers using visualization. The
first graph is a **Box Plot**, which is often used to identify the distribution of 
data and detect outliers. The graph shows the presence of a large number of 
points, which indicates the presence of outliers. The second graph is a **histogram**.
The outlier is observed outside the overall distribution pattern.

After the outliers have been found and presented graphically, they need to be
*processed*. We will do this using the **Quantile-based Flooring and method
Capping**. After applying this method, the skewness value
improved significantly **-1.14**. Apply all the same for the `dele` column.
___

### Exploratory data analysis

After processing the emissions, we will perform an exploratory analysis -- **exploratory 
data analysis**, in which you will find a `correlation` between the variables.

Use the **Heat Maps**, the graph shows that the speed mostly depends on 
from the distance traveled,(**-0,94** coefficient indicates a strong correlation 
between speed and distance, the greater the courier passed away, the less 
the speed and Vice versa), the graph shows that the change in elevation on the speed and 
the temperature on the velocity of impact is very weak. 

**Plotting a scatter plot**
It shows the relationship between the speed of the courier and
the distance traveled. Another pair plot graph shows a similar relationship.
___

### Building a regression model

We load all the necessary libraries:

```python
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error
import statsmodels.api as sm
from statsmodels.tools.eval_measures import mse, rmse
import warnings
import math
import scipy.stats as stats
import scipy
from sklearn.preprocessing import scale
warnings.filterwarnings('ignore')
from tkinter import font
import matplotlib.font_manager as font_manager
```
We determine which values in the columns will be dependent and independent 
variables. The dependent variable is `speed`, and the predictors are *distance*, 
*temperature*, *longitude*, *latitude*, *altitude change*, and *time*. Next, we divide the
data set into training and testing data. This means that **20%** of the test data will
be randomly selected and separated from the training data.

Now we can build a model. 

- After building the model, the question arises, how correctly interpret the result?

First of all, you should pay attention to the column with the name `p-value`. 
P-value shows the statistical significance of the model. It is important that the
p-value coefficient is less than *0.05*, since the lower the p-value, the 
better the result. In the table, the *temperature* predictor is greater than *0.05*
and does not depend on the `speed`, so we discard it.

In the model, `R squared is 90%` of the variance, which is really a lot.
Now let's build another model, but without a statistically significant result
`trip_tc`. We can see that now all the predictors are statistically significant
and R squared is still good. 

Let's build a diagram of the model. The actual and predicted estimates have almost perfect linearity.

So, to sum up, the best model will have:

- p-value<0.05
- smaller errors
- higher adjusted R squared.
___

### Errors

The last step is to inspect the **errors**. The errors are also minor. 
The values of the small error metric indicate good predictive ability,
while the large values indicate the opposite. 
If you want to know what MSE, RMSE or MAPE is, you can read [this] article.


[Wikipedia]: https://en.wikipedia.org/wiki/Walking
[source]: https://rp5.ru/%D0%9F%D0%BE%D0%B3%D0%BE%D0%B4%D0%B0_%D0%B2_%D0%BC%D0%B8%D1%80%D0%B5
[this script]: https://github.com/makaroszkaa/courier_speed/blob/main/raw_data_transform.py
[here]: https://github.com/makaroszkaa/courier_speed/blob/main/raw_data_transform.py
[link]: https://github.com/makaroszkaa/courier_speed/blob/main/linear_regression_model.py
[this]: https://www.dataquest.io/blog/understanding-regression-error-metrics/