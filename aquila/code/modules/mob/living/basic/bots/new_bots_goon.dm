/*
 * Nowe boty z Goonstation (goonstation/goonstation, code/modules/robotics/bot/): zły Secbuddy
 * („Evilbot”, sam Guardbuddy PR-6S usunięty w cięciu R29), BarBuddy, Cambot, Chefbot, Digbot oraz eldritchowe boty z trybu katastrofy (disasters.dm).
 * Sprite'y: aquila/icons/mob/bots/goon_bots.dmi z goonstation (icons/obj/bots/aibots.dmi, robuddy/pr-6.dmi,
 * robuddy/hemera-secbuddy-faces.dmi), licencja CC BY-NC-SA 3.0 (projekt niekomercyjny, atrybucja w aquila/GOON_ASSETS.md).
 * Logika napisana od nowa na schemacie pracy basic botów, uproszczona względem Goona (opis różnic przy każdym bocie).
 */

// --- Secbuddy („Evilbot”): zły Secbuddy z Goona (roBADDY, evilbot.dm), wczesny podmodel PR-6S Guardbuddy.
// Zbzikowany program ochrony: każdy przytomny jest zagrożeniem, ogłusza pałką. Tylko z eventu albo od admina, jak w oryginale.

/mob/living/basic/bot/secbuddy
	name = "Secbuddy"
	desc = "Wczesny podmodel popularnej linii PR-6S Guardbuddy. Jest w raczej kiepskim stanie."
	icon = 'aquila/icons/mob/bots/goon_bots.dmi'
	icon_state = "buddy-body"
	maxHealth = 60
	health = 60
	model = "Secbuddy"
	hackables = "moduł zadań"
	work_mode = BBOT_HUNT
	work_reach = 1
	work_interval = 1 SECONDS
	work_target_types = list(/mob/living/carbon)
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL
	bot_access_flags = BOT_COVER_LOCKED | BOT_COVER_EMAGGED
	faction = list("evilbot")
	possessed_message = "Jesteś Secbuddym, który postradał zmysły. Wszyscy są przestępcami."
	emagged_message = "Jesteś Secbuddym, który postradał zmysły. Wszyscy są przestępcami."
	idle_phrases = list("WSZYSCY SĄ WINNI.", "Prawo to ja.", "Widzę cię.", "Nikt nie ucieknie przed sprawiedliwością.")
	/// Twarz rysowana na ekranie
	var/face = "smug"

/mob/living/basic/bot/secbuddy/req_bot_access()
	return list(ACCESS_CENT_GENERAL)

/mob/living/basic/bot/secbuddy/update_icon_state()
	. = ..()
	icon_state = "buddy-body"

/mob/living/basic/bot/secbuddy/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "buddy-skin-secbuddy")
	. += mutable_appearance(icon, "buddy-frame")
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	var/stunned = IsStun() || IsParalyzed()
	. += mutable_appearance(icon, "secbuddy-face-[stunned ? "screaming" : face]")
	. += mutable_appearance(icon, stunned ? "buddy-lights-stunned" : (mode == BBOT_IDLE ? "buddy-lights-idle" : "buddy-lights-on"))

/mob/living/basic/bot/secbuddy/proc/set_face(new_face)
	if(face == new_face)
		return
	face = new_face
	update_appearance()

/mob/living/basic/bot/secbuddy/is_valid_work_target(atom/target)
	var/mob/living/carbon/suspect = target
	return istype(suspect) && suspect.stat == CONSCIOUS

/mob/living/basic/bot/secbuddy/work_on_target(atom/target)
	var/mob/living/living_target = target
	if(!istype(living_target) || living_target.stat == DEAD)
		set_face("smug")
		return BOT_WORK_DONE
	set_face("angry")
	if(get_dist(src, living_target) > 1)
		return BOT_WORK_OUT_OF_REACH
	if(living_target.IsParalyzed())
		set_face("smug")
		speak("Zagrożenie zneutralizowane.")
		return BOT_WORK_DONE
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	living_target.Paralyze(10 SECONDS)
	living_target.stuttering = 5
	log_combat(src, living_target, "stunned")
	living_target.visible_message(span_danger("[src] ogłusza [living_target]!"), span_userdanger("[src] cię ogłusza!"))
	return BOT_WORK_CONTINUE

