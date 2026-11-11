/// Kolor obudowy w oknie automatu, liczony raz na sprite: "ikona-stan" -> "#rrggbb"
GLOBAL_LIST_EMPTY(vending_window_colors)

/**
 * Główny kolor sprite'a automatu, którym okno maluje ramę i szyld.
 * Wybiera odcień, który zajmuje najwięcej wyraźnie kolorowych pikseli; szare automaty dostają szary.
 */
/obj/machinery/vending/proc/window_color()
	var/key = "[icon]-[initial(icon_state)]"
	if(key in GLOB.vending_window_colors)
		return GLOB.vending_window_colors[key]
	var/icon/sprite = icon(icon, initial(icon_state), SOUTH, 1)
	var/list/weight = new /list(12)
	var/list/sums = new /list(12)
	var/gray_sum = 0
	var/gray_count = 0
	for(var/x in 1 to sprite.Width())
		for(var/y in 1 to sprite.Height())
			var/pixel = sprite.GetPixel(x, y)
			if(!pixel)
				continue
			var/list/hsl = rgb2num(pixel, COLORSPACE_HSL)
			if(hsl[3] < 12 || hsl[3] > 92)
				continue
			if(hsl[2] < 25)
				gray_sum += hsl[3]
				gray_count++
				continue
			var/bin = clamp(round(hsl[1] / 30) + 1, 1, 12)
			weight[bin] += hsl[2]
			var/list/rgb = rgb2num(pixel)
			if(!sums[bin])
				sums[bin] = list(0, 0, 0, 0)
			var/list/sum = sums[bin]
			sum[1] += rgb[1]
			sum[2] += rgb[2]
			sum[3] += rgb[3]
			sum[4]++
	var/best = 0
	for(var/bin in 1 to 12)
		if(weight[bin] && (!best || weight[bin] > weight[best]))
			best = bin
	var/result
	if(best && weight[best] > 400)
		var/list/sum = sums[best]
		result = rgb(sum[1] / sum[4], sum[2] / sum[4], sum[3] / sum[4])
	else
		var/light = gray_count ? gray_sum / gray_count : 50
		result = rgb(0, 0, light, space = COLORSPACE_HSL)
	GLOB.vending_window_colors[key] = result
	return result
