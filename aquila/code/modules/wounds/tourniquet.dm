// AQUILA - opaska uciskowa (tourniquet) na wzór tgstation#95041, na naszym systemie krwawienia i ran.
// Krwawienie Bee jest jedną liczbą na całego moba, więc śledzimy w przybliżeniu, ile krwawienia przyszło z której kończyny
// (trafienia, rany cięte, oderwanie kończyny). Jak w tg opaska odcina 90% tego udziału, spowalnia nogę albo rękę,
// a na szyi dusi. Nasze: noszona za długo powoduje niedokrwienie i martwicę kończyny.

/// Po tym czasie zaczyna się niedokrwienie: obrażenia kończyny i spowolnienie rosną z każdą minutą
#define TOURNIQUET_ISCHEMIA_TIME (3 MINUTES)
/// Po tym czasie kończyna obumiera: zdjęcie opaski daje wstrząs toksyczny
#define TOURNIQUET_NECROSIS_TIME (8 MINUTES)
/// Opaska zdjęta szybciej niż po tym czasie puszcza całe zatrzymane krwawienie
#define TOURNIQUET_CLOT_TIME (1 MINUTES)
/// Spowolnienie od samej opaski na nodze (tg: +0.5)
#define TOURNIQUET_BASE_SLOWDOWN 0.5
/// Ile krwawienia z kończyny zatrzymuje opaska (tg: 90%)
#define TOURNIQUET_BLEED_BLOCK 0.9
/// O tyle wolniejsze są akcje z opaską na ręce (tg: +0.5 do interaction_modifier)
#define TOURNIQUET_ARM_ACTION_MOD 0.5
#define TOURNIQUET_MAX_SLOWDOWN 1.5

/// Strefa ciała (ręka/noga) -> przybliżone krwawienie z tej kończyny
/mob/living/carbon/var/list/aq_limb_bleed
/// Strefa ciała -> założona opaska
/mob/living/carbon/var/list/aq_tourniquets

/proc/aq_tourniquet_zone_name(zone)
	switch(zone)
		if(BODY_ZONE_L_ARM)
			return "lewa ręka"
		if(BODY_ZONE_R_ARM)
			return "prawa ręka"
		if(BODY_ZONE_L_LEG)
			return "lewa noga"
		if(BODY_ZONE_R_LEG)
			return "prawa noga"
		if(BODY_ZONE_HEAD)
			return "szyja"
	return zone

// --- Krwawienie z kończyn ---

/mob/living/carbon/proc/aq_bleed_rate()
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	return bleed ? bleed.bleed_rate : 0

/// Odcina część krwawienia. Zwraca, ile faktycznie odcięto.
/mob/living/carbon/proc/aq_clamp_bleeding(amount)
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	if(!bleed || amount <= 0)
		return 0
	amount = min(amount, bleed.bleed_rate)
	bleed.bleed_rate -= amount
	if(bleed.bleed_rate <= 0 && bleed.bandaged_bleeding <= 0)
		remove_status_effect(STATUS_EFFECT_BLEED)
	else
		bleed.update_icon()
	return amount

// Opatrzenie albo przypalenie zmniejsza globalne krwawienie, więc udziały kończyn maleją w tej samej proporcji.
/mob/living/carbon/cauterise_wounds(amount = INFINITY)
	var/bleed_before = aq_bleed_rate()
	. = ..()
	aq_scale_limb_bleed(bleed_before)

/mob/living/carbon/suppress_bloodloss(amount)
	var/bleed_before = aq_bleed_rate()
	. = ..()
	aq_scale_limb_bleed(bleed_before)

/mob/living/carbon/proc/aq_scale_limb_bleed(bleed_before)
	var/bleed_after = aq_bleed_rate()
	if(bleed_after <= 0 || bleed_before <= 0)
		aq_limb_bleed = null
		return
	for(var/zone in aq_limb_bleed)
		aq_limb_bleed[zone] *= min(1, bleed_after / bleed_before)

