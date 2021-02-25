begin

f = addfile("data/U10_zm.nc", "r")

u = f->u(time|:, {lev|10}, {lat|70}, lon|0)

nrun = 5

u = runave_n_Wrap(u, nrun, 0, 0)

time = f->time

date = cd_calendar(time, -2)

TIME = cd_calendar(time, -5)
year = TIME(:, 0)
month = TIME(:, 1)
day = TIME(:, 2)

nyear = count_unique_values(year)
year_unique = get_unique_values(year)

sfw_flag = new(dimsizes(time), integer, -999)
sfw_flag = 0

do n = 0, (nyear - 1)
	segment_index = ind( (year.eq.year_unique(n) .and. month.ge.2) .and. (year.eq.year_unique(n) .and. month.le.6) )
	
	u_segment = u(segment_index)
	
	do i = 1, (dimsizes(u_segment) - 1)
		if ( (.not.ismissing(u_segment(i - 1)) .and. .not.ismissing(u_segment(i))) .and. (u_segment(i - 1).ge.0 .and. u_segment(i).lt.0) ) then
			date_i = date(segment_index(i))
			date_i_index = ind(date.eq.date_i)
			sfw_flag(date_i_index) = 1
		end if
	end do
	
	delete(segment_index)
	delete(u_segment)
end do

reversal_index = ind(sfw_flag.eq.1)

do i = 0, (dimsizes(reversal_index) - 1)
	year_i = year(reversal_index(i))
	
	sfw_to_apr_index = ind( (date.ge.date(reversal_index(i))) .and. ( year.eq.year_i .and. month.le.6 ) )
	
	if ( any(u(sfw_to_apr_index).ge.0) ) then
		if ( max(u(sfw_to_apr_index)).gt.10 ) then
			sfw_flag(reversal_index(i)) = 0
		end if
	end if
	
	delete(sfw_to_apr_index)
end do

reversal_index_new = ind(sfw_flag.eq.1)

do i = 0, (dimsizes(reversal_index_new) - 2)
	delta_index = ind(date.ge.date(reversal_index_new(i)) .and. date.le.date(reversal_index_new(i + 1)))
	
	u_delta = u(delta_index)
	
	if ( all(u_delta.lt.10) ) then
		sfw_flag(reversal_index_new(i)) = 0
	end if
	
	delete(delta_index)
	delete(u_delta)
end do

sfw_index = ind(sfw_flag.eq.1)

sfw_events = date(sfw_index)

month_string = (/"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)

print(day(sfw_index) + "-" + month_string(month(sfw_index) - 1) + "-" + year(sfw_index))

asciiwrite("sfw_events_erainterim.txt", sfw_events)

end
