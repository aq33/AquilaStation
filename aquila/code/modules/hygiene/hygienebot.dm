// AQUILA - Hygienebot, ported from tgstation (#49613, constructible since #55089) and hooked into NSV13's hygiene.
// It hunts down people who stink or wear bloody clothes and hoses them down until they are clean.
// Od części BOTY to basic bot na drzewie zachowań (aquila/code/modules/mob/living/basic/bots/), pościg przez wspólny schemat pracy.

/mob/living/basic/bot/hygienebot
	name = "\improper Hygienebot"
	desc = "Latający robot sprzątający. Ściga każdego, kto nie umie porządnie się umyć!"
	icon = 'aquila/icons/mob/hygienebot.dmi'
	icon_state = "hygienebot"
	maxHealth = 100
	health = 100
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Hygienebot"
	hackables = "pompa wody"
	layer = ABOVE_MOB_LAYER
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED
	work_mode = BBOT_CLEANING
	work_reach = 0
	work_interval = 2 SECONDS
	speed = 2
	possessed_message = "Jesteś hygienebotem! Myj każdego, kto śmierdzi."
	emagged_message = "Jesteś zepsutym hygienebotem! Twoja woda to ogień."
	/// Czy bot spryskuje swój kafelek (wodą albo ogniem)
	var/washing = FALSE
	/// Cel ucieka dość długo, żeby bot klął
	var/frustration = 0
	/// Imię poprzedniego celu i kiedy go znalazł
	var/oldtarget_name
	var/last_found = 0

/mob/living/basic/bot/hygienebot/Initialize(mapload)
	additional_access = list(ACCESS_JANITOR)
	. = ..()

/mob/living/basic/bot/hygienebot/req_bot_access()
	return list(ACCESS_JANITOR)

/mob/living/basic/bot/hygienebot/update_icon_state()
	. = ..()
	icon_state = (bot_mode_flags & BOT_MODE_ON) ? "hygienebot-on" : "hygienebot"

/mob/living/basic/bot/hygienebot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "hygienebot-flame")
	if(washing)
		. += mutable_appearance(icon, is_emagged() ? "hygienebot-fire" : "hygienebot-water")

/mob/living/basic/bot/hygienebot/explode()
	visible_message(span_boldnotice("[src] rozpada się w pianowym wybuchu!"))
	new /obj/effect/particle_effect/foam(loc)
	return ..()

/mob/living/basic/bot/hygienebot/bot_reset(bypass_ai_reset)
	. = ..()
	frustration = 0
	stop_washing()

/mob/living/basic/bot/hygienebot/is_valid_work_target(atom/target)
	if(!ishuman(target))
		return FALSE
	if(target.name == oldtarget_name && world.time < last_found + 10 SECONDS)
		return FALSE
	return needs_washing(target)

/mob/living/basic/bot/hygienebot/on_work_target_found(atom/target)
	oldtarget_name = target.name
	frustration = 0
	speak("Wykryto niehigienicznego klienta. Proszę stać spokojnie, zaraz cię umyję.")
	playsound(loc, 'aquila/sound/effects/hygienebot_happy.ogg', 60, TRUE)
	visible_message("<b>[src]</b> wskazuje na [target.name]!")
	update_bot_mode(BBOT_HUNT)

/mob/living/basic/bot/hygienebot/work_on_target(atom/target)
	var/mob/living/carbon/human/dirty = target
	if(!istype(dirty) || is_clean(dirty))
		if(istype(dirty))
			speak("Miłego, czystego dnia!")
			playsound(loc, 'aquila/sound/effects/hygienebot_happy.ogg', 60, TRUE)
		last_found = world.time
		stop_washing()
		return BOT_WORK_DONE
	if(dirty.loc != loc || !isturf(dirty.loc))
		stop_washing()
		frustration++
		return BOT_WORK_OUT_OF_REACH
	if(frustration >= 5)
		speak(pick("No, kurwa, nareszcie.", "Wreszcie, dzięki Bogu.", "Nareszcie się zatrzymałeś, brudasie."))
		playsound(loc, 'aquila/sound/effects/hygienebot_angry.ogg', 60, TRUE)
		frustration = 0
	start_washing()
	wash_tile()
	return BOT_WORK_CONTINUE

/// Spryskuje swój kafelek i wszystko na nim
/mob/living/basic/bot/hygienebot/proc/wash_tile()
	do_wash(loc)
	for(var/atom/movable/thing in loc)
		if(thing != src)
			do_wash(thing)
	if(isopenturf(loc) && !is_emagged())
		var/turf/open/tile = loc
		tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

