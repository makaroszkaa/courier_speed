setwd("/home/georgy/Документы/GitHub/courier_speed")
dir()

# Setup
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(splines))


# Read data
# Delete row number column
# Delete alt difference column
raw_data = data.table::fread("raw_data.csv")
raw_data = as.data.frame(raw_data)
raw_data = raw_data[, -1]
raw_data = raw_data[, -ncol(raw_data)]


# Rename columns to better interpret the data
colnames(raw_data)[7] = "hour"
colnames(raw_data)[8] = "v_kph"
colnames(raw_data)[9] = "temp_c"


# Compute alt difference
# If rows %in% trip: difference(ele) else 0
list_trips = unique(raw_data$id)
tmp_data   = data.frame()
for (i in list_trips) {
    rd = raw_data %>% filter(id == i) %>% mutate(dele = c(0, diff(ele)))
    tmp_data = rbind(tmp_data, rd)
    rm(i, rd)
}
raw_data = tmp_data
rm(tmp_data, list_trips)

# Plot the speed vs alt diff
plot(x     = raw_data$dele,
     y     = raw_data$v_kph,
     col   = "dodgerblue",
     pch   = 19,
     frame = F,
     main  = "Speed vs difference in elevation",
     xlab  = "elevation difference, m",
     ylab  = "speed, kph")


# The plot shows that there are many points with elevation difference
# exceeding 50 m -- which is obviously not possible due to physics.
# We need to detect the outliers and substitute them with some kind of 
# values. We have to use a method, but simple vis also does give the idea
# of what is going on.
raw_data_outs = raw_data %>% filter(dele > -10 & dele < 10)
plot(x     = raw_data_outs$dele,
     y     = raw_data_outs$v_kph,
     col   = "dodgerblue",
     pch   = 19,
     frame = F,
     main  = "Speed vs difference in elevation without outs",
     xlab  = "elevation difference, m",
     ylab  = "speed, kph")

# Check if there is a correlation between going variables
# The plot shows that there is no way to determine the speed using these
# variables.
cor_data = raw_data_outs %>% select(v_kph, hour, temp_c, dele)
res2     = Hmisc::rcorr(as.matrix(cor_data))
corrplot::corrplot(res2$r, 
                   type = "upper", 
                   order = "hclust",
                   p.mat = res2$P,
                   sig.level = 0.01,
                   insig = "pch")
rm(res2, cor_data, raw_data_outs)


# Check if there is a correlation between speed and distance travelled
# Use haversine formula to compute the distance between points
# Test haversine formula on two points
p1 = c(raw_data$lat[1], raw_data$lon[1])
p2 = c(raw_data$lat[2], raw_data$lon[2])
d1 = pracma::haversine(p1, p2) * 1000
rm(p1, p2, d1)

list_trips = unique(raw_data$id)
list_trips = list_trips[-10]
tmp_data = data.frame()
for (i in list_trips){
    temp_df = raw_data %>% filter(id == i)
    d_vect  = vector()
    for (k in 1:(nrow(temp_df)-1)){
        p1     = c(temp_df$lat[k], temp_df$lon[k])
        p2     = c(temp_df$lat[k+1], temp_df$lon[k+1])
        # d1     = pracma::haversine(p1, p2) * 1000
        d1     = tryCatch({pracma::haversine(p1, p2) * 1000},
                          error = function(e){0})
        d_vect = c(d_vect, d1)
    }
    d_vect = c(0, d_vect)
    temp_df$dist = d_vect
    tmp_data = rbind(tmp_data, temp_df)
    print(paste(i, "--done"))
    rm(temp_df, i, k, d_vect)
    rm(p1, p2, d1)
}

raw_data = tmp_data
rm(tmp_data, list_trips)


list_trips = unique(raw_data$id)
tmp_data = data.frame()
for (i in list_trips){
    rd = raw_data %>% filter(id == i) %>% mutate(acc_dist = cumsum(dist))
    tmp_data = rbind(tmp_data, rd)
    rm(i, rd)
}
raw_data = tmp_data
rm(tmp_data, list_trips)

by_dist = raw_data
by_dist$acc_dist = round(by_dist$acc_dist, 0)
by_dist = by_dist %>% group_by(acc_dist) %>% summarise(speed = mean(v_kph))

