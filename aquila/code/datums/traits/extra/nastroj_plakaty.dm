// Plakaciarz (tg): pudełko własnoręcznie zrobionych plakatów, które poprawiają nastrój każdemu, kto je zobaczy.
// Uproszczenie: wszystkie plakaty są dla całej załogi (tg ma też plakaty działowe z osobnymi sprite'ami),
// wygląd losowany z oficjalnych plakatów.

#define AQ_POSTER_MOOD_CAT "poster_mood"

/datum/quirk/poster_boy
	name = "Plakaciarz"
	desc = "Masz kilka świetnych plakatów! Rozwieś je, a wszyscy będą mieli lepszy humor."
	icon = "tape"
	value = 1
	mob_trait = TRAIT_POSTERBOY
	medical_record_text = "Pacjent zgłasza chęć oklejania ścian przedmiotami własnej roboty."

/datum/quirk/poster_boy/on_spawn()
	aq_nastroj_give_item(new /obj/item/storage/box/posterbox(get_turf(quirk_holder)))

/obj/item/storage/box/posterbox
	name = "pudełko plakatów"
	desc = "Zrobiłeś je sam!"

/obj/item/storage/box/posterbox/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/poster/quirk(src)

/obj/item/poster/quirk
	name = "plakat domowej roboty"
	poster_type = /obj/structure/sign/poster/quirk
	icon_state = "rolled_legit"

/obj/structure/sign/poster/quirk
	name = "plakat domowej roboty"
	desc = "Duży kawałek domowej roboty, kosmoodpornego zadrukowanego papieru."
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/official
	/// Kto zobaczy plakat w tym zasięgu, dostaje nastrój
	var/datum/proximity_monitor/mood_monitor

/obj/structure/sign/poster/quirk/Initialize(mapload)
	. = ..()
	poster_item_name = "plakat domowej roboty"
	poster_item_desc = "Plakat zrobiony z miłością. Niektórzy ucieszą się na jego widok."
	poster_item_icon_state = "rolled_legit"
	mood_monitor = new(src, 7, TRUE)

/obj/structure/sign/poster/quirk/Destroy()
	QDEL_NULL(mood_monitor)
	return ..()

/obj/structure/sign/poster/quirk/HasProximity(atom/movable/AM)
	if(isliving(AM) && isturf(loc))
		on_seen(AM)

/obj/structure/sign/poster/quirk/examine(mob/user)
	. = ..()
	if(isliving(user) && isturf(loc))
		on_seen(user)

/// Ktoś zobaczył powieszony plakat
/obj/structure/sign/poster/quirk/proc/on_seen(mob/living/viewer)
	if(ruined || !viewer.mind || viewer.stat >= UNCONSCIOUS || is_blind(viewer))
		return
	if(!can_see(viewer, src, 7))
		return
	var/datum/component/mood/mood = viewer.GetComponent(/datum/component/mood)
	if(!mood || mood.has_mood_of_category(AQ_POSTER_MOOD_CAT))
		return
	to_chat(viewer, "<span class='notice'>Ale świetny plakat!</span>")
	SEND_SIGNAL(viewer, COMSIG_ADD_MOOD_EVENT, AQ_POSTER_MOOD_CAT, /datum/mood_event/poster_mood)

/datum/mood_event/poster_mood
	description = "<span class='nicegreen'>Ten plakat naprawdę mnie motywuje!</span>\n"
	mood_change = 2
	timeout = 5 MINUTES

#undef AQ_POSTER_MOOD_CAT
