# Sudden Stratospheric Warmings

 A simple NCL's code to calculate the central dates of the SSWs following Charlton and Polvani (2007) and final stratospheric warming (FSW) following Black et al., (2002)
 
 SSWs Criteria:
 
 1. The central date or event date of a SSW occurs when the daily-mean zonal-mean zonal winds at 10 hPa and 60N first change from westerly to easterly between November and March. 
 2. The winds must return to westerly for 20 consecutive days between events (to avoid counting the same event twice, roughly equivalent to the thermal damping timescale at 10 hPa). 
 3. If the winds do not return to westerly for at least 10 consecutive days before 30 April, the warming is a final warming
and is not included. 

 FSWs Criteria:
 1. SFW events are identified as the final time that the zonal-mean zonal wind at 70°N (the core latitude of the stratospheric polar vortex) drops below zero without returning to a specified positive threshold value until the subsequent autumn. 
 2. We apply this criterion to running 5-day averages at 10 hPa (with thresholds of 10 m/s).

<p align="center">
  <img src="https://github.com/sandrolubis/Sudden_Stratospheric_Warmings/blob/main/example/SSWs_Evolution.png" width="800">
</p>

##### Lubis, S.W., C.S. Huang, and N. Nakamura, 2018: Role of Finite-Amplitude Eddies and Mixing in the Life Cycle of Stratospheric Sudden Warmings. J. Atmos. Sci., 75,3987–4003, https://doi.org/10.1175/JAS-D-18-0138.1
