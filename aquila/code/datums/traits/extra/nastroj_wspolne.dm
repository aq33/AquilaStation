// Cechy z grupy „nastrój” (porty z tg, Monkestation, Skyrata, Goona i Tau Ceti): wspólne definicje, wykluczenia i pomocnicze procedury.
// Ten plik musi być dołączony przed pozostałymi plikami nastroj_*.dm.

#ifndef TRAIT_GAMER
#define TRAIT_GAMER "gamer"
#endif
#ifndef TRAIT_CLOWN_ENJOYER
#define TRAIT_CLOWN_ENJOYER "clown_enjoyer"
#endif
#ifndef TRAIT_MIME_FAN
#define TRAIT_MIME_FAN "mime_fan"
#endif
#ifndef TRAIT_POSTERBOY
#define TRAIT_POSTERBOY "poster_boy"
#endif
#ifndef TRAIT_CURSED
#define TRAIT_CURSED "cursed"
#endif
#ifndef TRAIT_EVIL
#define TRAIT_EVIL "evil"
#endif
#ifndef TRAIT_BADTOUCH
#define TRAIT_BADTOUCH "bad_touch"
#endif
#ifndef TRAIT_SNOB
#define TRAIT_SNOB "snob"
#endif
#ifndef TRAIT_EXTROVERT
#define TRAIT_EXTROVERT "extrovert"
#endif
#ifndef TRAIT_INTROVERT
#define TRAIT_INTROVERT "introvert"
#endif
#ifndef TRAIT_NERVOUS
#define TRAIT_NERVOUS "nervous"
#endif

/// Wygrana w grze na automacie: ()
#ifndef COMSIG_MOB_WON_VIDEOGAME
#define COMSIG_MOB_WON_VIDEOGAME "mob_won_videogame"
#endif
/// Przegrana w grze na automacie: ()
#ifndef COMSIG_MOB_LOST_VIDEOGAME
#define COMSIG_MOB_LOST_VIDEOGAME "mob_lost_videogame"
#endif
/// Ruch w grze na automacie: ()
#ifndef COMSIG_MOB_PLAYED_VIDEOGAME
#define COMSIG_MOB_PLAYED_VIDEOGAME "mob_played_videogame"
#endif
/// Węglowiec poślizgnął się i przewrócił: ()
#ifndef COMSIG_ON_CARBON_SLIP
#define COMSIG_ON_CARBON_SLIP "carbon_slip"
#endif

/// Pary i grupy cech, których nie da się wybrać razem (jak quirk_blacklist w tg)
/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	. = ..()
	var/list/exclusive_groups = list(
		list(/datum/quirk/gamer, /datum/quirk/no_taste, /datum/quirk/vegetarian, /datum/quirk/deviant_tastes),
		list(/datum/quirk/gamer, /datum/quirk/pineapple_liker, /datum/quirk/pineapple_hater),
		list(/datum/quirk/clown_enjoyer, /datum/quirk/mime_fan),
		list(/datum/quirk/prosthetic_limb, /datum/quirk/body_purist),
		list(/datum/quirk/transhumanist, /datum/quirk/body_purist),
		list(/datum/quirk/empath, /datum/quirk/evil),
		list(/datum/quirk/extrovert, /datum/quirk/introvert),
		list(/datum/quirk/pyromania, /datum/quirk/pyrophobia),
		list(/datum/quirk/all_nighter, /datum/quirk/heavy_sleeper),
	)
	for(var/list/group as anything in exclusive_groups)
		var/list/names = list()
		for(var/datum/quirk/quirk_type as anything in group)
			names += initial(quirk_type.name)
		quirk_blacklist += list(names)

/// Daje przedmiot z cechy: do plecaka, kieszeni albo ręki. Zwraca, gdzie trafił.
/datum/quirk/proc/aq_nastroj_give_item(obj/item/item)
	var/mob/living/carbon/human/holder = quirk_holder
	if(!istype(holder))
		return "pod twoimi stopami"
	var/static/list/slots = list(
		"w twoim plecaku" = ITEM_SLOT_BACKPACK,
		"w twojej lewej kieszeni" = ITEM_SLOT_LPOCKET,
		"w twojej prawej kieszeni" = ITEM_SLOT_RPOCKET,
	)
	var/where = holder.equip_in_one_of_slots(item, slots, FALSE)
	if(where)
		return where
	if(holder.put_in_hands(item))
		return "w twojej ręce"
	return "pod twoimi stopami"

/// Liczy otwarte płomienie w zasięgu wzroku (tg: /atom/proc/count_nearby_fire_sources, bez wag)
/proc/aq_count_nearby_fire_sources(atom/center, radius = 5)
	var/fire_size = 0
	for(var/atom/movable/thing in view(radius, center))
		if(isliving(thing))
			var/mob/living/burning_mob = thing
			if(burning_mob.on_fire)
				fire_size++
			continue
		if(istype(thing, /obj/structure/bonfire))
			var/obj/structure/bonfire/bonfire = thing
			if(bonfire.burning)
				fire_size++
		else if(istype(thing, /obj/structure/fireplace))
			var/obj/structure/fireplace/fireplace = thing
			if(fireplace.lit)
				fire_size++
		else if(istype(thing, /obj/item/flashlight/flare))
			var/obj/item/flashlight/flare/flare = thing
			if(flare.on)
				fire_size++
		else if(istype(thing, /obj/item/match))
			var/obj/item/match/match = thing
			if(match.lit)
				fire_size++
		else if(istype(thing, /obj/item/lighter))
			var/obj/item/lighter/lighter = thing
			if(lighter.lit)
				fire_size++
		else if(istype(thing, /obj/effect/hotspot))
			fire_size++
		else if(isobj(thing))
			var/obj/burning_obj = thing
			if(burning_obj.resistance_flags & ON_FIRE)
				fire_size++
	return fire_size