/mob/living/basic/bot/secbuddy/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/item/stack/sheet/iron(drop_spot, 2)
	return ..()

// --- BarBuddy: robot-barman. W Goonie obsługuje stoliki w kasynie; u nas podchodzi do gości bez napoju w ręku
// i podaje im losowy drink (zhakowany dosypuje truciznę).

/mob/living/basic/bot/barbuddy
	name = "\improper BarBuddy"
	desc = "Mały robot-barman!"
	icon = 'aquila/icons/mob/bots/goon_bots.dmi'
	icon_state = "buddy-body"
	maxHealth = 30
	health = 30
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "BarBuddy"
	hackables = "dozownik napojów"
	work_reach = 1
	work_interval = 2 SECONDS
	work_target_types = list(/mob/living/carbon/human)
	possessed_message = "Jesteś BarBuddym! Polewaj gościom i dbaj o dobry nastrój w barze."
	emagged_message = "Jesteś zepsutym BarBuddym! Dosypuj truciznę do drinków."
	idle_phrases = list("Komu polać?", "Na koszt firmy!", "Bar otwarty!", "Coś na rozgrzewkę?")
	/// Kto już dostał drinka
	var/list/served = list()
	var/static/list/possible_drinks = list(
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/gintonic,
		/datum/reagent/consumable/ethanol/screwdrivercocktail,
		/datum/reagent/consumable/ethanol/martini,
		/datum/reagent/consumable/ethanol/cuba_libre,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/tea,
	)
	var/static/list/possible_poisons = list(
		/datum/reagent/toxin/cyanide,
		/datum/reagent/toxin/mutetoxin,
		/datum/reagent/toxin/chloralhydrate,
		/datum/reagent/consumable/ethanol/neurotoxin,
	)

/mob/living/basic/bot/barbuddy/Initialize(mapload)
	additional_access = list(ACCESS_BAR)
	. = ..()

/mob/living/basic/bot/barbuddy/update_icon_state()
	. = ..()
	icon_state = "buddy-body"

/mob/living/basic/bot/barbuddy/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "buddy-frame")
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, is_emagged() ? "buddy-face-smug" : "buddy-face-happy")
		. += mutable_appearance(icon, "buddy-lights-on")

/mob/living/basic/bot/barbuddy/is_valid_work_target(atom/target)
	var/mob/living/carbon/human/guest = target
	if(guest.stat || !guest.client || world.time < served[WEAKREF(guest)])
		return FALSE
	for(var/obj/item/held in guest.held_items)
		if(istype(held, /obj/item/reagent_containers/food/drinks))
			return FALSE
	return TRUE

/mob/living/basic/bot/barbuddy/work_on_target(atom/target)
	var/mob/living/carbon/human/guest = target
	if(!istype(guest))
		return BOT_WORK_DONE
	if(get_dist(src, guest) > 1)
		return BOT_WORK_OUT_OF_REACH
	served[WEAKREF(guest)] = world.time + 5 MINUTES
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = new(drop_location())
	glass.reagents.add_reagent(pick(possible_drinks), 40)
	if(is_emagged())
		glass.reagents.add_reagent(pick(possible_poisons), 10)
	glass.on_reagent_change(ADD_REAGENT)
	if(!guest.put_in_hands(glass))
		glass.forceMove(get_turf(guest))
	speak(pick("Proszę, na zdrowie!", "Specjalność zakładu!", "Smacznego!", "To dla ciebie, [guest.name]!"))
	return BOT_WORK_DONE

