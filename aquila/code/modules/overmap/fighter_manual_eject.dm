// Ręczna katapulta myśliwca: przełączniki L i P na panelu konsoli (ship_console_hud.dm).

/// Czy pilot może się teraz katapultować z panelu. Pisze graczowi, dlaczego nie.
/obj/structure/overmap/small_craft/proc/aquila_can_manual_eject(mob/living/user)
	if(user != pilot)
		return FALSE
	if(istype(src, /obj/structure/overmap/small_craft/escapepod))
		to_chat(user, "<span class='warning'>Siedzisz już w kapsule ratunkowej.</span>")
		return FALSE
	if(!ispath(escape_pod_type))
		to_chat(user, "<span class='warning'>[src] nie ma kapsuły ratunkowej. Katapulta nie zadziała.</span>")
		return FALSE
	if(SSmapping.level_trait(z, ZTRAIT_BOARDABLE) || SSmapping.level_trait(z, ZTRAIT_RESERVED))
		to_chat(user, "<span class='warning'>Jesteś na pokładzie statku. Otwórz osłonę kokpitu i wysiądź normalnie.</span>")
		return FALSE
	return TRUE

/// Wystrzeliwuje kapsułę ratunkową z załogą, myśliwiec zostaje w kosmosie z włączonym hamulcem.
/// Kolejność jak przy zniszczeniu myśliwca (Destroy): najpierw wszyscy schodzą ze stanowisk, potem kapsuła ich zabiera.
/obj/structure/overmap/small_craft/proc/aquila_manual_eject(mob/living/user)
	var/mob/last_pilot = pilot
	for(var/mob/M as anything in operators)
		stop_piloting(M, eject_mob = FALSE)
	var/obj/structure/overmap/small_craft/escapepod/pod = create_escape_pod(escape_pod_type, last_pilot, TRUE)
	if(!pod)
		return FALSE
	brakes = TRUE
	log_game("[key_name(last_pilot)] katapultował się ręcznie z [src] [AREACOORD(src)]")
	return TRUE
