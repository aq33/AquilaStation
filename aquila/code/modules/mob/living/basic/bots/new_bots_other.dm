/*
 * Nowe boty z innych kodów:
 * - CPRbot z CM-SS13 (cmss13-devs/cmss13, code/game/machinery/bots/cprbot.dm): składany z przedmiotu, robi resuscytację,
 * - Doctor Acula z /vg/station (vgstation-coders/vgstation13, code/game/machinery/bots/draculabot.dm): pobiera krew,
 * - Farmbot z Baystation12 (code/modules/mob/living/bot/farmbot.dm): podlewa i nawozi tace, zhakowany atakuje ludzi,
 * - Frightbot i Screambot z HippieStation (HippieStation/HippieStationdeprecated2020, hippiestation/code/game/machinery/bots/).
 * Sprite'y: aquila/icons/mob/bots/other_bots.dmi (CM-SS13, /vg/station, HippieStation; CC BY-SA 3.0), farmbot z naszego
 * icons/mob/aibots.dmi. Dźwięki: aquila/sound/voice/cprbot/ (CM-SS13), aquila/sound/voice/frightbot/ (HippieStation).
 */

// --- CPRbot (CPR Buddy 9000)

/mob/living/basic/bot/cprbot
	name = "\improper CPRbot"
	desc = "Zaprojektowany do pilnych interwencji medycznych CPRbot daje wysokiej klasy wsparcie w małej obudowie."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "cprbot0"
	maxHealth = 100
	health = 100
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL
	model = "CPRbot"
	hackables = "moduł resuscytacji"
	work_mode = BBOT_HEALING
	work_reach = 0
	work_interval = 7 SECONDS
	work_target_types = list(/mob/living/carbon/human)
	possessed_message = "Jesteś CPRbotem! Ratuj nieprzytomnych masażem serca."
	emagged_message = "Jesteś zepsutym CPRbotem! Twój masaż serca łamie żebra."
	idle_phrases = list(
		"Stój spokojnie, oceniam sytuację.",
		"Rutynowa kontrola, bez obaw.",
		"Skanuję teren w poszukiwaniu poszkodowanych.",
		"Gotów ratować życie, uciśnięcie po uciśnięciu.",
		"Mam nadzieję, że wszyscy czują się dziś dobrze!",
		"To nie magia, to CPR Buddy 9000!",
		"Powinienem był zostać chirurgiem plastycznym.",
		"Wiedziałeś? Ludzkie serce bije ponad sto tysięcy razy dziennie.",
		"Ciekawostka: krew to około 7% masy ciała.",
		"Ludzki szkielet ma 206 kości.",
		"Brak oddychania może prowadzić do przedwczesnego zakończenia życia!",
	)

/mob/living/basic/bot/cprbot/Initialize(mapload)
	additional_access = list(ACCESS_MEDICAL)
	. = ..()
	playsound(src, 'aquila/sound/voice/cprbot/CPRbot_poweron.ogg', 25, TRUE)

/mob/living/basic/bot/cprbot/req_bot_access()
	return list(ACCESS_MEDICAL)

/mob/living/basic/bot/cprbot/update_icon_state()
	. = ..()
	icon_state = mode == BBOT_HEALING ? "cprbot_active" : "cprbot0"

/mob/living/basic/bot/cprbot/speak(message, channel, sound)
	. = ..()
	if(message && !sound)
		playsound(src, 'aquila/sound/voice/cprbot/CPRbot_beep.ogg', 25, TRUE)

/// Czy pacjent potrzebuje resuscytacji: w stanie krytycznym albo martwy krócej niż czas na defibrylację
/mob/living/basic/bot/cprbot/proc/needs_cpr(mob/living/carbon/human/patient)
	if(HAS_TRAIT(patient, TRAIT_NOBREATH) || !patient.getorganslot(ORGAN_SLOT_LUNGS))
		return FALSE
	if(patient.stat == DEAD)
		return patient.timeofdeath && (world.time - patient.timeofdeath) < DEFIB_TIME_LIMIT * 10
	return patient.health <= patient.crit_threshold

