/datum/buildmode_mode/copy
	key = "copy"
	var/atom/movable/stored = null

/datum/buildmode_mode/copy/Destroy()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>LPM na obiekcie/turfie/mobie   = Stwórz kopię wybranego celu</span>")
	to_chat(c, "<span class='notice'>PPM na obiekcie/mobie = Wybierz cel do skopiowania</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/copy/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		var/turf/T = get_turf(object)
		if(stored)
			DuplicateObject(stored, perfectcopy=1, sameloc=0,newloc=T)
			log_admin("Build Mode: [key_name(c)] copied [stored] to [AREACOORD(object)]")
	else if(right_click)
		if(ismovableatom(object)) // No copying turfs for now.
			to_chat(c, "<span class='notice'>[object]: ustawiono jako szablon.</span>")
			stored = object