# Make a plot of speed vs travelled distance
# The speed does not depend on travelled distance
plot(x     = by_dist$acc_dist,
     y     = by_dist$speed,
     col   = "dodgerblue1",
     type  = "l",
     frame = F)
rm(by_dist)

# Check if there is a correlation between going variables
# The plot shows that there is no way to determine the speed using these
# variables.
cor_data = raw_data %>% select(v_kph, hour, temp_c, dele, acc_dist)
res2     = Hmisc::rcorr(as.matrix(cor_data))
corrplot::corrplot(res2$r, 
                   type = "upper", 
                   order = "hclust",
                   p.mat = res2$P,
                   sig.level = 0.01,
                   insig = "pch")
rm(res2, cor_data)



# Make artificial dataset -------------------------------------------------

# Variables: hour, temp_c, dele, acc_dist
# Result: v_kph

# Define constants
list_trips = unique(raw_data$id)
total_hrs  = 1:24
temp_cels  = 10:25



# Make temp dataset with less columns so it is easier to follow
test_df = 
    raw_data %>% 
    filter(id == list_trips[1]) %>% 
    select(lat, lon, dele, acc_dist)

tmp_data = data.frame()
for (i in 1:length(list_trips)){
    ## define params
    trip_name = paste0("trip_", i)
    trip_hour = sample(total_hrs, 1, replace = T)
    trip_temp = sample(temp_cels, 1, replace = T)
    
    ## filter values
    test_df   = 
        raw_data %>% 
        filter(id == list_trips[i]) %>% 
        select(lat, lon, dele, acc_dist)
    test_df$trip_id = trip_name
    test_df$trip_hr = trip_hour
    
    ## bind to dataframe
    tmp_data = rbind(tmp_data, test_df)
    rm(i, test_df, trip_name, trip_hour, trip_temp)
}


# Sample trips from tmp dataframe to make new trips
tmp_data2 = data.frame()
list_ids2 = unique(tmp_data$trip_id)
sampl_ids = sample(list_ids2, size = 2000, replace = T)

for (i in 1:length(sampl_ids)){
    trip_name = paste0("trip_", i)
    trip_hour = sample(total_hrs, 1, replace = T)
    trip_temp = sample(temp_cels, 1, replace = T)
    
    ## filter values
    test_df   = 
        tmp_data %>% 
        filter(trip_id == sampl_ids[i]) %>% 
        select(lat, lon, dele, acc_dist)
    test_df$trip_id = trip_name
    test_df$trip_hr = trip_hour
    test_df$trip_tc = trip_temp
    
    ## bind to dataframe
    tmp_data2 = rbind(tmp_data2, test_df)
    rm(i, test_df, trip_name, trip_hour, trip_temp)
}

rm(raw_data, tmp_data, list_ids2, list_trips, sampl_ids, temp_cels, total_hrs)

# Reorder columns
tmp_data2 = tmp_data2 %>% select(trip_id, lat, lon, everything())
head(tmp_data2)


# Plot hist of variables to see the distributions
hist(tmp_data2$dele,
     col = "lightgreen")
hist(tmp_data2$trip_hr,
     col = "lightgreen")
hist(tmp_data2$trip_tc,
     col = "dodgerblue2")


# Add v_kph computation from change in elevation
# Delete outliers prior to making the formula
summary(tmp_data2$dele)
tmp_data2$dele_tmp = tmp_data2$dele
tmp_data2$dele_tmp[tmp_data2$dele < -5] = 0
tmp_data2$dele_tmp[tmp_data2$dele > 5] = 0
hist(tmp_data2$dele_tmp, col = "lightgreen")
tmp_data2$v_dele = 4.2

# Make small model for dele < 0
small_df = data.frame(dele = c(-5.2, -5, -4.3, -4, -3, -2, -1),
                      sped = c(8, 7.4, 6.2, 6, 4.3, 4.2, 4.2))
mod1 = lm(sped ~ ns(dele, df = 3), data = small_df)
pred = predict(mod1, newdata = small_df)

plot(x     = small_df$dele,
     y     = small_df$sped,
     col   = "dodgerblue1",
     frame = F,
     pch   = 19,
     xlab  = "elevation",
     ylab  = "speed")