/// Przywraca krwawienie zatrzymane wcześniej opaską (bez dźwięku i bez wzoru łączenia z add_bleeding)
/mob/living/carbon/proc/aq_restore_bleeding(amount)
	if(amount <= 0 || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	if(bleed)
		bleed.bleed_rate += amount
		bleed.update_icon()
	else
		apply_status_effect(dna?.species?.bleed_effect || STATUS_EFFECT_BLEED, amount)

/// Zapisuje nowe krwawienie jako pochodzące z kończyny. Pod opaską od razu je odcina.
/mob/living/carbon/proc/aq_add_limb_bleed(zone, amount)
	if(amount <= 0 || !(zone in GLOB.aq_tourniquet_zones))
		return
	var/obj/item/tourniquet/tourniquet = LAZYACCESS(aq_tourniquets, zone)
	if(tourniquet)
		var/blocked = aq_clamp_bleeding(amount * TOURNIQUET_BLEED_BLOCK)
		tourniquet.held_bleed += blocked
		amount -= blocked
		if(amount <= 0)
			return
	LAZYINITLIST(aq_limb_bleed)
	aq_limb_bleed[zone] += amount

/// Rozdziela przyrost krwawienia na kończyny, które dostały obrażenia od czasu snapshotu
/mob/living/carbon/proc/aq_attribute_bleed(list/snapshot, bleed_before)
	var/delta = aq_bleed_rate() - bleed_before
	if(delta <= 0)
		return
	var/list/hit_zones = list()
	var/total = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/list/before = snapshot[limb]
		if(!before || !(limb.body_zone in GLOB.aq_tourniquet_zones))
			continue
		var/taken = (limb.brute_dam - before[1]) + (limb.burn_dam - before[2])
		if(taken > 0)
			hit_zones[limb.body_zone] = taken
			total += taken
	for(var/zone in hit_zones)
		aq_add_limb_bleed(zone, delta * hit_zones[zone] / total)

GLOBAL_LIST_INIT(aq_tourniquet_zones, list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD))

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	var/list/snapshot = aq_limb_damage_snapshot()
	var/bleed_before = aq_bleed_rate()
	. = ..()
	aq_attribute_bleed(snapshot, bleed_before)

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	var/list/snapshot = aq_limb_damage_snapshot()
	var/bleed_before = aq_bleed_rate()
	. = ..()
	aq_attribute_bleed(snapshot, bleed_before)

/obj/item/bodypart/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	var/bleed_before = old_owner?.aq_bleed_rate()
	. = ..()
	if(. && old_owner)
		old_owner.aq_add_limb_bleed(body_zone, old_owner.aq_bleed_rate() - bleed_before)

// Ponowne otwarcie rany ciętej liczy się do kończyny, więc opaska zatrzymuje 90% tego krwawienia.
/datum/wound/slash/wound_effects(delta_time)
	var/bleed_before = victim.aq_bleed_rate()
	. = ..()
	victim.aq_add_limb_bleed(limb.body_zone, victim.aq_bleed_rate() - bleed_before)

/mob/living/carbon/proc/update_tourniquet_slowdown()
	var/slowdown = 0
	for(var/zone in aq_tourniquets)
		if(zone != BODY_ZONE_L_LEG && zone != BODY_ZONE_R_LEG)
			continue
		var/obj/item/tourniquet/tourniquet = aq_tourniquets[zone]
		slowdown += tourniquet.get_slowdown()
	if(slowdown)
		add_movespeed_modifier("aq_tourniquet", override = TRUE, multiplicative_slowdown = slowdown)
	else
		remove_movespeed_modifier("aq_tourniquet")