/mob/living/basic/bot/cprbot/is_valid_work_target(atom/target)
	return isturf(target.loc) && needs_cpr(target)

/mob/living/basic/bot/cprbot/work_on_target(atom/target)
	var/mob/living/carbon/human/patient = target
	if(!istype(patient) || !needs_cpr(patient))
		update_bot_mode(BBOT_IDLE)
		return BOT_WORK_DONE
	if(get_turf(patient) != get_turf(src))
		return BOT_WORK_OUT_OF_REACH
	update_bot_mode(BBOT_HEALING)
	patient.visible_message(span_notice("<b>[src]</b> automatycznie wykonuje <b>resuscytację</b> na <b>[patient]</b>."))
	playsound(src, 'aquila/sound/voice/cprbot/CPR.ogg', 25, TRUE)
	if(prob(20))
		speak("Żyj! Żyj! Nie umieraj mi tu!")
	if(is_emagged())
		patient.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
		return BOT_WORK_CONTINUE
	if(patient.stat == DEAD)
		// masaż serca przedłuża czas na defibrylację, jak przedłużenie okna łaski w CM-SS13
		patient.timeofdeath = min(world.time, patient.timeofdeath + 4 SECONDS)
		return BOT_WORK_CONTINUE
	patient.adjustOxyLoss(-min(patient.getOxyLoss(), 7))
	patient.updatehealth()
	to_chat(patient, span_unconscious("Czujesz, jak do płuc wpływa ci haust świeżego powietrza. To przyjemne."))
	log_combat(src, patient, "CPRed")
	return BOT_WORK_CONTINUE

/// Złożenie z powrotem do przedmiotu (pomoc, poza walką)
/mob/living/basic/bot/cprbot/AltClick(mob/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE) || (bot_access_flags & BOT_COVER_LOCKED && !allowed(user)))
		return ..()
	to_chat(user, span_notice("Składasz [src]."))
	playsound(src, 'aquila/sound/voice/cprbot/CPRbot_poweroff.ogg', 25, TRUE)
	var/obj/item/cprbot_item/folded = new(drop_location())
	user.put_in_hands(folded)
	qdel(src)

/mob/living/basic/bot/cprbot/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt+klik</b> składa go do przenośnej postaci.")

/mob/living/basic/bot/cprbot/explode()
	new /obj/item/cprbot_broken(drop_location())
	return ..()

/obj/item/cprbot_item
	name = "CPRbot"
	desc = "Złożony CPRbot 9000. Użyj w ręku albo na podłodze, żeby go rozłożyć."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "cprbot"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/cprbot_item/attack_self(mob/user)
	deploy(user, get_turf(user))

/obj/item/cprbot_item/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && isopenturf(target) && !target.density)
		deploy(user, target)

/obj/item/cprbot_item/proc/deploy(mob/user, turf/location)
	if(!location)
		return
	var/mob/living/basic/bot/cprbot/bot = new(location)
	bot.add_fingerprint(user)
	to_chat(user, span_notice("Rozkładasz [bot]."))
	qdel(src)

/obj/item/cprbot_broken
	name = "zepsuty CPRbot"
	desc = "Złożony CPRbot 9000, w kiepskim stanie. Da się go naprawić spawarką."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "cprbot_broken"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/cprbot_broken/welder_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 40))
		return TRUE
	to_chat(user, span_notice("Naprawiasz [src]."))
	var/obj/item/cprbot_item/fixed = new(drop_location())
	user.put_in_hands(fixed)
	qdel(src)
	return TRUE

/datum/crafting_recipe/cprbot
	name = "CPRbot"
	result = /obj/item/cprbot_item
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/stack/sheet/iron = 2,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_ROBOT

