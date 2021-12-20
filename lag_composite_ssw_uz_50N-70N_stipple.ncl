begin

f1 = addfile("data/uz.anom.1979-2020.daily.50N-70N.zon.nc", "r")

time = f1->time
plev = f1->plev

date = cd_calendar(time, -2)

u = f1->u

f2 = asciiread("ssw_events_era5.txt", -1, "integer")

ssw = f2

ssw_index = new(dimsizes(ssw), integer, -999)

do i = 0, (dimsizes(ssw) - 1)
	ssw_index(i) = ind(date.eq.ssw(i))
end do

maxlag = 40

lag = ispan(-maxlag, maxlag, 1)
lag!0 = "lag"
lag&lag = lag
lag@long_name = "Lagtime"
lag@units = "days"

n = new(dimsizes(lag), integer, -999)
n = 0
n!0 = "lag"
n&lag = lag

composite = new((/dimsizes(lag), dimsizes(plev)/), float, -999)
composite = 0.0

composite!0 = "lag"
composite!1 = "plev"

composite&lag = lag
composite&plev = plev

alpha = composite

nBoot = 1000

do l = 0, (dimsizes(lag) - 1)
	u_lag = new((/dimsizes(ssw_index), dimsizes(plev)/), float, -999)
	
	do i = 0, (dimsizes(ssw_index) - 1)
		if (.not.ismissing(ssw_index(i)) .and. (ssw_index(i) + lag(l)).ge.0 .and. (ssw_index(i) + lag(l)).le.(dimsizes(time) - 1)) then
			n(lag|l) = (/n(lag|l) + 1/)
			composite(lag|l, plev|:) = (/composite(lag|l, plev|:) + u(time|(ssw_index(i) + lag(l)), plev|:)/)
			u_lag(i, :) = u(ssw_index(i) + lag(l), :)
		end if
	end do
	
	BootStrap = bootstrap_stat(u_lag, 0, nBoot, 0, False)
	zBootStrap = BootStrap[0]
	zBootStrapLow = where(zBootStrap.lt.0, 1.0, 0.0)
	zBootStrapHigh = where(zBootStrap.gt.0, 1.0, 0.0)
	
	alpha_low = 100.0 * (1.0 - 2.0 * dim_sum_n(zBootStrapLow, 0) / int2flt(nBoot))
	alpha_high = 100.0 * (1.0 - 2.0 * dim_sum_n(zBootStrapHigh, 0) / int2flt(nBoot))
	
	alpha(lag|l, plev|:) = (/where(alpha_low.ge.0, alpha_low, alpha_high)/)
	
	delete(u_lag)
	delete(BootStrap)
	delete(zBootStrap)
	delete(zBootStrapLow)
	delete(zBootStrapHigh)
	delete(alpha_low)
	delete(alpha_high)
end do

composite = (/composite / conform(composite, n, 0)/)

wks = gsn_open_wks("png", "lag_composite_ssw_uz_50N-70N_stipple")

cmap = read_colormap_file("MPL_RdBu")

res = True
res@gsnDraw = False
res@gsnFrame = False
res@vpWidthF = 1.0
res@vpHeightF = 0.5
res@trXMinF = -30
res@trXMaxF = 40
res@cnFillOn = True
res@cnFillPalette = cmap(::-1, :)
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/-64.0, -32.0, -16.0, -8.0, -4.0, -2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0/)
res@lbLabelBarOn = False
res@tmYLMode = "Explicit"
res@tmYLValues = (/1.0, 3.0, 5.0, 10.0, 30.0, 50.0, 100.0, 300.0, 500.0, 1000.0/)
res@tmYLLabels = (/"1", "3", "5", "10", "30", "50", "100", "300", "500", "1000"/)
res@tmYRMode = "Automatic"
res@tmYLMajorOutwardLengthF = 0.0
res@tmXBMajorOutwardLengthF = 0.0
res@tmXBMinorOutwardLengthF = 0.0
res@tmYLLabelFontHeightF = 0.025
res@tmXBLabelFontHeightF = 0.025
res@tiYAxisFontHeightF = 0.025
res@tiXAxisString = "Lag [days]"
res@tiXAxisFontHeightF = 0.025
res@gsnStringFontHeightF = 0.025

res@tiYAxisString = "p [hPa]"

plot = gsn_csm_pres_hgt(wks, composite(plev|:, lag|:), res)

resAlpha = True
resAlpha@gsnDraw = False
resAlpha@gsnFrame = False
resAlpha@cnLinesOn = False
resAlpha@cnLineLabelsOn = False
resAlpha@cnInfoLabelOn = False
resAlpha@cnLevelSelectionMode = "ManualLevels"
resAlpha@cnMinLevelValF = 80.0
resAlpha@cnMaxLevelValF = 100.0
resAlpha@cnLevelSpacingF = 2.5
resAlpha@tmYRMode = "Automatic"
resAlpha@gsnLeftString = ""
resAlpha@gsnRightString = ""

opt = True
opt@gsnShadeFillType = "pattern"
opt@gsnShadeFillDotSizeF = 0.0025
opt@gsnShadeFillScaleF = 1.5
opt@gsnShadeHigh = 17

alpha_value = 95.0

plot_alpha = gsn_csm_pres_hgt(wks, alpha(plev|:, lag|:), resAlpha)
plot_alpha = gsn_contour_shade(plot_alpha, 100.0 - alpha_value, alpha_value, opt)
overlay(plot, plot_alpha)

resLine = True
resLine@gsLineColor = "grey"

plot@$unique_string("line")$ = gsn_add_polyline(wks, plot, (/0.0, 0.0/), (/1.0, 1000.0/), resLine)

plot@$unique_string("line")$ = gsn_add_polyline(wks, plot, (/res@trXMinF, res@trXMaxF/), (/250.0, 250.0/), resLine)

resP = True
resP@gsnMaximize = True
resP@gsnPanelLabelBar = True
resP@lbBoxEndCapStyle = "TriangleBothEnds"
resP@lbBoxLinesOn = False
resP@lbLabelFontHeightF = 0.015
resP@lbTitleOn = True
resP@lbTitleDirection = "across"
resP@lbTitlePosition = "bottom"
resP@lbTitleString = "[m s~S~-1~N~]"
resP@lbTitleFontHeightF = 0.015
resP@pmLabelBarWidthF = 0.8
resP@pmLabelBarHeightF = 0.05
resP@pmLabelBarOrthogonalPosF = -0.05

gsn_panel(wks, plot, (/1, 1/), resP)

end
