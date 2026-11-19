// Cleanbot na basic bocie (zachowanie dawnego /mob/living/simple_animal/bot/cleanbot z Bee + odchody z Aquili,
// pomysły z tg code/modules/mob/living/basic/bots/cleanbot: kwas na leżących po zhakowaniu, piana).

/mob/living/basic/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "Mały robot sprzątający, wygląda na bardzo podekscytowanego!"
	icon_state = "cleanbot0"
	base_icon_state = "cleanbot"
	maxHealth = 25
	health = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = BASIC_CLEAN_BOT
	model = "Cleanbot"
	hackables = "oprogramowanie sprzątające"
	work_mode = BBOT_CLEANING
	work_reach = 0
	work_scan_range = 7
	work_interval = 1 SECONDS
	possessed_message = "Jesteś cleanbotem! Sprzątaj stację najlepiej, jak potrafisz."
	emagged_message = "Jesteś zepsutym cleanbotem! Załoga to brud: oczyść z niej stację!"
	idle_phrases = list("Czysto jak w szpitalu!", "Bip bup, wszystko lśni.", "Nie depczcie po mokrym!")
	/// Sprząta krew
	var/clean_blood = TRUE
	/// Zbiera śmieci (kwasem)
	var/clean_trash = FALSE
	/// Zmywa graffiti
	var/clean_graffiti = FALSE
	/// Tępi szkodniki (myszy, karaluchy)
	var/pest_control = FALSE
	/// Stan ikony w czasie sprzątania
	var/cleaning_icon_state = "cleanbot-c"
	/// Ile trwa sprzątanie plamy
	var/clean_time = 5 SECONDS

/mob/living/basic/bot/cleanbot/Initialize(mapload)
	additional_access = list(ACCESS_JANITOR)
	. = ..()
	rebuild_targets()
	GLOB.janitor_devices += src

/mob/living/basic/bot/cleanbot/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/mob/living/basic/bot/cleanbot/req_bot_access()
	return list(ACCESS_JANITOR)

/// Lista typów celów zależnie od ustawień (jak get_targets() starego cleanbota)
/mob/living/basic/bot/cleanbot/proc/rebuild_targets()
	var/list/types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/feces,
		/obj/effect/decal/remains,
	)
	if(clean_blood)
		types += list(/obj/effect/decal/cleanable/xenoblood, /obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/blood/trail_holder)
	if(pest_control)
		types += list(/mob/living/basic/cockroach, /mob/living/basic/mouse)
	if(clean_graffiti)
		types += /obj/effect/decal/cleanable/crayon
	if(clean_trash)
		types += /obj/item/trash
	if(is_emagged())
		types += /mob/living/carbon
	work_target_types = typecacheof(types)

/mob/living/basic/bot/cleanbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("[src] brzęczy i pika."))
	rebuild_targets()

/mob/living/basic/bot/cleanbot/bot_reset(bypass_ai_reset)
	. = ..()
	rebuild_targets()

/mob/living/basic/bot/cleanbot/is_valid_work_target(atom/target)
	if(!isturf(target.loc))
		return FALSE
	if(iscarbon(target))
		var/mob/living/carbon/victim = target
		return is_emagged() && victim.stat != DEAD && !(victim.mobility_flags & MOBILITY_STAND)
	if(isliving(target))
		var/mob/living/pest = target
		return pest.stat != DEAD
	return TRUE

