/datum/buildmode_mode/varedit
	key = "edit"
	// Varedit mode
	var/varholder = null
	var/valueholder = null

/datum/buildmode_mode/varedit/Destroy()
	varholder = null
	valueholder = null
	return ..()

/datum/buildmode_mode/varedit/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>PPM na przycisku trybu budowania = Wybierz zmienną (typ) i wartość</span>")
	to_chat(c, "<span class='notice'>LPM na turfie/obiekcie/mobie      = Ustaw zmienną (typ) i wartość</span>")
	to_chat(c, "<span class='notice'>PPM na turfie/obiekcie/mobie     = Przywróć wartość zmiennej</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/varedit/Reset()
	. = ..()
	varholder = null
	valueholder = null

/datum/buildmode_mode/varedit/change_settings(client/c)
	varholder = input(c, "Podaj nazwę zmiennej:" ,"Nazwa", "name")
	
	if(!vv_varname_lockcheck(varholder))
		return

	var/temp_value = c.vv_get_value()
	if(isnull(temp_value["class"]))
		Reset()
		to_chat(c, "<span class='notice'>Zmienna wyczyszczona.</span>")
		return
	valueholder = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(isnull(varholder))
		to_chat(c, "<span class='warning'>Najpierw wybierz zmienną do modyfikacji.</span>")
		return
	if(left_click)
		if(object.vars.Find(varholder))
			if(object.vv_edit_var(varholder, valueholder) == FALSE)
				to_chat(c, "<span class='warning'>Obiekt odrzuca twoją edycję.</span>")
				return
			log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [valueholder]")
		else
			to_chat(c, "<span class='warning'>[initial(object.name)] nie ma zmiennej o nazwie „[varholder]”</span>")
	if(right_click)
		if(object.vars.Find(varholder))
			var/reset_value = initial(object.vars[varholder])
			if(object.vv_edit_var(varholder, reset_value) == FALSE)
				to_chat(c, "<span class='warning'>Obiekt odrzuca twoją edycję.</span>")
				return
			log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [reset_value]")
		else
			to_chat(c, "<span class='warning'>[initial(object.name)] nie ma zmiennej o nazwie „[varholder]”</span>")

