// AQUILA - lampa UV (Polaris i Baystation12 code/modules/detectivework/tools/uvlight.dm, sprite z Polarisa).
// Włączona co sekundę ujawnia w promieniu 3 kratek zmytą krew na podłodze i przedmiotach, ale tylko na chwilę:
// ślady gasną zaraz po odejściu lampy. Luminol zostaje do oprysku miejsca zbrodni, ludzi i ubrań (świeci 60 s),
// a lampa do przeczesania korytarza. Oba wołają to samo ujawnianie, lampa nie skraca świecenia po luminolu.

#define UV_LIGHT_RANGE 3
#define UV_REVEAL_TIME (2 SECONDS)

/obj/item/aq_uv_light
	name = "lampa UV"
	desc = "Latarka ultrafioletowa. W jej świetle widać zmytą krew w promieniu kilku kroków."
	icon = 'aquila/icons/obj/detective/uv_light.dmi'
	icon_state = "uv_off"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	light_color = "#7f3fff"
	custom_materials = list(/datum/material/iron = 200, /datum/material/glass = 200)
	var/on = FALSE

/obj/item/aq_uv_light/attack_self(mob/user)
	toggle(user)

/obj/item/aq_uv_light/proc/toggle(mob/user)
	on = !on
	icon_state = on ? "uv_on" : "uv_off"
	set_light(on ? UV_LIGHT_RANGE : 0, 2)
	playsound(src, 'sound/weapons/empty.ogg', 20, TRUE)
	if(on)
		START_PROCESSING(SSobj, src)
		uv_scan()
	else
		STOP_PROCESSING(SSobj, src)
	if(user)
		to_chat(user, "<span class='notice'>[on ? "Włączasz" : "Wyłączasz"] [src].</span>")

/obj/item/aq_uv_light/dropped(mob/user)
	. = ..()
	if(on && isturf(loc)) // rzucona na ziemię gaśnie
		toggle()

/obj/item/aq_uv_light/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/aq_uv_light/process(delta_time)
	if(!on)
		return PROCESS_KILL
	uv_scan()

/// Ujawnia ślady w zasięgu. Zwraca liczbę ujawnionych (test)
/obj/item/aq_uv_light/proc/uv_scan()
	. = 0
	var/turf/center = get_turf(src)
	if(!center)
		return
	for(var/turf/T in view(UV_LIGHT_RANGE, center))
		for(var/obj/effect/blood_trace/trace in T)
			if(length(trace.return_latent_blood_DNA()))
				trace.reveal(UV_REVEAL_TIME)
				.++
		for(var/obj/item/I in T)
			if(I.luminol_act(UV_REVEAL_TIME))
				.++

#undef UV_LIGHT_RANGE
#undef UV_REVEAL_TIME