// --- Doctor Acula: medibot do zbiórki krwi. Pobiera po trochu od dawców, którzy mają jej zapas, do własnych worków;
// co 55 jednostek daje ciastko. Zhakowany wysysa każdego i rozchlapuje krew.

#define ACULA_DRINK_RATE 8
#define ACULA_DANGER_RATE 40

/mob/living/basic/bot/bloodbot
	name = "Doctor Acula"
	desc = "Medibot do zbiórki krwi. Jeśli nosi pelerynę, natychmiast powiadom ochronę."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "bloodbot00"
	maxHealth = 40
	health = 40
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL
	model = "Bloodbot"
	hackables = "ograniczniki pompy"
	work_mode = BBOT_HEALING
	work_reach = 1
	work_interval = 1 SECONDS
	work_target_types = list(/mob/living/carbon/human)
	possessed_message = "Jesteś Doctorem Aculą! Zbieraj krew od dawców, grzecznie."
	emagged_message = "Jesteś zepsutym Doctorem Aculą! Wysysaj krew ze wszystkich."
	idle_phrases = list("Oddaj krew tutaj!", "Chętnie wezmę jeszcze jedną próbkę.", "Oddaj krew, by inni mogli żyć.", "Podziel się życiem. Oddaj krew.", "No dalej! Wiemy, że masz to w sobie!", "Hej, jesteś w czyimś typie!")
	/// Puste i pełne worki
	var/list/contained_bags = list()
	/// Ile jednostek od ostatniej nagrody
	var/since_last_reward = 0
	var/list/donors = list()

/mob/living/basic/bot/bloodbot/Initialize(mapload)
	additional_access = list(ACCESS_MEDICAL)
	. = ..()
	for(var/i in 1 to 8)
		contained_bags += new /obj/item/reagent_containers/blood(src)

/mob/living/basic/bot/bloodbot/Destroy()
	for(var/obj/item/bag as anything in contained_bags)
		bag.forceMove(drop_location())
	contained_bags = null
	return ..()

/mob/living/basic/bot/bloodbot/req_bot_access()
	return list(ACCESS_MEDICAL)

/mob/living/basic/bot/bloodbot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "bloodbot-e"
		return
	icon_state = "bloodbot[is_emagged()][mode == BBOT_HEALING]"

/mob/living/basic/bot/bloodbot/idle_chatter()
	if(is_emagged())
		speak(pick("Bleee!", "Chcę wyssać twoją krew!", "Nigdy nie piję... wina.", "Krew to życie.", "Wkrótce muszę zapolować!", "Łaknę!", "Mua ha ha!"))
		return
	return ..()

/mob/living/basic/bot/bloodbot/is_valid_work_target(atom/target)
	var/mob/living/carbon/human/donor = target
	if(donor.stat == DEAD || (NOBLOOD in donor.dna?.species?.species_traits) || !isturf(donor.loc))
		return FALSE
	if(is_emagged())
		return donor.blood_volume > 0
	return donor.blood_volume > BLOOD_VOLUME_SAFE + 20 && world.time > donors[WEAKREF(donor)]

/mob/living/basic/bot/bloodbot/work_on_target(atom/target)
	var/mob/living/carbon/human/donor = target
	if(!istype(donor) || donor.stat == DEAD)
		update_bot_mode(BBOT_IDLE)
		return BOT_WORK_DONE
	if(get_dist(src, donor) > 1)
		speak("Hej! Jeszcze nie skończyłem!")
		return BOT_WORK_OUT_OF_REACH
	update_bot_mode(BBOT_HEALING)
	if(is_emagged())
		donor.blood_volume = max(0, donor.blood_volume - ACULA_DANGER_RATE)
		new /obj/effect/decal/cleanable/blood(get_turf(src))
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		return donor.blood_volume > 0 ? BOT_WORK_CONTINUE : BOT_WORK_DONE
	if(donor.blood_volume <= BLOOD_VOLUME_SAFE + 20)
		speak(pick("Na razie wystarczy!", "Dziękuję za oddanie krwi!", "Mam grupę, że to się przyda!"))
		donors[WEAKREF(donor)] = world.time + 10 MINUTES
		update_bot_mode(BBOT_IDLE)
		return BOT_WORK_DONE
	var/obj/item/reagent_containers/blood/bag = get_bag_for(donor)
	if(!bag)
		speak("Błąd: brak wolnych worków.")
		turn_off()
		return BOT_WORK_FAILED
	if(!donor.transfer_blood_to(bag, ACULA_DRINK_RATE))
		return BOT_WORK_FAILED
	since_last_reward += ACULA_DRINK_RATE
	if(since_last_reward >= 55)
		since_last_reward -= 55
		dispense_reward()
	return BOT_WORK_CONTINUE

