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
