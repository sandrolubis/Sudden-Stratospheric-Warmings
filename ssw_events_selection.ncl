; Author: Dr. Sandro Lubis (Feb, 2021)
;         A simple NCL's code to calculate the central dates of the SSWs
;         following Charlton and Polvani (2007).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

f     = addfile("data/U10_zm.nc", "r") ; input data

u     = f->u(time|:, {lev|10}, {lat|60}, lon|0)

time  = f->time

date  = cd_calendar(time, -2)

TIME  = cd_calendar(time, -5)
year  = TIME(:, 0)
month = TIME(:, 1)
day   = TIME(:, 2)

nyear = count_unique_values(year)
year_unique = get_unique_values(year)

ssw_flag = new(dimsizes(time), integer, -999)
ssw_flag = 0

do n = 0, (nyear - 2)
	segment_index = ind( (year.eq.year_unique(n) .and. month.ge.11) .or. (year.eq.year_unique(n + 1) .and. month.le.3) )
	
	u_segment = u(segment_index)
	
	do i = 1, (dimsizes(u_segment) - 1)
		if (u_segment(i - 1).ge.0 .and. u_segment(i).lt.0) then
			date_i = date(segment_index(i))
			date_i_index = ind(date.eq.date_i)
			ssw_flag(date_i_index) = 1
		end if
	end do
	
	delete(segment_index)
	delete(u_segment)
end do

reversal_index = ind(ssw_flag.eq.1)

do i = 1, (dimsizes(reversal_index) - 1)
	delta_index = ind(date.ge.date(reversal_index(i - 1)) .and. date.le.date(reversal_index(i)))
	
	u_delta = u(delta_index)
	u_delta_pos = ind(u_delta.ge.0)
	
	if (dimsizes(u_delta_pos).lt.20) then
		ssw_flag(reversal_index(i)) = 0
	end if
	
	delete(delta_index)
	delete(u_delta)
	delete(u_delta_pos)
end do

reversal_index_new = ind(ssw_flag.eq.1)

do i = 0, (dimsizes(reversal_index_new) - 1)
	if ( month(reversal_index_new(i)).le.3 ) then
		year_i = year(reversal_index_new(i))
		ssw_to_apr_index = ind( (date.ge.date(reversal_index_new(i))) .and. ( year.eq.year_i .and. month.le.4 ) )
		
		if ( all(u(ssw_to_apr_index).lt.0) ) then
			ssw_flag(reversal_index_new(i)) = 0
		else
			u_i = u(ssw_to_apr_index)
			u_i_pos = ind(u_i.ge.0)
			
			if ( dimsizes(u_i_pos).lt.10 ) then
				ssw_flag(reversal_index_new(i)) = 0
			end if
			
			delete(u_i)
			delete(u_i_pos)
		end if
		
		delete(ssw_to_apr_index)
	end if
	
	if ( month(reversal_index_new(i)).ge.11 ) then
		year_i = year(reversal_index_new(i))
		ssw_to_apr_index = ind( (date.ge.date(reversal_index_new(i))) .and. ( year.eq.(year_i + 1) .and. month.le.4 ) )
		
		if ( all(u(ssw_to_apr_index).lt.0) ) then
			ssw_flag(reversal_index_new(i)) = 0
		else
			u_i = u(ssw_to_apr_index)
			u_i_pos = ind(u_i.ge.0)
			
			if ( dimsizes(u_i_pos).lt.10 ) then
				ssw_flag(reversal_index_new(i)) = 0
			end if
			
			delete(u_i)
			delete(u_i_pos)
		end if
		
		delete(ssw_to_apr_index)
	end if
end do

ssw_index = ind(ssw_flag.eq.1)

ssw_events = date(ssw_index)

month_string = (/"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)

print(day(ssw_index) + "-" + month_string(month(ssw_index) - 1) + "-" + year(ssw_index))

asciiwrite("ssw_events_erainterim.txt", ssw_events)

end