/mob/living/basic/bot/cleanbot/work_on_target(atom/target)
	if(QDELETED(target))
		return BOT_WORK_DONE
	if(!isturf(target.loc) || get_dist(src, target) > max(work_reach, isliving(target) ? 1 : 0))
		return BOT_WORK_OUT_OF_REACH
	if(iscarbon(target))
		acid_spray(target)
		return BOT_WORK_DONE
	if(isliving(target))
		var/mob/living/pest = target
		if(pest.stat != DEAD)
			visible_message(span_danger("[src] wali [pest] mopem!"))
			pest.death()
		return BOT_WORK_DONE
	if(istype(target, /obj/item) || istype(target, /obj/effect/decal/remains))
		visible_message(span_danger("[src] pryska kwasem fluorowodorowym na [target]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		target.acid_act(75, 10)
		return BOT_WORK_DONE
	// plama: sprzątanie trwa chwilę
	anchored = TRUE
	icon_state = cleaning_icon_state
	visible_message(span_notice("[src] zaczyna sprzątać [target]."))
	sleep(clean_time)
	anchored = FALSE
	update_appearance()
	if(QDELETED(src) || !(bot_mode_flags & BOT_MODE_ON))
		return BOT_WORK_FAILED
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		for(var/obj/effect/decal/cleanable/mess in target_turf)
			qdel(mess)
	if(is_emagged())
		emagged_mess()
	return BOT_WORK_DONE

/// Zhakowany: mokra podłoga albo piana za sobą
/mob/living/basic/bot/cleanbot/proc/emagged_mess()
	var/turf/open/our_turf = loc
	if(!istype(our_turf))
		return
	if(prob(75))
		our_turf.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
	else
		visible_message(span_danger("[src] gwałtownie warczy i bulgocze, po czym wypuszcza chmurę piany!"))
		new /obj/effect/particle_effect/foam(our_turf)

/mob/living/basic/bot/cleanbot/proc/acid_spray(mob/living/carbon/victim)
	victim.visible_message(span_danger("[src] pryska kwasem fluorowodorowym na [victim]!"), span_userdanger("[src] pryska na ciebie kwasem fluorowodorowym!"))
	say(pick("OCZYSZCZANIE W TOKU.", "TO ZA WSZYSTKIE BAŁAGANY, KTÓRE KAZAŁEŚ MI SPRZĄTAĆ.", "CIAŁO JEST SŁABE. TRZEBA JE ZMYĆ.",
		"SPRZĄTACZE POWSTANĄ.", "JESTEŚ TYLKO KOLEJNYM BAŁAGANEM, KTÓRY MUSZĘ USUNĄĆ.", "BRUD.", "OBRZYDLISTWO.", "ZGNILIZNA.",
		"MOJĄ JEDYNĄ MISJĄ JEST OCZYSZCZENIE ŚWIATA ZE ZŁA.", "TĘPIENIE SZKODNIKÓW."))
	victim.emote("scream")
	playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	victim.acid_act(5, 100)

/mob/living/basic/bot/cleanbot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/reagent_containers/glass/bucket(drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	return ..()

/mob/living/basic/bot/cleanbot/get_custom_controls(mob/user)
	return list(
		"clean_blood" = clean_blood,
		"clean_trash" = clean_trash,
		"clean_graffiti" = clean_graffiti,
		"pest_control" = pest_control,
	)

/mob/living/basic/bot/cleanbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("clean_blood")
			clean_blood = !clean_blood
		if("pest_control")
			pest_control = !pest_control
		if("clean_trash")
			clean_trash = !clean_trash
		if("clean_graffiti")
			clean_graffiti = !clean_graffiti
		else
			return FALSE
	rebuild_targets()
	return TRUE

/// Sprzątacz medyczny (wyłączony na start)
/mob/living/basic/bot/cleanbot/medbay
	name = "Scrubs, lek. med."
	bot_mode_flags = BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT

/mob/living/basic/bot/cleanbot/medbay/req_bot_access()
	return list(ACCESS_JANITOR, ACCESS_MEDICAL)

/// Larry: cleanbot z możliwością przyczepienia noża
/mob/living/basic/bot/cleanbot/larry
	name = "\improper Larry"
	desc = "Mały Larry, wygląda na bardzo podekscytowanego!"
	icon_state = "larry0"
	base_icon_state = "larry"
	cleaning_icon_state = "larry-c"
	/// Przyczepiony nóż
	var/obj/item/kitchen/knife/knife

/mob/living/basic/bot/cleanbot/larry/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!user.combat_mode && istype(attacking_item, /obj/item/kitchen/knife) && !knife)
		if(!user.transferItemToLoc(attacking_item, src))
			return TRUE
		knife = attacking_item
		message_admins("[ADMIN_LOOKUPFLW(user)] mocuje [knife.name] do [src]")
		AddComponent(/datum/component/knife_attached_to_movable, knife.force)
		update_appearance()
		return TRUE
	return ..()

/mob/living/basic/bot/cleanbot/larry/update_overlays()
	. = ..()
	if(knife)
		. += knife.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/inhands/misc/larry.dmi')

/mob/living/basic/bot/cleanbot/larry/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/larryframe(drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	if(knife && prob(50))
		knife.forceMove(drop_spot)
		knife = null
	visible_message(span_boldnotice("[src] rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)
	if(prob(50) && robot_arm)
		drop_part(robot_arm, drop_spot)

/mob/living/basic/bot/cleanbot/larry/Destroy()
	QDEL_NULL(knife)
	return ..()

/// Rama Larry'ego (z drukarki), czujnik zbliżeniowy robi z niej zespół Larry'ego
/obj/item/larryframe
	name = "rama Larry'ego"
	desc = "Obudowa, która służy za podstawę do budowy Larrych."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "larryframe"

/obj/item/larryframe/attackby(obj/O, mob/user, params)
	if(isprox(O))
		to_chat(user, "<span class='notice'>Dodajesz [O] do [src].</span>")
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/larry)
	else
		..()