/mob/living/carbon/get_wound_scan_lines()
	. = ..()
	for(var/zone in aq_tourniquets)
		var/obj/item/tourniquet/tourniquet = aq_tourniquets[zone]
		. += "<span class='alert'>[capitalize(aq_tourniquet_zone_name(zone))]: <b>opaska uciskowa</b> od [DisplayTimeText(tourniquet.worn_time())][tourniquet.get_state_text()].</span>"

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	aq_limb_bleed = null
	for(var/zone in aq_tourniquets?.Copy())
		var/obj/item/tourniquet/tourniquet = aq_tourniquets[zone]
		tourniquet.held_bleed = 0
		tourniquet.detach(silent = TRUE)
		tourniquet.forceMove(drop_location())
	return ..()

// --- Przedmiot ---

/obj/item/tourniquet
	name = "opaska uciskowa"
	desc = "Opaska z pokrętłem do tamowania silnych krwotoków. Założona na rękę albo nogę zatrzymuje prawie całe krwawienie z tej kończyny, ale ją spowalnia, a noszona dłużej niż kilka minut niszczy kończynę. Zakładanie jej na szyję to bardzo zły pomysł."
	icon = 'aquila/icons/obj/sec_med/sec_med.dmi'
	icon_state = "tourniquet"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	resistance_flags = FLAMMABLE
	materials = list(/datum/material/plastic = 500)
	/// Na kim jest założona
	var/mob/living/carbon/wearer
	/// Strefa ciała, na której jest założona
	var/zone
	/// Kiedy ją założono
	var/applied_at = 0
	/// Krwawienie zatrzymane przez opaskę
	var/held_bleed = 0
	/// Kiedy ostatnio ostrzegano noszącego
	var/next_warning = 0
	/// Czy opaska spowalnia akcje noszącego (na ręce)
	var/slows_actions = FALSE

/obj/item/tourniquet/Destroy()
	if(wearer)
		detach(silent = TRUE)
	return ..()

/obj/item/tourniquet/attack(mob/living/M, mob/living/user)
	if(user.combat_mode || !iscarbon(M))
		return ..()
	var/target_zone = check_zone(user.zone_selected)
	if(!(target_zone in GLOB.aq_tourniquet_zones))
		to_chat(user, "<span class='warning'>Opaskę zakłada się na rękę, nogę albo... szyję.</span>")
		return
	try_apply(M, user, target_zone)