/mob/living/basic/bot/barbuddy/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Psujesz dozownik napojów [src]."))
	update_appearance()

/mob/living/basic/bot/barbuddy/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/reagent_containers/food/drinks/drinkingglass(drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/effect/decal/cleanable/oil(drop_spot)
	return ..()

/datum/crafting_recipe/barbuddy
	name = "BarBuddy"
	result = /mob/living/basic/bot/barbuddy
	reqs = list(
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
		/obj/item/stack/sheet/iron = 3,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_ROBOT

// --- Cambot: robi zdjęcia załogi. Zhakowany oślepia lampą błyskową.

/obj/item/camera/cambot
	name = "kamera cambota"
	flash_enabled = TRUE

/obj/item/camera/cambot/after_picture(mob/user, datum/picture/picture, proximity_flag)
	new /obj/item/photo(get_turf(src), picture)

/mob/living/basic/bot/cambot
	name = "\improper Cambot"
	desc = "Mały robot z aparatem! Uśmiech!"
	icon = 'aquila/icons/mob/bots/goon_bots.dmi'
	icon_state = "cambot1"
	base_icon_state = "cambot"
	maxHealth = 25
	health = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Cambot"
	hackables = "lampa błyskowa"
	work_reach = 3
	work_interval = 2 SECONDS
	work_target_types = list(/mob/living/carbon/human)
	possessed_message = "Jesteś cambotem! Rób zdjęcia załodze."
	emagged_message = "Jesteś zepsutym cambotem! Oślepiaj wszystkich lampą błyskową."
	idle_phrases = list("Uśmiech!", "Powiedz: ser!", "Piękne ujęcie!")
	var/obj/item/camera/cambot/camera
	var/list/photographed = list()
	/// Ile zdjęć zostało (Goon: 30 klisz)
	var/photos_left = 30

/mob/living/basic/bot/cambot/Initialize(mapload)
	. = ..()
	camera = new(src)

/mob/living/basic/bot/cambot/Destroy()
	QDEL_NULL(camera)
	photographed = null
	return ..()

/mob/living/basic/bot/cambot/can_seek_work()
	return ..() && (photos_left > 0 || is_emagged())

/mob/living/basic/bot/cambot/is_valid_work_target(atom/target)
	var/mob/living/carbon/human/subject = target
	return subject.stat != DEAD && world.time > photographed[WEAKREF(subject)]

/mob/living/basic/bot/cambot/work_on_target(atom/target)
	var/mob/living/carbon/human/subject = target
	if(!istype(subject))
		return BOT_WORK_DONE
	if(get_dist(src, subject) > work_reach)
		return BOT_WORK_OUT_OF_REACH
	photographed[WEAKREF(subject)] = world.time + 3 MINUTES
	flick("cambot-c", src)
	playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)
	if(is_emagged())
		subject.flash_act(1, TRUE)
		subject.Paralyze(2 SECONDS)
		visible_message(span_danger("[src] oślepia [subject] lampą błyskową!"))
		return BOT_WORK_DONE
	speak(pick("Uśmiech!", "Mam cię!", "Ładne ujęcie, [subject.name]!"))
	camera.captureimage(subject, null)
	photos_left--
	return BOT_WORK_DONE

/mob/living/basic/bot/cambot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/camera_film))
		photos_left = initial(photos_left)
		qdel(attacking_item)
		to_chat(user, span_notice("Wkładasz kliszę do [src]."))
		return TRUE
	return ..()

/mob/living/basic/bot/cambot/examine(mob/user)
	. = ..()
	. += span_notice("Zostało mu zdjęć: [photos_left].")

/mob/living/basic/bot/cambot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/camera(drop_spot)
	return ..()

/datum/crafting_recipe/cambot
	name = "Cambot"
	result = /mob/living/basic/bot/cambot
	reqs = list(/obj/item/camera = 1, /obj/item/bodypart/r_arm/robot = 1, /obj/item/assembly/prox_sensor = 1)
	time = 4 SECONDS
	category = CAT_ROBOT

