# Remote Sensing Video Alignment (ReSVA)

This is a simple, flexible MATLAB code package that geocorrects and combines video-based remotely sensed data without the full use of position and attitude hardware (i.e. Global Navigation Satellite System - GNSS / Inertial Measurement Unit - IMU). The main ReSVA file will load in the example dataset ("raw_ir_data.mat"), and run it through the two-step process of registering the data, followed by gridding it into a final geocorrected image. For complete information on this methodology, please see the following paper:

Naprstek, T., Arroyo-Mora, J. P., Johnston, J. M., and G. Leblanc, 2021, ReSVA: A MATLAB method to co-register and mosaic airborne video-based remotely sensed data, MethodsX, 8, 101471. https://doi.org/10.1016/j.mex.2021.101471

For an example of its use within airborne remote sensing research, please see the following paper:

Ifimov, G., Naprstek, T., Johnston, J. M., Arroyo-Mora, J. P., Leblanc, G., & Lee, M. D. (2021). Geocorrection of Airborne Mid-Wave Infrared Imagery for Mapping Wildfires without GPS or IMU. Sensors, 21(9), 3047.