/obj/item/tourniquet/proc/try_apply(mob/living/carbon/patient, mob/living/user, target_zone)
	if(LAZYACCESS(patient.aq_tourniquets, target_zone))
		to_chat(user, "<span class='warning'>Na tej kończynie ([aq_tourniquet_zone_name(target_zone)]) już jest opaska.</span>")
		return FALSE
	var/obj/item/bodypart/limb = patient.get_bodypart(target_zone)
	if(limb && !IS_ORGANIC_LIMB(limb))
		to_chat(user, "<span class='warning'>Opaska nic nie da na protezie.</span>")
		return FALSE
	if(target_zone == BODY_ZONE_HEAD && !limb)
		return FALSE
	var/self = user == patient
	// Czasy z tg: 5 s, bez krwawiącej rany i na szyi dwa razy dłużej, na cudzej kończynie dwa razy krócej
	var/apply_time = 5 SECONDS
	if(limb && !LAZYACCESS(patient.aq_limb_bleed, target_zone) && !limb.get_wound(WOUND_SLASH))
		apply_time *= 2
	if(target_zone == BODY_ZONE_HEAD)
		apply_time *= 2
		user.visible_message("<span class='warning'>[user] zaciska opaskę uciskową na szyi [patient]!</span>", \
			"<span class='userdanger'>Zaciskasz opaskę uciskową na szyi[self ? "" : " [patient]"]... to chyba nie jest dobry pomysł?</span>")
	else
		if(!self)
			apply_time *= 0.5
		user.visible_message("<span class='notice'>[user] zaciska opaskę uciskową na kończynie [patient] ([aq_tourniquet_zone_name(target_zone)]).</span>", \
			"<span class='notice'>Zaciskasz opaskę uciskową[self ? "" : " na [patient]"] ([aq_tourniquet_zone_name(target_zone)])...</span>")
	if(!do_mob(user, patient, apply_time))
		return FALSE
	if(LAZYACCESS(patient.aq_tourniquets, target_zone) || !user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	attach(patient, target_zone)
	playsound(patient, 'sound/items/zip.ogg', 40, TRUE)
	// Ciasne zaciśnięcie boli (tg)
	if(limb)
		patient.apply_damage(5, BRUTE, limb)
		patient.adjustStaminaLoss(20)
	user.visible_message("<span class='notice'>[user] zakłada opaskę uciskową [patient] ([aq_tourniquet_zone_name(target_zone)]).</span>", \
		"<span class='notice'>Opaska siedzi mocno[self ? "" : " na [patient]"]. Nie trzymaj jej dłużej niż kilka minut.</span>")
	return TRUE

/// Zakłada opaskę bez czekania (też dla testów i zestawów komory)
/obj/item/tourniquet/proc/attach(mob/living/carbon/patient, target_zone)
	wearer = patient
	zone = target_zone
	applied_at = world.time
	next_warning = world.time + TOURNIQUET_ISCHEMIA_TIME
	forceMove(patient)
	LAZYSET(patient.aq_tourniquets, zone, src)
	var/share = LAZYACCESS(patient.aq_limb_bleed, zone)
	if(!share)
		share = guess_limb_bleed()
	if(patient.aq_limb_bleed)
		patient.aq_limb_bleed -= zone
	held_bleed = patient.aq_clamp_bleeding(share * TOURNIQUET_BLEED_BLOCK)
	if(share - held_bleed > 0)
		LAZYINITLIST(patient.aq_limb_bleed)
		patient.aq_limb_bleed[zone] = share - held_bleed
	if(zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM)
		slows_actions = TRUE
		patient.next_move_modifier += TOURNIQUET_ARM_ACTION_MOD
	RegisterSignal(patient, COMSIG_PARENT_EXAMINE, PROC_REF(on_wearer_examine))
	RegisterSignal(patient, COMSIG_PARENT_QDELETING, PROC_REF(on_wearer_deleted))
	var/atom/movable/screen/alert/aq_tourniquet/alert = patient.throw_alert("aq_tourniquet_[zone]", /atom/movable/screen/alert/aq_tourniquet)
	alert?.tourniquet = src
	patient.update_tourniquet_slowdown()
	START_PROCESSING(SSobj, src)

/// Krwawienie z kończyny, której nie śledziliśmy (np. rana sprzed założenia opaski)
/obj/item/tourniquet/proc/guess_limb_bleed()
	var/obj/item/bodypart/limb = wearer.get_bodypart(zone)
	if(!limb)
		return BLEED_CRITICAL // kikut
	. = 0
	for(var/datum/wound/slash/cut in limb.wounds)
		. += cut.initial_bleed

/// Zdejmuje opaskę z pacjenta. Zwraca krwawienie, jeśli rana wciąż jest otwarta.
/obj/item/tourniquet/proc/detach(silent = FALSE)
	var/mob/living/carbon/patient = wearer
	var/old_zone = zone
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(patient, list(COMSIG_PARENT_EXAMINE, COMSIG_PARENT_QDELETING))
	LAZYREMOVE(patient.aq_tourniquets, old_zone)
	patient.clear_alert("aq_tourniquet_[old_zone]")
	var/worn = worn_time()
	wearer = null
	zone = null
	if(slows_actions)
		slows_actions = FALSE
		patient.next_move_modifier -= TOURNIQUET_ARM_ACTION_MOD
	if(!QDELETED(patient))
		patient.update_tourniquet_slowdown()
		var/obj/item/bodypart/limb = patient.get_bodypart(old_zone)
		var/still_open = !limb || limb.get_wound(WOUND_SLASH)
		if(held_bleed > 0 && (worn < TOURNIQUET_CLOT_TIME || still_open))
			patient.aq_restore_bleeding(held_bleed)
			LAZYINITLIST(patient.aq_limb_bleed)
			patient.aq_limb_bleed[old_zone] += held_bleed
			if(!silent)
				to_chat(patient, "<span class='danger'>Krew znów płynie z rany ([aq_tourniquet_zone_name(old_zone)])!</span>")
		if(worn >= TOURNIQUET_NECROSIS_TIME && limb && old_zone != BODY_ZONE_HEAD && patient.stat != DEAD)
			patient.adjustToxLoss(min(30, 3 * (worn - TOURNIQUET_ISCHEMIA_TIME) / (1 MINUTES)))
			if(!silent)
				to_chat(patient, "<span class='userdanger'>Martwa krew z niedokrwionej kończyny ([aq_tourniquet_zone_name(old_zone)]) uderza do reszty ciała!</span>")
	held_bleed = 0

/obj/item/tourniquet/proc/worn_time()
	return wearer ? world.time - applied_at : 0

/obj/item/tourniquet/proc/get_slowdown()
	var/worn = worn_time()
	if(worn < TOURNIQUET_ISCHEMIA_TIME)
		return TOURNIQUET_BASE_SLOWDOWN
	return min(TOURNIQUET_MAX_SLOWDOWN, TOURNIQUET_BASE_SLOWDOWN + 0.25 * (worn - TOURNIQUET_ISCHEMIA_TIME) / (1 MINUTES))

/obj/item/tourniquet/proc/get_state_text()
	if(zone == BODY_ZONE_HEAD)
		return ", <b>dusi!</b>"
	var/worn = worn_time()
	if(worn >= TOURNIQUET_NECROSIS_TIME)
		return ", <b>martwica kończyny!</b>"
	if(worn >= TOURNIQUET_ISCHEMIA_TIME)
		return ", niedokrwienie"
	return ""

/obj/item/tourniquet/process(delta_time)
	if(QDELETED(wearer) || loc != wearer)
		if(wearer)
			detach(silent = TRUE)
		return PROCESS_KILL
	if(wearer.stat == DEAD || IS_IN_STASIS(wearer))
		return
	if(zone == BODY_ZONE_HEAD)
		choke(delta_time)
		return
	var/worn = worn_time()
	if(worn < TOURNIQUET_ISCHEMIA_TIME)
		return
	var/obj/item/bodypart/limb = wearer.get_bodypart(zone)
	if(!limb) // kikut nie ma czego niedokrwić
		return
	var/minutes_over = (worn - TOURNIQUET_ISCHEMIA_TIME) / (1 MINUTES)
	limb.receive_damage(brute = min(2, 0.15 + 0.15 * minutes_over) * delta_time)
	wearer.update_tourniquet_slowdown()
	if(world.time < next_warning)
		return
	next_warning = world.time + 30 SECONDS
	if(worn >= TOURNIQUET_NECROSIS_TIME)
		to_chat(wearer, "<span class='userdanger'>Nie czujesz kończyny ([aq_tourniquet_zone_name(zone)]). Jest sina i zimna, tkanki obumierają!</span>")
	else
		to_chat(wearer, "<span class='danger'>Kończyna pod opaską ([aq_tourniquet_zone_name(zone)]) drętwieje i boli.</span>")
	if(limb.held_index && prob(50))
		var/obj/item/held = wearer.get_item_for_held_index(limb.held_index)
		if(held && wearer.dropItemToGround(held))
			to_chat(wearer, "<span class='warning'>Zdrętwiałe palce wypuszczają [held]!</span>")

/// Opaska na szyi (tg): brak oddechu i krwi do mózgu
/obj/item/tourniquet/proc/choke(delta_time)
	if(HAS_TRAIT(wearer, TRAIT_NOBREATH))
		return
	wearer.losebreath += 1 * delta_time
	wearer.adjustOxyLoss(1 * delta_time)
	if(DT_PROB(6, delta_time))
		wearer.adjustStaminaLoss(10)
	if(DT_PROB(5, delta_time))
		wearer.blur_eyes(2)
	if(DT_PROB(4, delta_time))
		wearer.Dizzy(4)
		wearer.confused = max(wearer.confused, 2)

/obj/item/tourniquet/proc/on_wearer_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='warning'>Ma założoną opaskę uciskową ([aq_tourniquet_zone_name(zone)]) od [DisplayTimeText(worn_time())][get_state_text()]. <a href='byond://?src=[REF(src)];remove=1'>Zdejmij</a></span>"

/obj/item/tourniquet/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	var/turf/drop_turf = get_turf(wearer)
	detach(silent = TRUE)
	if(drop_turf)
		forceMove(drop_turf)
	else
		qdel(src)

/obj/item/tourniquet/Topic(href, list/href_list)
	. = ..()
	if(!href_list["remove"] || !wearer)
		return
	var/mob/living/user = usr
	if(!istype(user) || user.incapacitated() || !user.Adjacent(wearer))
		return
	INVOKE_ASYNC(src, PROC_REF(try_remove), user)

/obj/item/tourniquet/proc/try_remove(mob/living/user)
	var/mob/living/carbon/patient = wearer
	if(!patient)
		return FALSE
	var/self = user == patient
	user.visible_message("<span class='notice'>[user] luzuje opaskę uciskową [patient] ([aq_tourniquet_zone_name(zone)]).</span>", \
		"<span class='notice'>Luzujesz opaskę uciskową[self ? "" : " [patient]"]...</span>")
	if(!do_mob(user, patient, 2 SECONDS) || wearer != patient)
		return FALSE
	detach()
	forceMove(patient.drop_location())
	user.put_in_hands(src)
	user.visible_message("<span class='notice'>[user] zdejmuje opaskę uciskową z [patient].</span>", "<span class='notice'>Zdejmujesz opaskę uciskową.</span>")
	return TRUE

/atom/movable/screen/alert/aq_tourniquet
	name = "Opaska uciskowa"
	desc = "Masz założoną opaskę uciskową. Po kilku minutach kończyna zaczyna obumierać. Kliknij, żeby ją zdjąć."
	icon = 'aquila/icons/hud/screen_alert_bleeding.dmi'
	icon_state = "bleed_bandage"
	var/obj/item/tourniquet/tourniquet

/atom/movable/screen/alert/aq_tourniquet/Destroy()
	tourniquet = null
	return ..()

/atom/movable/screen/alert/aq_tourniquet/Click(location, control, params)
	. = ..()
	var/mob/living/user = usr
	if(!istype(user) || user != tourniquet?.wearer || user.incapacitated())
		return
	INVOKE_ASYNC(tourniquet, TYPE_PROC_REF(/obj/item/tourniquet, try_remove), user)

// --- Rozdawanie ---

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/tourniquet/tourniquet = new(H)
	var/obj/item/storage/survival_box = box ? locate(box) in H.back : null
	if(survival_box && SEND_SIGNAL(survival_box, COMSIG_TRY_STORAGE_INSERT, tourniquet, null, TRUE, TRUE))
		return
	if(H.back && SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_INSERT, tourniquet, null, TRUE, TRUE))
		return
	if(H.equip_to_slot_if_possible(tourniquet, ITEM_SLOT_LPOCKET, disable_warning = TRUE) || H.equip_to_slot_if_possible(tourniquet, ITEM_SLOT_RPOCKET, disable_warning = TRUE))
		return
	qdel(tourniquet)

/obj/item/storage/firstaid/regular/PopulateContents()
	. = ..()
	if(!empty)
		new /obj/item/tourniquet(src)

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/tourniquet] = 6
	return ..()

/obj/machinery/vending/wallmed/Initialize(mapload)
	products[/obj/item/tourniquet] = 2
	return ..()

#undef TOURNIQUET_ISCHEMIA_TIME
#undef TOURNIQUET_NECROSIS_TIME
#undef TOURNIQUET_CLOT_TIME
#undef TOURNIQUET_BASE_SLOWDOWN
#undef TOURNIQUET_MAX_SLOWDOWN
#undef TOURNIQUET_BLEED_BLOCK
#undef TOURNIQUET_ARM_ACTION_MOD