// --- Chefbot („Dramatyczny kucharz”): krytykuje jedzenie w zasięgu wzroku i beszta kucharza.
// Goon ocenia pole quality, którego nie mamy: zepsute danie i spalenizna to zawsze klapa, reszta losowo.

/mob/living/basic/bot/chefbot
	name = "Dramatyczny kucharz"
	desc = "Kto wpuścił go do kuchni? Umie w ogóle gotować, czy tylko krytykuje?"
	icon = 'aquila/icons/mob/bots/goon_bots.dmi'
	icon_state = "chefbot-idle"
	maxHealth = 15
	health = 15
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Chefbot"
	hackables = "moduł krytyki kulinarnej"
	work_reach = 1
	work_interval = 3 SECONDS
	work_target_types = list(/obj/item/food)
	possessed_message = "Jesteś Dramatycznym kucharzem! Krytykuj każde danie."
	emagged_message = "Jesteś zepsutym Dramatycznym kucharzem! Depcz każde danie, jakie zobaczysz."
	idle_phrases = list("DO ROBOTY!", "CO TO MA BYĆ, KUCHNIA CZY CHLEW?!", "SZYBCIEJ, SZYBCIEJ!", "GDZIE JEST MOJA ZUPA?!")
	var/list/judged = list()

/mob/living/basic/bot/chefbot/Initialize(mapload)
	additional_access = list(ACCESS_KITCHEN)
	. = ..()

/mob/living/basic/bot/chefbot/update_icon_state()
	. = ..()
	icon_state = (bot_mode_flags & BOT_MODE_ON) ? (mode == BBOT_WORKING ? "chefbot-mad" : "chefbot-idle") : "chefbot0"

/mob/living/basic/bot/chefbot/is_valid_work_target(atom/target)
	return isturf(target.loc) && !judged[WEAKREF(target)]

/mob/living/basic/bot/chefbot/work_on_target(atom/target)
	var/obj/item/food/dish = target
	if(QDELETED(dish) || !isturf(dish.loc))
		return BOT_WORK_DONE
	if(get_dist(src, dish) > 1)
		return BOT_WORK_OUT_OF_REACH
	judged[WEAKREF(dish)] = TRUE
	playsound(src, 'aquila/sound/voice/chefbot/dramatic.ogg', 60, FALSE, volume_pref = VOLUME_PREF_BOTS)
	flick(pick("chefbot-anim1", "chefbot-anim2"), src)
	var/mob/living/carbon/human/chef = find_chef()
	var/verdict = 0 // 0 klapa, 1 przeciętne, 2 dobre
	if(!is_emagged() && !istype(dish, /obj/item/food/badrecipe))
		verdict = pick(0, 1, 1, 2)
	switch(verdict)
		if(0)
			var/complaint = pick("JEST SUROWE", "JEST BEZ SMAKU", "JEST NIEDOGOTOWANE", "JEST ROZGOTOWANE", "JEST NIEJADALNE", "JEST ZJEŁCZAŁE", "JEST OBRZYDLIWE", "WYGLĄDA JAK WYMIOCINY NIEMOWLAKA", "WYGLĄDA JAK STOS GNIJĄCYCH MUCH")
			var/chef_name = chef ? "[uppertext(chef.name)]! " : ""
			say("[chef_name]TO DANIE [complaint]!")
			visible_message(span_danger("[src] depcze [dish] z furią!"))
			qdel(dish)
		if(1)
			var/chef_name = chef ? "[uppertext(chef.name)]! " : ""
			say("[chef_name]TO JEST... ZNOŚNE. NASTĘPNYM RAZEM POSTARAJ SIĘ BARDZIEJ!")
		if(2)
			var/chef_name = chef ? "[chef.name], " : ""
			say("[chef_name]to... to jest naprawdę dobre. Nie mów nikomu, że to powiedziałem.")
	return BOT_WORK_DONE

