/**
 * Migotanie lamp na całym statku (przeciążony reaktor) bez skoku w jednym ticku.
 *
 * Wcześniej pętla po całym GLOB.machines i start migotania każdej lampy szły w `process()` reaktora,
 * więc setki `update()` lamp wpadały w ten sam tick. Tu pętla ustępuje przez CHECK_TICK
 * (jak `propagate_light_flicker` w tgstation/tgstation#92503), a wywołujący nie czeka.
 *
 * * source - reaktor; migoczą lampy z tego samego statku (overmapy)
 * * chance - szansa (w %) na migotanie pojedynczej lampy
 */
/proc/aq_flicker_ship_lights(atom/source, chance)
	set waitfor = FALSE
	if(QDELETED(source))
		return
	var/source_overmap = source.get_overmap()
	for(var/obj/machinery/light/light in GLOB.machines)
		if(QDELETED(light))
			continue
		if(prob(chance) && light.get_overmap() == source_overmap)
			light.flicker()
		CHECK_TICK
