# GREGOR campaing webpage
# Sebastian Castellanos Duran, MPS Jul 2018

Short webpage that sumarizes GRIS+ and some GRIS observations taken by MPS. 
It displays SDO images of the HMI and AIA channels

# What to do
There are simple idl routines that generates automatically the entite webpage.

- The download, cut and process SDO data
- Creates all the webpage structure like sub pages for each day

# To run
OPEN SSWIDL terminal and run

.r jscd_run_all

This will call all subroutines

# New data?

Fill the table:
  
  gregor_obs.csv

and run all the pipeline again

# General templates
The 'neutral' files: 

index_neutral.html
day_neutral.html

are the basic and general output of the page. The routines will read them and 
add the extra information for each day. Notices that changes on this files, will 
require to change the loc_obs_in_index variables on the subroutines!

# Routines
jscd_general_path.pro  -> general path. Change if you change the location of the folder
jscd_run_all.pro       -> To run all pipeline
jscd_download_hmi.pro  -> download hmi data
jscd_coaligned_hmi.pro -> process SDO data, creates images and videos and subcubes
jscd_index.pro         -> To create the index file - HOME PAGE
jscd_days_index.pro    -> To create all days files with the table
jscd_obs.pro           -> To create all obs files

# Location
data    : ./day/obs/data/"year"/"day"/"SDO obs"/
subcubes: ./day/obs/data/"year"/"day"/"SDO obs"/"year"_"SDO obs".fits
images  : ./day/obs/images/"year"/"day"/"SDO obs"/"year"_"SDO obs.jpg
videos  : ./day/obs/videos/"year"/"day"/"SDO obs"/"year"_"SDO obs.jpg


