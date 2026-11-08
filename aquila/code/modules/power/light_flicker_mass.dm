/**
 * Migotanie lamp na całym statku (przeciążony reaktor) bez skoku w jednym ticku.
 *
 * Wcześniej pętla po całym GLOB.machines i start migotania każdej lampy szły w `process()` reaktora,
 * więc setki `update()` lamp wpadały w ten sam tick. Tu pętla ustępuje przez CHECK_TICK
 * (jak `propagate_light_flicker` w tgstation/tgstation#92503), a wywołujący nie czeka.
 *
 * * source - reaktor; migoczą lampy z tego samego statku (overmapy)
 * * chance - szansa (w %) na migotanie pojedynczej lampy
 * * candidates - lista przeszukiwana w poszukiwaniu lamp (domyślnie wszystkie maszyny; test podaje własną)
 */
/proc/aq_flicker_ship_lights(atom/source, chance, list/candidates = GLOB.machines)
	set waitfor = FALSE
	if(QDELETED(source))
		return
	var/source_overmap = source.get_overmap()
	// Reaktor poza statkiem: lampy bez overmapy też dają null, więc bez tego migotałyby wszystkie lampy poza statkami
	if(!source_overmap)
		return
	for(var/obj/machinery/light/light in candidates)
		if(QDELETED(light))
			continue
		if(prob(chance) && light.get_overmap() == source_overmap)
			light.flicker()
		CHECK_TICK
