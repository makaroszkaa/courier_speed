# open the file
courier_data = pd.read_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/courier_data.csv')
courier_data

# identifying Outliers with Interquartile Range (IQR)
# the lines of code below calculate and print the interquartile range for each 
# of the variables in the dataset
Q1 = courier_data.quantile(0.25)
Q3 = courier_data.quantile(0.75)
IQR = Q3 - Q1
print(IQR)

# the above output prints the IQR scores, which can be used to detect outliers
# the code below generates an output with the 'True' and 'False' values
# points where the values are 'True' represent the presence of the outlier
((courier_data < (Q1 - 1.5 * IQR)) | (courier_data > (Q3 + 1.5 * IQR)))

# the skewness value, should be in the range [-1,1]
print(courier_data['speed'].skew())

# output statistics for the speed column
courier_data['speed'].describe()

# identifying outliers using visualization
plt.boxplot(courier_data['speed'])  
plt.show() 
courier_data.speed.hist()

# quantile-based Flooring and Capping
print(courier_data['speed'].quantile(0.10))
print(courier_data['speed'].quantile(0.90))
courier_data['speed'] = np.where(courier_data['speed'] <3.7, 3.7,courier_data['speed'])
courier_data['speed'] = np.where(courier_data['speed'] >5.3, 5.3,courier_data['speed'])
print(courier_data['speed'].skew()) 

# after applying this method, we can see that the value of the asymmetry has improved
# significantly
courier_data['speed'].describe()

# applying all the same for the 'dele'column
print(courier_data['dele'].skew())
courier_data['dele'].describe()
plt.boxplot(courier_data['dele']) 
plt.show() 
courier_data.speed.hist()

# quantile-based Flooring and Capping
print(courier_data['dele'].quantile(0.10))
print(courier_data['dele'].quantile(0.90))
courier_data['dele'] = np.where(courier_data['dele'] <-1.57, -1.57,courier_data['speed'])
courier_data['dele'] = np.where(courier_data['dele'] >1.6, 1.6,courier_data['speed'])
print(courier_data['dele'].skew()) 

# after applying this method, we can see that the value of the asymmetry has improved
# significantly
courier_data['dele'].describe()

# exploratory data analysis
courier_data.dtypes

# heat Maps
plt.figure(figsize=(20,10))
c= courier_data.corr()
sns.heatmap(c,cmap='BrBG',annot=True)
c

# plotting a scatter plot
from io import StringIO
_ = sns.lmplot(x='speed', y='acc_dist', data=courier_data, ci=None, line_kws={'color': 'red'})
plt.show()

# pair plot
sns.pairplot(data = courier_data, vars=['speed','acc_dist'])
plt.show()

# building a linear regression model
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

# define X and Y
Y=courier_data["speed"]
X=courier_data[[ 'acc_dist', 'dele', 'trip_tc', 'trip_hr', 'lat', 'lon']]

# we divide the data set into training and test data, from which we select 20%
# of the data at random and separate them from the training data
X_train, X_test, y_train, y_test = train_test_split(X, Y, test_size = 0.2, random_state = 465)
print('Training Data Count: {}'.format(X_train.shape[0]))
print('Testing Data Count: {}'.format(X_test.shape[0]))

# now, let’s build the model(comments on the model will be given in the article):
X_train = sm.add_constant(X_train)
results = sm.OLS(y_train, X_train).fit()
results.summary()

# let's build the second model without the temperature predictor
X2=courier_data[['acc_dist', 'dele', 'trip_hr', 'lat', 'lon']]
X2_train, X2_test, y2_train, y2_test = train_test_split(X2, Y, test_size = 0.2, random_state = 465)

print('Training Data Count:', X2_train.shape[0])
print('Testing Data Count::', X2_test.shape[0])

X2_train = sm.add_constant(X2_train)

results2 = sm.OLS(y2_train, X2_train).fit()
results2.summary()

# R squared is still good and I have no variable having p-value higher than 0.05
# let’s look at the model chart here:
X2_test = sm.add_constant(X2_test)
y2_preds = results2.predict(X2_test)

plt.figure(dpi = 75)
plt.scatter(y2_test, y2_preds)
plt.plot(y2_test, y2_test, color="red")
plt.xlabel("Actual speed")
plt.ylabel("Pred. speed")
plt.title("Model: Actual speed vs pred. speed  ")
plt.show()

# actual scores and predicted scores have almost perfect linearity

# finally,  will check the errors
print("Mean Absolute Error (MAE)         : {}".format(mean_absolute_error(y2_test, y2_preds)))
print("Mean Squared Error (MSE) : {}".format(mse(y2_test, y2_preds)))
print("Root Mean Squared Error (RMSE) : {}".format(rmse(y2_test, y2_preds)))
print("Root Mean Squared Error (RMSE) : {}".format(rmse(y2_test, y2_preds)))
print("Mean Absolute Perc. Error (MAPE) : {}".format(np.mean(np.abs((y2_test - y2_preds) / y2_test)) * 100))