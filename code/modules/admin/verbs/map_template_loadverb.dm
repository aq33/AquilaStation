/client/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	var/datum/map_template/template

	var/map = i18n_input_choice(src, input(src, i18n_dialog_text(src, "Wybierz szablon mapy do postawienia w twoim OBECNYM MIEJSCU"),i18n_dialog_text(src, "Postaw szablon mapy")) as null|anything in i18n_input_shown(src, sortList(SSmapping.map_templates))) // AQ EDIT - i18n okienka
	if(!map)
		return
	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		var/image/item = image('icons/turf/overlays.dmi',S,"greenOverlay")
		item.plane = ABOVE_LIGHTING_PLANE
		preview += item
	images += preview
	if(i18n_alert(usr, src,"Potwierdź miejsce.","Potwierdzenie szablonu","Tak","Nie") == "Tak") // AQ EDIT - i18n okienka
		if(template.load(T, centered = TRUE))
			message_admins("<span class='adminnotice'>[key_name_admin(src)] stawia szablon mapy ([template.name]) w [ADMIN_COORDJMP(T)]</span>")
		else
			to_chat(src, "Nie udało się postawić mapy")
	images -= preview

/client/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	var/map = input(src, i18n_dialog_text(src, "Wybierz szablon mapy do wgrania do magazynu szablonów"),i18n_dialog_text(src, "Wgraj szablon mapy")) as null|file // AQ EDIT - i18n okienka
	if(!map)
		return
	if(copytext("[map]", -4) != ".dmm")//4 == length(".dmm")
		to_chat(src, "<span class='warning'>Nazwa pliku musi kończyć się na '.dmm': [map]</span>")
		return
	var/datum/map_template/M
	var/type
	switch(i18n_alert(usr, src, "Jaki to rodzaj mapy?", "Rodzaj mapy", "Zwykła", "Prom", "Anuluj")) // AQ EDIT - i18n okienka
		if("Zwykła")
			type = "Normal"
			M = new /datum/map_template(map, "[map] - Uploaded by [ckey] at [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")]", TRUE)
		if("Prom")
			type = "Shuttle"
			M = new /datum/map_template/shuttle(map, "[map] - Uploaded by [ckey] at [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")]", TRUE, copytext("[map]",1, -4))
		else
			return
	if(!M.cached_map)
		to_chat(src, "<span class='warning'>Szablonu mapy '[map]' nie udało się poprawnie sparsować.</span>")
		return

	var/datum/map_report/report = M.cached_map.check_for_errors()
	var/report_link
	if(report)
		report.show_to(src)
		report_link = " - <a href='byond://?src=[REF(report)];[HrefToken(TRUE)];show=1'>raport walidacji</a>"
		to_chat(src, "<span class='warning'>Szablon mapy '[map]' <a href='byond://?src=[REF(report)];[HrefToken()];show=1'>nie przeszedł walidacji</a>.</span>")
		if(report.loadable)
			var/response = i18n_alert(usr, src, "Mapa nie przeszła walidacji. Czy mimo to chcesz ją wczytać?", "Błędy mapy", "Anuluj", "Wgraj mimo to") // AQ EDIT - i18n okienka
			if(response != "Wgraj mimo to")
				return
		else
			i18n_alert(usr, src, "Mapa nie przeszła walidacji i nie można jej wczytać.", "Błędy mapy", "No trudno") // AQ EDIT - i18n okienka
			return
	switch(type)
		if("Normal")
			SSmapping.map_templates[M.name] = M
		if("Shuttle")
			var/datum/map_template/shuttle/S = M
			SSmapping.shuttle_templates[S.shuttle_id] = S
	message_admins("<span class='adminnotice'>[key_name_admin(src)] wgrywa szablon mapy ([type == "Shuttle" ? "prom" : "zwykła"]) '[map]' ([M.width]x[M.height])[report_link].</span>")
	to_chat(src, "<span class='notice'>Szablon mapy '[map]' gotowy do postawienia ([M.width]x[M.height])</span>")