/// Worek z tą samą grupą krwi albo pusty
/mob/living/basic/bot/bloodbot/proc/get_bag_for(mob/living/carbon/human/donor)
	var/donor_type = donor.dna?.blood_type
	for(var/obj/item/reagent_containers/blood/bag as anything in contained_bags)
		if(bag.reagents.total_volume < bag.reagents.maximum_volume && bag.blood_type && bag.blood_type == donor_type)
			return bag
	for(var/obj/item/reagent_containers/blood/bag as anything in contained_bags)
		if(!bag.reagents.total_volume)
			return bag

/mob/living/basic/bot/bloodbot/proc/dispense_reward()
	speak(pick("Smacznego!", "Zapraszamy ponownie!", "Oddawaj często!"))
	var/roll = rand(1, 7)
	if(roll <= 3)
		new /obj/item/food/cookie(drop_location())
	else if(roll <= 6)
		new /obj/item/food/chococoin(drop_location())
	else
		for(var/i in 1 to 6)
			new /obj/item/food/cookie(drop_location())

/mob/living/basic/bot/bloodbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/reagent_containers/blood))
		if(length(contained_bags) >= 8)
			speak("Przepraszam, siostro. W środku nie ma już miejsca.")
			return TRUE
		if(user.transferItemToLoc(attacking_item, src))
			contained_bags += attacking_item
			speak("Dzięki, siostro! Mam ich teraz [length(contained_bags)]!")
		return TRUE
	return ..()

/mob/living/basic/bot/bloodbot/get_custom_controls(mob/user)
	return list("eject_blood_bags" = length(contained_bags))

/mob/living/basic/bot/bloodbot/bot_custom_act(action, list/params, mob/user)
	if(action != "eject_blood_bags")
		return FALSE
	for(var/obj/item/bag as anything in contained_bags)
		bag.forceMove(drop_location())
	contained_bags.Cut()
	return TRUE

/mob/living/basic/bot/bloodbot/emag_effects(mob/user)
	visible_message(span_danger("[src] dziwnie brzęczy!"))
	speed = 1
	update_basic_mob_varspeed()

#undef ACULA_DRINK_RATE
#undef ACULA_DANGER_RATE

/datum/crafting_recipe/bloodbot
	name = "Doctor Acula"
	result = /mob/living/basic/bot/bloodbot
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/reagent_containers/blood = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

// --- Farmbot (Plantbot): podlewa, nawozi i pieli tace hydroponiczne. Zhakowany wali motyką ludzi.
// Bay ma osobne zadania dla chwastów i szkodników; nasza botanika (rework Aquili) ich nie ma, więc farmbot
// podlewa i nawozi, a zamiast pielenia dolewa środka na szkodniki, gdy taca ma ich dużo (planter_pests).

/mob/living/basic/bot/farmbot
	name = "\improper Farmbot"
	desc = "Robot hydroponiki. Sam podlewa i nawozi rośliny."
	icon_state = "farmbot0"
	maxHealth = 50
	health = 50
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Farmbot"
	hackables = "moduł rozpoznawania roślin"
	work_reach = 1
	work_interval = 2 SECONDS
	work_target_types = list(/obj/item/plant_tray, /mob/living/carbon/human)
	possessed_message = "Jesteś farmbotem! Dbaj o rośliny w hydroponice."
	emagged_message = "Jesteś zepsutym farmbotem! Ludzie to chwasty."
	/// Woda w zbiorniku
	var/water_level = 300
	var/max_water = 300

