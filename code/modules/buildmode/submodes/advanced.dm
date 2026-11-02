/datum/buildmode_mode/advanced
	key = "advanced"
	var/objholder = null

// FIXME: add logic which adds a button displaying the icon
// of the currently selected path

/datum/buildmode_mode/advanced/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>PPM na przycisku trybu budowania = Ustaw typ obiektu</span>")
	to_chat(c, "<span class='notice'>LPM + alt na turfie/obiekcie    = Skopiuj typ obiektu")
	to_chat(c, "<span class='notice'>LPM na turfie/obiekcie          = Postaw obiekty</span>")
	to_chat(c, "<span class='notice'>PPM                             = Usuń obiekty</span>")
	to_chat(c, "")
	to_chat(c, "<span class='notice'>Przyciskiem w lewym górnym rogu</span>")
	to_chat(c, "<span class='notice'>zmieniasz kierunek budowanych obiektów.</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/advanced/change_settings(client/c)
	var/target_path = input(c, "Podaj ścieżkę typu:", "Ścieżka typu", "/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			alert("Nie wybrano ścieżki")
			return
		else if(ispath(objholder, /area))
			objholder = null
			alert("Ta ścieżka jest niedozwolona.")
			return

/datum/buildmode_mode/advanced/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/alt_click = pa.Find("alt")

	if(left_click && alt_click)
		if (istype(object, /turf) || istype(object, /obj) || istype(object, /mob))
			objholder = object.type
			to_chat(c, "<span class='notice'>[initial(object.name)] ([object.type]): wybrano.</span>")
		else
			to_chat(c, "<span class='notice'>[initial(object.name)] nie jest turfem, obiektem ani mobem! Wybierz ponownie.</span>")
	else if(left_click)
		if(ispath(objholder,/turf))
			var/turf/T = get_turf(object)
			log_admin("Build Mode: [key_name(c)] modified [T] in [AREACOORD(object)] to [objholder]")
			T.ChangeTurf(objholder)
		else if(!isnull(objholder))
			var/obj/A = new objholder (get_turf(object))
			A.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(c)] modified [A]'s [COORD(A)] dir to [BM.build_dir]")
		else
			to_chat(c, "<span class='warning'>Najpierw wybierz typ obiektu.</span>")
	else if(right_click)
		if(isobj(object))
			log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
			qdel(object)