lines(small_df$dele, pred, col = "red")
rm(small_df, pred)

# Compute speed using small model
tmp2 = tmp_data2 %>% select(dele_tmp, v_dele) %>% filter(dele_tmp < 0)
colnames(tmp2) = c("dele", "sped")
pred_vdele = predict(mod1, newdata = tmp2)
head(pred_vdele)
tmp_data2$v_dele[tmp_data2$dele_tmp < 0] = pred_vdele
rm(mod1, tmp2, pred_vdele)
head(tmp_data2)


# Compute speed for dele > 0
small_df = data.frame(dele = c(0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0),
                      sped = c(4.2, 4.1, 4.1, 3.9, 3.6, 3.5, 3.5, 3.5))
mod1 = lm(sped ~ ns(dele, df = 3), data = small_df)
tmp2 = tmp_data2 %>% select(dele_tmp, v_dele) %>% filter(dele_tmp > 0)
colnames(tmp2) = c("dele", "sped")
pred_vdele = predict(mod1, newdata = tmp2)
head(pred_vdele)
tmp_data2$v_dele[tmp_data2$dele_tmp > 0] = pred_vdele
rm(mod1, tmp2, pred_vdele)
rm(small_df)
head(tmp_data2)
summary(tmp_data2)


# Add jitter to speed from elevation
tmp_data2$v_dele_jit = jitter(tmp_data2$v_dele, factor = 1000)
tmp_data2 = tmp_data2 %>% select(-c(dele_tmp, v_dele))


# Compute speed from distance
summary(tmp_data2$acc_dist)
small_df = data.frame(dist = c(0, 
                               100, 
                               1000, 
                               5000, 
                               10000, 
                               15000, 
                               20000,
                               30000,
                               40000),
                      sped = c(7.0, 
                               6.4, 
                               6.0, 
                               5.2,
                               5.0,
                               4.0,
                               3.8,
                               3.0,
                               0.1))
mod2 = lm(sped ~ dist, data = small_df)
plot(x     = small_df$dist,
     y     = small_df$sped,
     col   = "dodgerblue1",
     frame = F,
     pch   = 19,
     xlab  = "distance",
     ylab  = "speed")
lines(small_df$dist, predict(mod2, newdata = small_df), col = "red")
rm(small_df)

tmp_data2$v_dist = 4.2
tmp3 = tmp_data2 %>% select(acc_dist, v_dist)
colnames(tmp3) = c("dist", "sped")
pred_vdist = predict(mod2, newdata = tmp3)
tmp_data2$v_dist = pred_vdist
tmp_data2$v_dist_jit = jitter(tmp_data2$v_dist, factor = 1000)
tmp_data2 = tmp_data2 %>% select(-v_dist)
rm(mod2, tmp3, pred_vdist)

# Plot speed vs distance
plot(x     = tmp_data2$acc_dist,
     y     = tmp_data2$speed,
     col   = "dodgerblue1",
     pch   = 19,
     frame = F,
     main  = "Speed by distance",
     xlab  = "distance, m",
     ylab  = "speed, kph")

tmp_data2$speed = (tmp_data2$v_dele_jit + tmp_data2$v_dist_jit) / 2
tmp_data2 = tmp_data2 %>% select(-c(v_dele_jit, v_dist_jit))
write.csv(tmp_data2, "courier_data.csv", row.names = F)

by_distance = 
    tmp_data2 %>% group_by(round(acc_dist,2)) %>% summarise(speed = mean(speed))
plot(x     = by_distance$`round(acc_dist, 2)`,
     y     = by_distance$speed,
     col   = "dodgerblue1",
     pch   = 19,
     frame = F,
     main  = "Speed by distance",
     xlab  = "distance, m",
     ylab  = "speed, kph")

by_ele =
    tmp_data2 %>% 
    group_by(ele = round(dele, 2)) %>% summarise(speed = mean(speed))
plot(x     = by_ele$ele,
     y     = by_ele$speed,
     col   = "dodgerblue1",
     pch   = 19,
     frame = F,
     main  = "Speed by distance",
     xlab  = "distance, m",
     ylab  = "speed, kph")
