# Remote Sensing Video Alignment (ReSVA)

This is a simple, flexible MATLAB code package that combines video-based remotely sensed data without the full use of position and attitude hardware (i.e. Global Navigation Satellite System - GNSS / Inertial Measurement Unit - IMU). The main ReSVA file will load in the example dataset ("raw_ir_data.mat"), and run it through the two-step process of registering the data, followed by gridding it into a final geocorrected image. For complete information on this methodology, please see the following paper:

T. Naprstek, J. P. Arroyo-Mora, J. M. Johnston, and G. Leblanc, ReSVA: A MATLAB method to co-register and mosaic airborne video-based remotely sensed data, MethodsX (Under Review), 2021.

For an example of its use within airborne remote sensing research, please see the following paper:

G. Ifimov, T. Naprstek, J. M. Johnston, J. P. Arroyo-Mora, G. Leblanc, and M. D. Lee, Geocorrection of Airborne Mid-Wave Infrared Imagery for Mapping Wildfires without GPS or IMU, Sensors (Under Review), 2021.
