// Składniki widoczne przez szybkę mikrofali rysowały się jako czarne sylwetki (zgłoszone przy pierogach).
// update_overlays() kopiuje cały wygląd składnika image(ingredient) i kładzie go z BLEND_INSET_OVERLAY. Każdy przedmiot ma
// w nakładkach czarny bloker emisji (EMISSIVE_BLOCK_GENERIC w atoms_movable.dm), który normalnie leży na EMISSIVE_PLANE,
// ale w nakładce typu inset płaszczyzny się spłaszczają i bloker zakrywał składnik. Zdejmujemy go z kopii.
/obj/machinery/microwave/update_overlays()
	. = ..()
	for(var/image/ingredient_overlay in .)
		if(ingredient_overlay.blend_mode != BLEND_INSET_OVERLAY)
			continue
		var/list/kept = list()
		for(var/image/sub_overlay as anything in ingredient_overlay.overlays)
			if(sub_overlay.plane != EMISSIVE_PLANE)
				kept += sub_overlay
		if(length(kept) != length(ingredient_overlay.overlays))
			ingredient_overlay.overlays = kept

	// Grafika mikrofali z tg: w czasie pracy animowana ramka "mw1" zamiast "mw" i świecące elementy ramki (emissive_*).
	var/list/new_overlays = .
	if(!length(new_overlays))
		return
	var/border_index = new_overlays.Find("mw")
	if(operating && border_index)
		new_overlays[border_index] = "mw1"
	if(machine_stat & NOPOWER)
		return
	for(var/border_state in list("mw1", "mw", "mwo"))
		if(border_state in new_overlays)
			new_overlays += emissive_appearance(icon, "emissive_[border_state]")
			break