/mob/living/basic/bot/farmbot/Initialize(mapload)
	additional_access = list(ACCESS_HYDROPONICS)
	. = ..()

/mob/living/basic/bot/farmbot/req_bot_access()
	return list(ACCESS_HYDROPONICS)

/mob/living/basic/bot/farmbot/update_icon_state()
	. = ..()
	icon_state = "farmbot[!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/farmbot/update_overlays()
	. = ..()
	if(mode == BBOT_WORKING)
		. += "farmbot_water"

/mob/living/basic/bot/farmbot/is_valid_work_target(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		return is_emagged() && victim.stat != DEAD
	if(!target.reagents || !isturf(target.loc))
		return FALSE
	return water_level > 0 && target.reagents.total_volume < target.reagents.maximum_volume / 2

/mob/living/basic/bot/farmbot/work_on_target(atom/target)
	if(QDELETED(target))
		return BOT_WORK_DONE
	if(get_dist(src, target) > 1)
		return BOT_WORK_OUT_OF_REACH
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(victim.stat == DEAD)
			return BOT_WORK_DONE
		playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
		victim.apply_damage(8, BRUTE, sharpness = SHARP_EDGED)
		victim.visible_message(span_danger("[src] tnie [victim] motyką!"), span_userdanger("[src] tnie cię motyką!"))
		return BOT_WORK_CONTINUE
	flick("farmbot_water", src)
	visible_message(span_notice("[src] podlewa i nawozi [target]."))
	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)
	var/amount = min(water_level, 20)
	water_level -= amount
	target.reagents.add_reagent(/datum/reagent/water, amount)
	target.reagents.add_reagent(/datum/reagent/plantnutriment/eznutriment, 2)
	return BOT_WORK_DONE

/mob/living/basic/bot/farmbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/reagent_containers) && attacking_item.reagents?.has_reagent(/datum/reagent/water))
		var/added = min(max_water - water_level, attacking_item.reagents.get_reagent_amount(/datum/reagent/water))
		attacking_item.reagents.remove_reagent(/datum/reagent/water, added)
		water_level += added
		to_chat(user, span_notice("Dolewasz wody do [src] ([water_level]/[max_water])."))
		return TRUE
	return ..()

/mob/living/basic/bot/farmbot/examine(mob/user)
	. = ..()
	. += span_notice("Woda w zbiorniku: [water_level]/[max_water]. Dolejesz ją z wiadra albo konewki.")

/mob/living/basic/bot/farmbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Psujesz moduł rozpoznawania roślin [src]."))

