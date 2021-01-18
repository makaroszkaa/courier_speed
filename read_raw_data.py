#!/usr/bin/env python
# coding: utf-8

#loading libraries
import pandas as pd
from pandas import Series, DataFrame
import numpy as np
import gpxpy
import gpxpy.gpx
import os
from os.path import isfile
from os.path import join as joinpath
from os import listdir
import matplotlib.pyplot as plt
import datetime as dt

# Check if file exists
exists = os.path.isfile('C:/Users/hrypo/Documents/visual_project/walking_tracks/2020-12-20_12-49_Sun.gpx')

# Create an empty DataFrame and navigate to the desired folder. 
# Next, for each track inside gpx.tracks, create an empty dataframe and get the variables we need inside point 
# (give them a name). 
# Next, attach all frames to temp_dataframe. 
# This is necessary in order to combine all dataframes into one. Finally, let's index the resulting DataFrame.
directory = 'C:/Users/hrypo/Documents/visual_project/walking_tracks' 
list_file = os.listdir(directory) 
gpx_data = pd.DataFrame() 
for filename in list_file: 
    if filename.endswith(".gpx"):
        path_to_file = directory + '/' + filename 
        gpx_file = open(path_to_file) 
        gpx = gpxpy.parse(gpx_file) 
        temp_dataframe = pd.DataFrame()
        for track in gpx.tracks: 
            temp_dataframe0 = pd.DataFrame()
            for segment in track.segments: 
                temp_dataframe1 = pd.DataFrame()
                for point in segment.points: 
                    lat   = point.latitude 
                    lon   = point.longitude
                    ele   = point.elevation
                    time  = point.time
                    speed = point.extensions[0].text
                    data = {'lat':[point.latitude] , 
                            'lon':[point.longitude],
                            'ele':[point.elevation],
                            'time':[point.time],
                            'speed':[point.extensions[0].text] }
                    frame = DataFrame(data)
                    temp_dataframe1 = temp_dataframe1.append(frame) 
                temp_dataframe0 = temp_dataframe0.append(temp_dataframe1)
            temp_dataframe = temp_dataframe.append(temp_dataframe0)
        temp_dataframe.index = np.arange(1, len(temp_dataframe) + 1) 
        temp_dataframe['id'] = filename 
        gpx_data = gpx_data.append(temp_dataframe) 
        continue 
    else:
        continue 
gpx_data.index = np.arange(1, len(gpx_data) + 1)  

# saving csv file
gpx_data.to_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/gpx_data.csv') 

# open the file
gpx_data = pd.read_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/gpx_data.csv') 

# split the date and time into two columns, index and delete the unnecessary column
gpx_data.time.str.split(expand=True,) 
gpx_data[['date','time']] = gpx_data.time.str.split(" ",expand=True,)
gpx_data.index = np.arange(1, len(gpx_data) + 1)
gpx_data = gpx_data.drop(['Unnamed: 0', 'id'], axis = 1)

# we separate the time and "+00: 00" into two columns and delete the unnecessary column
gpx_data.time.str.split(expand=True,) 
gpx_data[['time','min']] = gpx_data.time.str.split("+",expand=True,)
gpx_data = gpx_data.drop(['min'], axis = 1)

# divide time into hours minutes and seconds
gpx_data[['h','m','s']] = gpx_data['time'].astype(str).str.split(':', expand=True).astype(int) 

# deleting unnecessary columns
gpx_data = gpx_data.drop(['time', 'm', 's'], axis = 1)

# change the name in the column
gpx_data = gpx_data.rename(columns={'h': 'time'}) 

# Compute real speed in *kph*
gpx_data['real_speed'] = 60 / gpx_data['speed']

# Drop all speed over 7.82 kph
gpx_data.drop = gpx_data[gpx_data['speed'] >= 7.281]
gpx_data = gpx_data.drop

# re-index and save as a new file
gpx_data.index = np.arange(1, len(gpx_data) + 1)
gpx_data.to_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/gpx_data_new.csv') 

# open the file
pogoda = pd.read_csv('C:/Users/hrypo/Documents/visual_project/pogoda.csv', ';') 

# create dataframe
frame = DataFrame(pogoda) 

# doing indexing
frame.index = np.arange(1, len(frame) + 1) 

# remove even lines that indicate half an hour
frame = frame.iloc[::2] 

# index
frame.index = np.arange(1, len(frame) + 1) 

# deleting unnecessary columns
frame = frame.drop(['P0', 'P', 'U', 'DD', 'Ff', 'ff10', 'WW', 'W', 'c', 'VV', 'Td'], axis = 1) 

# add packages
from datetime import datetime
import matplotlib.pyplot as plot
import time
import datetime
import os

# divide hours and minutes into two columns
frame.time.str.split(expand=True,)
frame[['time','min']] = frame.time.str.split(":",expand=True,) 

# remove unnecessary column minutes
frame = frame.drop(['min'], axis = 1) 

# rename the column
frame = frame.rename(columns={'data': 'date'}) 

# save the new file
frame.to_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/pogoda_new.csv') 

# open two converted files
data1 = pd.read_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/gpx_data_new.csv') 
data2 = pd.read_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/pogoda_new.csv') 


# join two files
output1 = pd.merge(data1, data2, 
                   on=['date', 'time'], 
                   how='left') 

# save the resulting table with data to build the model
output1.to_csv('C:/Users/hrypo/Documents/visual_project/walking_tracks_csv/output1.csv') 