/// Ściga uciekającego: zhakowany pali po drodze, a długi pościg kończy się wyzwiskami
/mob/living/basic/bot/hygienebot/Life(seconds, times_fired)
	. = ..()
	var/mob/living/carbon/human/dirty = ai_controller?.blackboard[BB_BOT_WORK_TARGET]
	if(stat || !istype(dirty) || dirty.loc == loc)
		return
	if(is_emagged())
		start_washing()
		wash_tile()
		return
	frustration++
	if(frustration >= 5 && prob(min(frustration * 2, 60)))
		playsound(loc, 'aquila/sound/effects/hygienebot_angry.ogg', 60, TRUE)
		speak(pick("Wracaj tu, ty śmierdzący gnoju!", "STÓJ ALBO PRZETNĘ CI TĘTNICE!", "Daj się, kurwa, umyć, dupku!", "STÓJ. NIE. UCIEKAJ.", "Albo się zatrzymasz, albo wywlekę cię przez śluzę.", "Chcę cię tylko, kurwa, umyć, troglodyto.", "Jak nie wrócisz, to otoczę cię zieloną chmurą."))
	if(frustration > 50)
		bot_reset()

/mob/living/basic/bot/hygienebot/proc/start_washing()
	if(washing)
		return
	washing = TRUE
	update_appearance()

/mob/living/basic/bot/hygienebot/proc/stop_washing()
	if(!washing)
		return
	washing = FALSE
	update_appearance()

/// Whether the bot should go after this person
/mob/living/basic/bot/hygienebot/proc/needs_washing(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return FALSE
	if(is_emagged())
		return TRUE
	if(H.hygiene <= HYGIENE_LEVEL_DIRTY && !HAS_TRAIT(H, TRAIT_ALWAYS_CLEAN))
		return TRUE
	return has_bloody_clothes(H)

/// Whether the bot is done with this person. Stricter than needs_washing(), so a target is washed back up to normal
/mob/living/basic/bot/hygienebot/proc/is_clean(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return TRUE
	if(is_emagged())
		return FALSE
	if(H.hygiene < HYGIENE_LEVEL_NORMAL && !HAS_TRAIT(H, TRAIT_ALWAYS_CLEAN))
		return FALSE
	return !has_bloody_clothes(H)

/mob/living/basic/bot/hygienebot/proc/has_bloody_clothes(mob/living/carbon/human/H)
	for(var/slot in list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_FEET))
		var/obj/item/I = H.get_item_by_slot(slot)
		if(I && HAS_BLOOD_DNA(I))
			return TRUE
	return FALSE

/mob/living/basic/bot/hygienebot/proc/do_wash(atom/A)
	if(is_emagged())
		A.fire_act()
		return
	SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	A.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	if(isturf(A))
		for(var/obj/effect/E in A)
			if(is_cleanable(E))
				qdel(E)
		return
	if(!iscarbon(A))
		return
	var/mob/living/carbon/C = A
	C.wash_cream()
	var/cleaned_items = FALSE
	for(var/obj/item/I in C.get_equipped_items(TRUE) + C.held_items)
		if(SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
			cleaned_items = TRUE
	if(cleaned_items)
		C.regenerate_icons()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.adjust_hygiene(HYGIENEBOT_WASH_AMOUNT)

// Construction: 2 metal sheets -> weld a water hole -> proximity sensor -> 1 fluid duct
/obj/item/bot_assembly/hygienebot
	name = "niedokończony hygienebot"
	desc = "Koniec z bagnem raz na zawsze."
	icon = 'aquila/icons/mob/hygienebot.dmi'
	icon_state = "hygienebot"
	created_name = "Hygienebot"

/obj/item/bot_assembly/hygienebot/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/atom/Tsec = drop_location()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(I.tool_behaviour == TOOL_WELDER)
				if(I.use_tool(src, user, 0, volume = 40))
					to_chat(user, "<span class='notice'>Wypalasz otwór na wodę w [src]!</span>")
					build_step++
				return
			if(I.tool_behaviour == TOOL_WRENCH)
				if(I.use_tool(src, user, 0, volume = 40))
					new /obj/item/stack/sheet/iron(Tsec, 2)
					to_chat(user, "<span class='notice'>Rozkręcasz [src].</span>")
					qdel(src)
				return

		if(ASSEMBLY_SECOND_STEP)
			if(isprox(I))
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				build_step++
				to_chat(user, "<span class='notice'>Dodajesz [I] do [src].</span>")
				qdel(I)
				return
			if(I.tool_behaviour == TOOL_WELDER)
				if(I.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Zaspawujesz otwór na wodę w [src].</span>")
					build_step--
				return

		if(ASSEMBLY_THIRD_STEP)
			if(istype(I, /obj/item/stack/ducts))
				if(istype(loc, /obj/item/storage/backpack))
					to_chat(user, "<span class='warning'>Najpierw wyjmij [src] z [loc]!</span>")
					return
				var/obj/item/stack/ducts/D = I
				to_chat(user, "<span class='notice'>Zaczynasz podłączać rurę do [src]...</span>")
				if(do_after(user, 4 SECONDS, target = src) && D.use(1))
					to_chat(user, "<span class='notice'>Podłączasz rurę do [src].</span>")
					var/mob/living/basic/bot/hygienebot/H = new(drop_location())
					H.name = created_name
					qdel(src)
				return
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				new /obj/item/assembly/prox_sensor(Tsec)
				to_chat(user, "<span class='notice'>Odłączasz czujnik zbliżeniowy od [src].</span>")
				build_step--
				return