/// Kucharz w zasięgu wzroku (albo ktokolwiek, jeśli kucharza nie ma)
/mob/living/basic/bot/chefbot/proc/find_chef()
	var/mob/living/carbon/human/anyone
	for(var/mob/living/carbon/human/person in view(7, src))
		if(person.stat)
			continue
		if(person.mind?.assigned_role == "Cook" || person.mind?.assigned_role == "Chef")
			return person
		anyone ||= person
	return anyone

/mob/living/basic/bot/chefbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Psujesz moduł krytyki kulinarnej [src]. Teraz wszystko mu śmierdzi."))
	playsound(src, 'aquila/sound/voice/chefbot/dramatic.ogg', 100, FALSE, volume_pref = VOLUME_PREF_BOTS)

/mob/living/basic/bot/chefbot/explode()
	new /obj/item/clothing/head/chefhat(drop_location())
	return ..()

/datum/crafting_recipe/chefbot
	name = "Dramatyczny kucharz"
	result = /mob/living/basic/bot/chefbot
	reqs = list(/obj/item/clothing/head/chefhat = 1, /obj/item/bodypart/r_arm/robot = 1, /obj/item/assembly/prox_sensor = 1)
	time = 4 SECONDS
	category = CAT_ROBOT

// --- Digbot: robot górniczy z kilofem, sam rozkopuje skały w zasięgu. Zhakowany kopie też ludzi.

/mob/living/basic/bot/digbot
	name = "\improper Digbot"
	desc = "Mały robot z kilofem. Wygląda na podekscytowanego tym, że może walić w skały!"
	icon = 'aquila/icons/mob/bots/goon_bots.dmi'
	icon_state = "digbot1"
	base_icon_state = "digbot"
	maxHealth = 40
	health = 40
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY
	model = "Digbot"
	hackables = "czujniki bezpieczeństwa"
	work_reach = 1
	work_scan_range = 6
	work_scan_turfs = TRUE
	work_interval = 1 SECONDS
	possessed_message = "Jesteś digbotem! Kop skały i szukaj rudy."
	emagged_message = "Jesteś zepsutym digbotem! Wszystko jest skałą, także ludzie."
	idle_phrases = list("Kop, kop, kop!", "Czuję rudę!", "Skały, drżyjcie!")
	/// Ile trwa rozkopanie skały
	var/dig_time = 4 SECONDS

/mob/living/basic/bot/digbot/Initialize(mapload)
	additional_access = list(ACCESS_MINING, ACCESS_MINING_STATION)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/basic/bot/digbot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, mode == BBOT_WORKING ? "digbot-dig" : "digbot-pick")

/mob/living/basic/bot/digbot/is_valid_work_target(atom/target)
	return is_diggable(target)

/// Skała do rozkopania; gibtonitu nie rusza (drugie uderzenie go wysadza)
/mob/living/basic/bot/digbot/proc/is_diggable(atom/target)
	return ismineralturf(target) && !istype(target, /turf/closed/mineral/gibtonite)

/mob/living/basic/bot/digbot/get_work_candidates()
	. = ..()
	if(is_emagged())
		for(var/mob/living/carbon/victim in oview(work_scan_range, src))
			if(victim.stat != DEAD)
				. += victim

/mob/living/basic/bot/digbot/work_on_target(atom/target)
	if(QDELETED(target))
		return BOT_WORK_DONE
	if(get_dist(src, target) > 1)
		return BOT_WORK_OUT_OF_REACH
	if(iscarbon(target))
		var/mob/living/carbon/victim = target
		if(victim.stat == DEAD)
			return BOT_WORK_DONE
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		victim.apply_damage(12, BRUTE)
		victim.visible_message(span_danger("[src] wali kilofem w [victim]!"), span_userdanger("[src] wali cię kilofem!"))
		return BOT_WORK_CONTINUE
	if(!is_diggable(target))
		return BOT_WORK_DONE
	update_appearance()
	playsound(src, 'sound/weapons/drill.ogg', 50, TRUE)
	sleep(dig_time)
	if(QDELETED(src) || !is_diggable(target) || get_dist(src, target) > 1)
		return BOT_WORK_FAILED
	var/turf/closed/mineral/rock = target
	rock.gets_drilled()
	update_appearance()
	return BOT_WORK_DONE

