# Code
In this folder, you will find the code used in the PCG signal classifier project. The "data acquisition" folder contains the original functions provided by Physionet for segmenting the signals into different stages of cardiac sounds, among other relevant functions, including the main file used to store all the .wav files from the database into a matlab structure.
The data used can be downloaded for free from: https://physionet.org/content/challenge-2016/1.0.0/ 
This website allows you to obtain six folders with the datasets for training, named training-a, training-b, training-c, training-d, training-e, and training-f.
The main.m file is responsible for preprocessing the signals, training the model, and conducting the model's tests.
