# OpenStudio Environments

This repository contains Openstudio simulation models for different room configurations (large, medium, and small) based on room A403. These models are designed to analyze HVAC performance, indoor air quality, and occupancy effects in various room sizes.

# EpJSON Conversion for Sinergym

To convert the .idf file to .epJSON file, we will use "Convert Input Format" script of EnergyPlus. Provide .idf file after you press Run inside OpenStudio. The script will generate a file at the same folder of in.idf. Then rename the file.

hekimoglu ~$ /Applications/EnergyPlus-24-1-0/ConvertInputFormat-24.1.0 /Users/hekimoglu/workspace/openstudio_envs/A403-small/run/in.idf

hekimoglu ~/workspace/openstudio_envs/A403-small/run $ mv in.epJSON A403-small.epJSON