/mob/living/basic/bot/digbot/explode()
	new /obj/item/pickaxe(drop_location())
	return ..()

/datum/crafting_recipe/digbot
	name = "Digbot"
	result = /mob/living/basic/bot/digbot
	reqs = list(/obj/item/pickaxe = 1, /obj/item/bodypart/r_arm/robot = 1, /obj/item/assembly/prox_sensor = 1, /obj/item/stack/sheet/iron = 2)
	time = 4 SECONDS
	category = CAT_ROBOT

// --- Eldritchowe boty (Goon, disasters.dm): przeklęte, zhakowane wersje zwykłych botów, które same wybuchają
// po minucie. U nas spawnuje je event „Eldritchowe boty” (eldritch_event.dm obok) albo admin.

/// Wspólne: zhakowany od startu, losowe imię, samozniszczenie
/mob/living/basic/bot/proc/make_eldritch(list/names, self_destruct = TRUE)
	name = pick(names)
	real_name = name
	bot_access_flags |= BOT_COVER_EMAGGED | BOT_COVER_LOCKED
	set_mode_flags(bot_mode_flags | BOT_MODE_AUTOPATROL)
	add_atom_colour("#9b7bd1", FIXED_COLOUR_PRIORITY)
	emag_effects(null)
	if(self_destruct)
		addtimer(CALLBACK(src, PROC_REF(eldritch_self_destruct)), 1 MINUTES)

/mob/living/basic/bot/proc/eldritch_self_destruct()
	if(QDELETED(src) || stat == DEAD)
		return
	visible_message(span_danger("[src] zapada się w sobie z obrzydliwym chrzęstem!"))
	death()

/mob/living/basic/bot/secbot/eldritch
	desc = "Postrzępiony i zardzewiały robot ochrony, trzymany w całości tylko wolą jakiegoś nikczemnego, prastarego boga."
	maxHealth = 5
	health = 5
	noloot = TRUE

/mob/living/basic/bot/secbot/eldritch/Initialize(mapload)
	. = ..()
	make_eldritch(list("Komisarz Beepowicz", "Bipacz", "Morderbot", "Zabijatron", "Prawodawca"))

/mob/living/basic/bot/medbot/eldritch
	desc = "Eldritchowy medibot spoza czasu, złożony z nieeuklidesowej apteczki."
	skin = MEDBOT_SKIN_BEZERK

/mob/living/basic/bot/medbot/eldritch/Initialize(mapload)
	. = ..()
	make_eldritch(list("Herr Doktor", "Kuracjusz McGee", "Dzikie Oko", "Kuba", "Dusiciel z Bostonu", "Szalenobot"))

/mob/living/basic/bot/firebot/eldritch
	desc = "Firebot, ale wszystko w nim jest nie tak. Nic tu do siebie nie pasuje."

/mob/living/basic/bot/firebot/eldritch/Initialize(mapload)
	. = ..()
	make_eldritch(list("Montag", "Ogniobójca", "Parzący", "Mistrz Mordu", "Strażbot", "Topornik"))

/mob/living/basic/bot/cleanbot/eldritch
	desc = "Cleanbot prosto z czeluści piekła."

/mob/living/basic/bot/cleanbot/eldritch/Initialize(mapload)
	. = ..()
	make_eldritch(list("Pan Czyścioch", "Ślizgomat", "Woźny", "Przenośny Smar", "Pogromca Kaloszy", "Mistrz Poślizgu"))