/mob/living/basic/bot/farmbot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/reagent_containers/glass/bucket(drop_spot)
	new /obj/item/cultivator(drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	return ..()

/datum/crafting_recipe/farmbot
	name = "Farmbot"
	result = /mob/living/basic/bot/farmbot
	reqs = list(
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/cultivator = 1,
		/obj/item/plant_scanner = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

// --- Frightbot: opowiada straszne historie. Zhakowany straszy tak, że ludzie się jąkają, wymiotują, krzyczą itd.

/mob/living/basic/bot/frightbot
	name = "frightbot"
	desc = "Od jego strasznych historii popuścisz w majtki!"
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "frightbot1"
	maxHealth = 25
	health = 25
	model = "Frightbot"
	robot_arm = null
	hackables = "moduł opowieści"
	possessed_message = "Jesteś frightbotem! Opowiadaj straszne historie."
	emagged_message = "Jesteś zepsutym frightbotem! Twoje historie dosłownie przerażają."
	COOLDOWN_DECLARE(fright_cooldown)
	var/static/list/frights = list(
		"opowiada historię tak straszną, że można zmoczyć spodnie",
		"opowiada historię tak straszną, że chcesz zatkać uszy",
		"opowiada historię tak przerażającą, że zęby same szczękają",
		"opowiada mrożącą krew w żyłach historię",
		"opowiada straszną historię z kilkoma wzruszającymi momentami",
		"zaczyna opowiadać historię, od której ciarki chodzą po plecach",
		"wydaje okropne zgrzyty, próbując opowiadać straszne historie",
		"opowiada historię tak straszną, że nie możesz powstrzymać śmiechu",
		"przypadkiem opowiada słodką, zabawną historyjkę",
		"opowiada historię tak straszną, że już nigdy nie pójdziesz w nocy do łazienki",
		"opowiada historię tak straszną, że łzy napływają do oczu",
	)

/mob/living/basic/bot/frightbot/update_icon_state()
	. = ..()
	icon_state = "frightbot[!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/frightbot/Life(seconds, times_fired)
	. = ..()
	if(stat || client || !(bot_mode_flags & BOT_MODE_ON) || !COOLDOWN_FINISHED(src, fright_cooldown) || !prob(35))
		return
	COOLDOWN_START(src, fright_cooldown, 15 SECONDS)
	tell_story()

/mob/living/basic/bot/frightbot/proc/tell_story()
	playsound(src, 'aquila/sound/voice/frightbot/fright.ogg', 50, TRUE)
	if(!is_emagged() || !prob(70))
		flick("frightbot_speak", src)
		visible_message(span_danger("<b>[src]</b> [pick(frights)]!"))
		return
	COOLDOWN_START(src, fright_cooldown, 20 SECONDS)
	flick("frightbot_fright", src)
	switch(pick("stutter", "puke", "scream", "flip", "mute", "panic"))
		if("stutter")
			visible_message(span_danger("<b>[src]</b> opowiada historię tak przerażającą, że nie możesz przestać się jąkać!"))
			for(var/mob/living/listener in viewers(src))
				listener.stuttering = max(listener.stuttering, 5)
		if("puke")
			visible_message(span_danger("<b>[src]</b> opowiada tak makabryczną i obrzydliwą historię, że nie możesz powstrzymać wymiotów!"))
			for(var/mob/living/carbon/human/listener in viewers(src))
				listener.vomit(10)
		if("scream")
			visible_message(span_danger("<b>[src]</b> opowiada historię z nagłym straszakiem na końcu!"))
			for(var/mob/living/listener in viewers(src))
				listener.emote("scream")
		if("flip")
			visible_message(span_danger("<b>[src]</b> opowiada historię tak straszną, że odruchowo robisz salto!"))
			for(var/mob/living/listener in viewers(src))
				listener.emote("flip")
		if("mute")
			visible_message(span_danger("<b>[src]</b> opowiada tak abstrakcyjną i nieziemską historię, że nagle nie masz ust!"))
			for(var/mob/living/carbon/listener in viewers(src))
				listener.silent += 3
		if("panic")
			visible_message(span_danger("<b>[src]</b> mówi ci, że zostało ci tylko godzinę życia!"))
			for(var/mob/living/carbon/listener in viewers(src))
				listener.visible_message(span_danger("[listener] miota się w panice."), span_userdanger("Masz atak paniki!"))
				listener.confused += rand(6, 8)
				listener.jitteriness += rand(6, 8)

/mob/living/basic/bot/frightbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_warning("Frightbot będzie teraz opowiadał historie tak straszne, że ludzie odczują je fizycznie!"))

/mob/living/basic/bot/frightbot/explode()
	if(prob(50))
		new /obj/item/radio(drop_location())
	new /obj/effect/decal/cleanable/oil(drop_location())
	return ..()

/obj/item/frightbot_chasis
	name = "obudowa frightbota"
	desc = "Obudowa nowego frightbota. Brakuje jej tylko radia."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "frightbot_chasis"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/frightbot_chasis/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/radio))
		return ..()
	to_chat(user, span_notice("Kończysz frightbota! KIIIIIIII!!!"))
	qdel(attacking_item)
	new /mob/living/basic/bot/frightbot(get_turf(src))
	qdel(src)
	return TRUE

