// AQUILA - warstwa zgodności obszaru UI kultu krwi (mind_ui z vgstation, przez draft Monkestation#3867).

// ---- /obj/abstract ----
// W vg to baza obiektów, które nie biorą udziału w grze (elementy mind_ui w client.screen, znaczniki).
// U nas nie ma takiego typu, więc definiujemy go tutaj, żeby nic go nie niszczyło ani nie przesuwało.
/obj/abstract
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/abstract/ex_act(severity, target)
	return

/obj/abstract/singularity_act()
	return

/obj/abstract/singularity_pull(S, current_size)
	return

// ---- helpery screen_loc z nowszego tg (code/__HELPERS/screen_objs.dm) ----

/// Zamienia screen_loc ("CENTER:-12,BOTTOM:39", "3:10,15:29"...) na przesunięcie w pikselach od lewego dolnego rogu: list(x, y)
/proc/screen_loc_to_offset(screen_loc, view)
	if(!screen_loc)
		return list(64, 64)
	var/list/view_size = getviewsize(view) // AQUILA - u nas nie ma view_to_pixels(), liczymy piksele na miejscu
	view_size[1] *= world.icon_size
	view_size[2] *= world.icon_size
	var/x = 0
	var/y = 0
	if(findtext(screen_loc, "EAST"))
		x += view_size[1]
	if(findtext(screen_loc, "WEST"))
		x += world.icon_size
	if(findtext(screen_loc, "NORTH"))
		y += view_size[2]
	if(findtext(screen_loc, "SOUTH"))
		y += world.icon_size

	var/list/x_and_y = splittext(screen_loc, ",")

	var/list/x_pack = splittext(x_and_y[1], ":")
	var/list/y_pack = splittext(x_and_y[2], ":")

	var/x_coord = x_pack[1]
	var/y_coord = y_pack[1]

	if (findtext(x_coord, "CENTER"))
		x += view_size[1] / 2

	if (findtext(y_coord, "CENTER"))
		y += view_size[2] / 2

	x_coord = text2num(cut_relative_direction(x_coord))
	y_coord = text2num(cut_relative_direction(y_coord))

	x += x_coord * world.icon_size
	y += y_coord * world.icon_size

	if(length(x_pack) > 1)
		x += text2num(x_pack[2])
	if(length(y_pack) > 1)
		y += text2num(y_pack[2])
	return list(x, y)

/// Wycina z fragmentu screen_loc słowa kierunków (CENTER, NORTH, LEFT...)
/proc/cut_relative_direction(fragment)
	var/static/regex/regex = regex(@"([A-Z])\w+", "g")
	return regex.Replace(fragment, "")

// ---- czcionka YouMurderer BB ----
// Plik youmurdererbb_reg.ttf ma tylko znaki ASCII (108 glifów, bez ąćęłńóśźż), więc polski tekst
// w maptexcie tą czcionką gubi litery. Ten helper zdejmuje ogonki, tak jak status_display robi to dla TinyUnicode.
/proc/youmurderer_safe_text(text)
	var/static/list/polish_letters = list(
		"ą" = "a", "ć" = "c", "ę" = "e", "ł" = "l", "ń" = "n", "ó" = "o", "ś" = "s", "ź" = "z", "ż" = "z",
		"Ą" = "A", "Ć" = "C", "Ę" = "E", "Ł" = "L", "Ń" = "N", "Ó" = "O", "Ś" = "S", "Ź" = "Z", "Ż" = "Z",
	)
	. = "[text]"
	for(var/letter in polish_letters)
		. = replacetext(., letter, polish_letters[letter])