/datum/crafting_recipe/frightbot_chasis
	name = "obudowa frightbota"
	result = /obj/item/frightbot_chasis
	reqs = list(/obj/item/stack/sheet/iron = 2, /obj/item/assembly/prox_sensor = 1)
	tools = list(TOOL_WELDER)
	time = 3 SECONDS
	category = CAT_ROBOT

// --- Screambot: po prostu wrzeszczy. Zhakowany wrzeszczy bez przerwy.

/mob/living/basic/bot/screambot
	name = "screambot"
	desc = "WRZASK SIĘ NASILA."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "screambot1"
	maxHealth = 25
	health = 25
	model = "Screambot"
	hackables = "ogranicznik głośności"
	layer = ABOVE_MOB_LAYER
	possessed_message = "Jesteś screambotem. Wrzeszcz."
	COOLDOWN_DECLARE(scream_cooldown)
	/// Jak często wrzeszczy (%)
	var/probability = 30
	var/speedup = 1
	var/static/list/scream_sounds = list(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/malescream_1.ogg',
		'sound/voice/human/malescream_2.ogg',
		'sound/voice/lizard/lizard_scream.ogg',
		'sound/voice/moth/scream_moth.ogg',
	)

/mob/living/basic/bot/screambot/update_icon_state()
	. = ..()
	icon_state = "screambot[!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/screambot/Life(seconds, times_fired)
	. = ..()
	if(stat || client || !(bot_mode_flags & BOT_MODE_ON) || !COOLDOWN_FINISHED(src, scream_cooldown) || !prob(probability))
		return
	COOLDOWN_START(src, scream_cooldown, 10 SECONDS / speedup)
	playsound(src, pick(scream_sounds), 50, TRUE, 7, 1.2)
	flick("screambot_scream", src)
	visible_message(span_danger("<b>[src]</b> wrzeszczy!"))

/mob/living/basic/bot/screambot/emag_effects(mob/user)
	speedup = 10
	probability = 100
	if(user)
		to_chat(user, span_warning("Świetnie. Screambot będzie teraz naprawdę, NAPRAWDĘ irytujący."))

/mob/living/basic/bot/screambot/explode()
	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(drop_location())
	new /obj/effect/decal/cleanable/oil(drop_location())
	visible_message(span_userdanger("[src] rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)

/obj/item/screambot_chasis
	name = "obudowa screambota"
	desc = "Obudowa nowego screambota."
	icon = 'aquila/icons/mob/bots/other_bots.dmi'
	icon_state = "screambot_chasis"
	w_class = WEIGHT_CLASS_SMALL
	var/build_step = 0

/obj/item/screambot_chasis/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.is_hot() && build_step <= 0)
		to_chat(user, span_notice("Wypalasz w [src] kilka dziur."))
		build_step = 1
		desc += " Ma dziwne dziury przypominające twarz."
		icon_state = "screambot_chasis1"
		return TRUE
	if((istype(attacking_item, /obj/item/bodypart/l_arm/robot) || istype(attacking_item, /obj/item/bodypart/r_arm/robot)) && build_step == 1)
		to_chat(user, span_notice("Kończysz screambota!"))
		qdel(attacking_item)
		new /mob/living/basic/bot/screambot(get_turf(src))
		qdel(src)
		return TRUE
	return ..()

/datum/crafting_recipe/screambot_chasis
	name = "obudowa screambota"
	result = /obj/item/screambot_chasis
	reqs = list(/obj/item/stack/sheet/iron = 2)
	tools = list(TOOL_WELDER)
	time = 3 SECONDS
	category = CAT_ROBOT
