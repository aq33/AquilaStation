// Mięsoczłowiek (Beefman) z Fulpstation: fulp_modules/features/species/beefmen/.
// Ciało z wołowiny: odrywa i przyczepia sobie kończyny, krwawi sokiem w cieple, nie śpi i widzi rozdarcia Fobetora (beefman_phobetor.dm).
// Różnice względem oryginału (u nas inny system części ciała i krwawienia):
// - oczy i usta to nakładki BODY_LAYER zamiast body_markings tg;
// - sok cieknie przez nasze krwawienie per kończyna (blood_limbs.dm), opatrunek i opaska uciskowa go zatrzymują;
// - kończyna zmienia się w płat mięsa tylko przy oderwaniu przez właściciela, odcięciu i rozerwaniu ciała,
//   bo inne drop_limb() (klonowanie, maszyny, amputacja) dalej używają kończyny;
// - utrzymuje 20°C przez natural_bodytemperature_stabilization() (NSV13 robi termoregulację na gatunku).

/// Polska nazwa wysmażenia -> kolor mięsa (bez #)
GLOBAL_LIST_INIT(beefman_colors, list(
	"Bardzo krwisty" = "d93356",
	"Krwisty" = "da2e4a",
	"Średnio krwisty" = "e73f4e",
	"Średnio wysmażony" = "f05b68",
	"Prawie wysmażony" = "e76b76",
	"Dobrze wysmażony" = "d36b75",
))

/// Polska nazwa oczu -> stan ikony "[stan]_head"
GLOBAL_LIST_INIT(beefman_eyes, list(
	"Oliwki" = "olives",
	"Kapary" = "capers",
	"Goździki" = "cloves",
	"Ziarna pieprzu" = "peppercorns",
))

/// Polska nazwa ust -> stan ikony "[stan]_head"
GLOBAL_LIST_INIT(beefman_mouths, list(
	"Uśmiech" = "smile",
	"Uśmieszek" = "smirk",
	"Grymas" = "frown",
	"Rozczarowanie" = "disappointing",
	"Zaciśnięte zęby" = "grit",
	"Wymuszony uśmiech" = "grittingsmile",
))

GLOBAL_LIST_INIT(beefman_experiment_names, list(
	"Eksperyment", "Próba", "Obiekt", "Test", "Badanie", "Operacja", "Protokół", "Porażka", "Odrzut", "Studium",
	"Doświadczenie", "Obserwacja", "Próbka", "Przypadek", "Eksponat", "Okaz", "Prototyp", "Typ", "Wersja", "Szczep", "SCP",
))

GLOBAL_LIST_INIT(beefman_beef_names, list(
	"Stek", "Tatar", "Antrykot", "Polędwica", "Zrazowa", "Łata", "Schab", "Golonka", "Chudzina", "Marmurek",
	"Krwisty", "Szponder", "Mostek", "Ozór", "Policzek", "Rumsztyk", "Kotlet", "Grill", "Przypiek", "Pieczeń", "Smażony",
))

GLOBAL_LIST_INIT(beefman_russian_names, list(
	"Iwanow", "Smirnow", "Kuzniecow", "Popow", "Wasiljew", "Pietrow", "Sokołow", "Michajłow", "Fiodorow", "Morozow",
	"Wołkow", "Aleksiejew", "Lebiediew", "Siemionow", "Jegorow", "Pawłow", "Kozłow", "Stiepanow", "Nikołajew", "Orłow",
	"Traktor", "Romanow", "Ruczkin", "Rykow", "Putiłow", "Plisiecki", "Pierwak", "Patruszew", "Niemcow", "Noskow",
	"Morienow", "Maksudow", "Lewkin", "Łużkow", "Kazak", "Korablin", "Ziomin", "Żydkow", "Żurow", "Jesipow",
	"Diogtiew", "Gagolin", "Gagarin", "Warennikow", "Woroncow", "Błażenow", "Bondarczuk", "Baburin", "Achremienko", "Antonowicz",
	"Alochin", "Igumnow", "Zykow", "Siergiejew", "Statnik", "Suworow", "Tymoszenko", "Trufanow", "Uglicki", "Usaczow",
	"Fomienkow", "Chlebnikow", "Chromow", "Cwietnow", "Cyrinski", "Szczepkin", "Engowatow", "Jumatow", "Juszkow", "Jakubowicz",
	"Ambamow", "Anatolij", "Aleksandrow", "Andriejew", "Aparin", "Asimow", "Rajdenowicz", "Rajkow", "Wołgin", "Bakunin",
	"Kropotkin", "Rasputin", "Bielecki", "Barszczow", "Czechow", "Czernow", "Dmitrijew", "Dubinski", "Dymitr", "Stachanow",
	"Kałasznikow", "Maksym", "Mirski", "Mołotow", "Płotkin", "Sławiński", "Winski", "Wolski", "Zacharow",
))

/// Imię mięsoczłowieka: „Obiekt XIV Stek” albo „Próba III Iwanow”
/proc/beefman_name()
	var/list/last_names = prob(50) ? GLOB.beefman_russian_names : GLOB.beefman_beef_names
	return "[pick(GLOB.beefman_experiment_names)] \Roman[rand(1, 49)] [pick(last_names)]"

/proc/random_unique_beefman_name(attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(beefman_name())
		if(!findname(.))
			break

/datum/species/beefman
	name = "\improper Mięsoczłowiek"
	id = SPECIES_BEEFMAN
	sexes = 0
	default_color = "e73f4e"
	fixed_mut_color = "e73f4e"
	// DYNCOLORS jak eteryk: kolor ciała z wyboru wysmażenia, bez zwykłego koloru mutanta w oknie postaci
	species_traits = list(DYNCOLORS, HAIR, NOEYESPRITES, NO_UNDERWEAR, AGENDER)
	inherent_traits = list(TRAIT_EASYDISMEMBER, TRAIT_GENELESS, TRAIT_RESISTCOLD, TRAIT_SLEEPIMMUNE)
	default_features = list(
		"body_size" = "Normal",
		FEATURE_BEEF_COLOR = "Średnio krwisty",
		FEATURE_BEEF_EYES = "Oliwki",
		FEATURE_BEEF_MOUTH = "Uśmiech",
	)
	// Ciało mięsoczłowieka jest wyższe o 2-3 piksele, a dłonie wiszą niżej (offsety z oryginału)
	offset_features = list(
		OFFSET_UNIFORM = list(0, 2),
		OFFSET_ID = list(0, 2),
		OFFSET_GLOVES = list(0, -4),
		OFFSET_GLASSES = list(0, 3),
		OFFSET_EARS = list(0, 2),
		OFFSET_SHOES = list(0, 0),
		OFFSET_S_STORE = list(0, 2),
		OFFSET_FACEMASK = list(0, 3),
		OFFSET_HEAD = list(0, 3),
		OFFSET_FACE = list(0, 3),
		OFFSET_BELT = list(0, 3),
		OFFSET_BACK = list(0, 2),
		OFFSET_SUIT = list(0, 2),
		OFFSET_NECK = list(0, 2),
		OFFSET_RIGHT_HAND = list(0, -4),
		OFFSET_LEFT_HAND = list(0, -4),
	)
	hair_color = "mutcolor"
	use_skintones = FALSE
	heatmod = 0.5
	armor = -20 // bez skóry: 20% więcej obrażeń (damage_modifier = -20)
	siemens_coeff = 0.7
	speedmod = -0.2 // w oryginale każda noga -0.1
	punchdamage = 5
	attack_sound = 'aquila/sound/species/beefman/beef_hit.ogg'
	grab_sound = 'aquila/sound/species/beefman/beef_grab.ogg'
	deathsound = 'aquila/sound/species/beefman/beef_die.ogg'
	species_language_holder = /datum/language_holder/beefman
	mutant_brain = /obj/item/organ/brain/beefman
	mutanttongue = /obj/item/organ/tongue/beefman
	skinned_type = /obj/item/food/meatball
	meat = /obj/item/food/meat/slab
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_chest = /obj/item/bodypart/chest/beef
	species_head = /obj/item/bodypart/head/beef
	species_l_arm = /obj/item/bodypart/l_arm/beef
	species_r_arm = /obj/item/bodypart/r_arm/beef
	species_l_leg = /obj/item/bodypart/l_leg/beef
	species_r_leg = /obj/item/bodypart/r_leg/beef

	/// Odwodnienie od soli: przez tyle cykli życia krwawi mocniej i nie odnawia soku
	var/dehydrated = 0
	/// Strefa -> ile krwawienia tej strefy to sok mięsoczłowieka (reszta to zwykłe rany)
	var/list/juice_bleed = list()
	/// Strefy, które można oderwać i przyczepić z płata mięsa
	var/static/list/tearable_limbs = list(
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

/mob/living/carbon/human/species/beefman
	race = /datum/species/beefman

/datum/species/beefman/random_name(gender, unique, lastname, attempts)
	if(unique)
		return random_unique_beefman_name(attempts || 10)
	return capitalize(beefman_name())

/datum/species/beefman/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	var/mob/living/carbon/human/H = C
	if(istype(H))
		beefman_validate_features(H)
		fixed_mut_color = GLOB.beefman_colors[H.dna.features[FEATURE_BEEF_COLOR]]
		H.dna.features["mcolor"] = fixed_mut_color // włosy ("mutcolor") mają kolor mięsa
	// Od razu chłodne, inaczej na starcie rundy krwawiłoby, zanim ostygnie
	C.bodytemperature = BEEFMAN_BODYTEMP_NORMAL
	. = ..()
	RegisterSignal(C, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	if(!istype(C, /mob/living/carbon/human/dummy) && !C.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor))
		C.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/species/beefman/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	set_juice_bleeding(C, 0)
	UnregisterSignal(C, COMSIG_PARENT_ATTACKBY)
	C.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()

/// Brakujące albo nieznane cechy (stara postać, losowy człowiek) dostają losową wartość
/datum/species/beefman/proc/beefman_validate_features(mob/living/carbon/human/H)
	if(!(H.dna.features[FEATURE_BEEF_COLOR] in GLOB.beefman_colors))
		H.dna.features[FEATURE_BEEF_COLOR] = pick(GLOB.beefman_colors)
	if(!(H.dna.features[FEATURE_BEEF_EYES] in GLOB.beefman_eyes))
		H.dna.features[FEATURE_BEEF_EYES] = pick(GLOB.beefman_eyes)
	if(!(H.dna.features[FEATURE_BEEF_MOUTH] in GLOB.beefman_mouths))
		H.dna.features[FEATURE_BEEF_MOUTH] = pick(GLOB.beefman_mouths)

/// Oczy i usta z przypraw, rysowane na głowie
/datum/species/beefman/handle_body(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !IS_ORGANIC_LIMB(head) || HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/eyes = GLOB.beefman_eyes[H.dna.features[FEATURE_BEEF_EYES]] || "olives"
	var/mouth = GLOB.beefman_mouths[H.dna.features[FEATURE_BEEF_MOUTH]] || "smile"
	var/list/standing = list()
	var/old_overlays = H.overlays_standing[BODY_LAYER]
	if(islist(old_overlays))
		standing += old_overlays
	else if(old_overlays)
		standing += old_overlays
	standing += mutable_appearance(BEEFMAN_BODYPARTS_ICON, "[eyes]_head", -BODY_LAYER)
	standing += mutable_appearance(BEEFMAN_BODYPARTS_ICON, "[mouth]_head", -BODY_LAYER)
	H.remove_overlay(BODY_LAYER)
	H.overlays_standing[BODY_LAYER] = standing
	H.apply_overlay(BODY_LAYER)

/// Ciało wraca do 20°C, nie do 37°C (bodytemp_normal = T20C w oryginale)
/datum/species/beefman/natural_bodytemperature_stabilization(mob/living/carbon/human/human_holder)
	if(HAS_TRAIT(human_holder, TRAIT_COLDBLOODED))
		return ..()
	var/difference = BEEFMAN_BODYTEMP_NORMAL - human_holder.bodytemperature
	if(human_holder.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		return min(difference / BODYTEMP_AUTORECOVERY_DIVISOR, -BODYTEMP_AUTORECOVERY_MINIMUM)
	if(difference >= 0)
		return max(difference * human_holder.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, min(difference, BODYTEMP_AUTORECOVERY_MINIMUM / 4))
	return min(difference * human_holder.metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, max(difference, -BODYTEMP_AUTORECOVERY_MINIMUM / 4))

/datum/species/beefman/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
	handle_juices(H)

/// Sok cieknie powyżej 25°C, mniej z przypieczonych kończyn, mocniej po soli. Bez krwawienia sok się odnawia.
/datum/species/beefman/proc/handle_juices(mob/living/carbon/human/H)
	var/burnt = 0
	for(var/obj/item/bodypart/limb as anything in H.bodyparts)
		if(IS_ORGANIC_LIMB(limb))
			burnt += limb.burn_dam
	var/level = (H.bodytemperature - BEEFMAN_BLEEDOUT_LEVEL) / 20 - burnt / 30
	if(dehydrated)
		dehydrated--
		set_juice_bleeding(H, clamp(level, 2, 10) * BEEFMAN_JUICE_PER_LEVEL)
		return
	set_juice_bleeding(H, clamp(level, 0, 5) * BEEFMAN_JUICE_PER_LEVEL)
	if(H.blood_volume >= BLOOD_VOLUME_NORMAL || H.is_bleeding())
		return
	H.blood_volume = min(H.blood_volume + 4, BLOOD_VOLUME_NORMAL)

/// Ustawia krwawienie sokiem na każdej organicznej kończynie. Opatrzona albo zaciśnięta opaską kończyna soku nie puszcza.
/datum/species/beefman/proc/set_juice_bleeding(mob/living/carbon/human/H, rate)
	if(HAS_TRAIT(H, TRAIT_NO_BLOOD) || (NOBLOOD in species_traits))
		rate = 0
	var/datum/status_effect/bleeding/bleed = H.get_bleed_status()
	var/list/zones = list()
	for(var/obj/item/bodypart/limb as anything in H.bodyparts)
		zones[limb.body_zone] = IS_ORGANIC_LIMB(limb) ? rate : 0
	for(var/zone in juice_bleed)
		if(!(zone in zones))
			zones[zone] = 0 // kikut: sok już nie cieknie
	for(var/zone in zones)
		var/target = zones[zone]
		if(target > 0 && ((bleed && bleed.limb_bandaged[zone]) || LAZYACCESS(H.aq_tourniquets, zone)))
			target = 0
		var/current = bleed ? min(juice_bleed[zone] || 0, bleed.limb_bleed[zone] || 0) : 0
		var/delta = target - current
		if(delta > 0)
			if(!bleed)
				bleed = H.apply_status_effect(bleed_effect, 0, zone)
				if(!bleed)
					return
			bleed.change_limb_bleeding(zone, delta)
		else if(delta < 0 && bleed)
			bleed.change_limb_bleeding(zone, delta)
		if(target > 0)
			juice_bleed[zone] = target
		else
			juice_bleed -= zone
	if(bleed && !QDELETED(bleed))
		bleed.update_icon()

/// Sól wysusza mięso: przez kilka cykli krwawi mocniej
/mob/living/proc/beefman_dehydrate()
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !isbeefman(H))
		return
	var/datum/species/beefman/beef = H.dna.species
	if(!beef.dehydrated || prob(10))
		to_chat(H, span_alert("Twoje mięsiste usta są wysuszone."))
	beef.dehydrated++

/datum/reagent/consumable/sodiumchloride/on_mob_metabolize(mob/living/L)
	. = ..()
	L.beefman_dehydrate()

/datum/reagent/saltpetre/on_mob_metabolize(mob/living/L)
	. = ..()
	L.beefman_dehydrate()

// --- Dotyk i kończyny ---

/// Przytulony brudzi się sokiem
/datum/species/beefman/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user != target)
		target.add_mob_blood(user)
	return ..()

/// Prawy przycisk (intencja rozbrajania) na sobie pustą ręką: oderwij wskazaną kończynę albo język
/datum/species/beefman/disarm(mob/living/carbon/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user != target || !ishuman(user))
		return ..()
	var/zone = beefman_zone(user.zone_selected)
	if(!(zone in tearable_limbs))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(tear_off), user, zone)
	return TRUE

/// Usta zostają ustami, reszta jak check_zone (dłoń -> ręka)
/datum/species/beefman/proc/beefman_zone(zone)
	return zone == BODY_ZONE_PRECISE_MOUTH ? zone : check_zone(zone)

/datum/species/beefman/proc/tear_off(mob/living/carbon/human/user, zone)
	if(user in user.do_afters)
		return FALSE
	if(zone == BODY_ZONE_PRECISE_MOUTH)
		var/obj/item/organ/tongue/tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			return FALSE
		user.visible_message(span_notice("[user] chwyta się za język i ciągnie."), span_notice("Chwytasz się za język i mocno szarpiesz."))
		if(!do_after(user, 1 SECONDS, target = user))
			return FALSE
		return tear_off_now(user, zone)

	var/obj/item/bodypart/limb = user.get_bodypart(zone)
	if(!limb)
		return FALSE
	if(!IS_ORGANIC_LIMB(limb))
		to_chat(user, span_warning("To trzyma się mocno. Delikatnym szarpnięciem tego nie oderwiesz."))
		return FALSE
	user.visible_message(span_notice("[user] chwyta się za [strefa_pl(zone, TRUE)] i ciągnie."), span_notice("Chwytasz się za [strefa_pl(zone, TRUE)] i mocno szarpiesz."))
	if(!do_after(user, 3 SECONDS, target = user))
		return FALSE
	return tear_off_now(user, zone)

/// Oderwanie bez czekania: język albo kończyna ląduje w ręce jako płat mięsa. Zwraca to, co oderwano.
/datum/species/beefman/proc/tear_off_now(mob/living/carbon/human/user, zone)
	if(zone == BODY_ZONE_PRECISE_MOUTH)
		var/obj/item/organ/tongue/tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			return null
		tongue.Remove(user)
		qdel(tongue)
		var/obj/item/food/meat/slab/tongue_meat = new(user.drop_location())
		user.put_in_hands(tongue_meat)
		playsound(user, 'aquila/sound/species/beefman/beef_hit.ogg', 40, TRUE)
		return tongue_meat

	var/obj/item/bodypart/limb = user.get_bodypart(zone)
	if(!limb || !IS_ORGANIC_LIMB(limb))
		return null
	user.visible_message(span_notice("[user] odrywa sobie [strefa_pl(zone, TRUE)]!"), span_notice("Twoja [strefa_pl(zone)] odskakuje bez oporu."))
	playsound(user, 'aquila/sound/species/beefman/beef_hit.ogg', 40, TRUE)
	limb.drop_limb()
	// Kończyna z innego gatunku po prostu odpada, nasza zmienia się w płat mięsa
	var/obj/item/to_hold = limb
	if(limb.limb_id == SPECIES_BEEFMAN)
		to_hold = limb.beefman_to_meat(user)
	if(to_hold)
		user.put_in_hands(to_hold)
	return to_hold

/// Płat mięsa wciśnięty w kikut (albo w usta bez języka) staje się nową kończyną (językiem)
/datum/species/beefman/proc/on_attackby(mob/living/carbon/human/source, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	if(!istype(item, /obj/item/food/meat/slab) || !isliving(user))
		return
	var/zone = beefman_zone(user.zone_selected)
	if(!(zone in tearable_limbs))
		return
	if(zone == BODY_ZONE_PRECISE_MOUTH)
		if(source.getorganslot(ORGAN_SLOT_TONGUE) || !source.get_bodypart(BODY_ZONE_HEAD))
			return
	else if(source.get_bodypart(zone))
		return
	INVOKE_ASYNC(src, PROC_REF(mash_meat), source, item, user, zone)
	return COMPONENT_NO_AFTERATTACK

/datum/species/beefman/proc/mash_meat(mob/living/carbon/human/beefboy, obj/item/food/meat/slab/meat, mob/living/user, zone)
	if(beefboy in user.do_afters)
		return
	user.visible_message(span_notice("[user] zaczyna wciskać [meat] w [beefboy]."), span_notice("Zaczynasz wciskać [meat] w [beefboy]."))
	if(!do_after(user, 2 SECONDS, target = beefboy) || QDELETED(meat))
		return
	attach_meat(beefboy, meat, zone)

/// Wrośnięcie mięsa bez czekania. Zwraca nową kończynę albo język, null gdy miejsce jest zajęte.
/datum/species/beefman/proc/attach_meat(mob/living/carbon/human/beefboy, obj/item/food/meat/slab/meat, zone)
	if(!isbeefman(beefboy))
		return null
	if(zone == BODY_ZONE_PRECISE_MOUTH)
		if(beefboy.getorganslot(ORGAN_SLOT_TONGUE) || !beefboy.get_bodypart(BODY_ZONE_HEAD))
			return null
		var/obj/item/organ/tongue/beefman/new_tongue = new()
		new_tongue.Insert(beefboy)
		beefboy.visible_message(span_notice("[capitalize(meat.name)] wypuszcza pędy i staje się nowym językiem [beefboy]!"), span_notice("Mięso zrasta się z twoimi ustami!"))
		. = new_tongue
	else
		if(beefboy.get_bodypart(zone))
			return null
		var/obj/item/bodypart/new_limb = beefboy.newBodyPart(zone, FALSE, FALSE)
		new_limb.replace_limb(beefboy, FALSE, TRUE)
		beefboy.visible_message(span_notice("Mięso wypuszcza palce i wrasta w [beefboy] jako [strefa_pl(zone)]!"), span_notice("Mięso wypuszcza palce i staje się twoją nową kończyną: [strefa_pl(zone)]!"))
		new_limb.beefman_take_meat(beefboy, meat)
		. = new_limb
	qdel(meat)
	playsound(beefboy, 'aquila/sound/species/beefman/beef_grab.ogg', 50, TRUE)

/// Nowa kończyna z płata mięsa: nadgryzione mięso daje uszkodzoną kończynę, a reszta odczynników z mięsa trafia do krwi
/obj/item/bodypart/proc/beefman_take_meat(mob/living/carbon/human/beefboy, obj/item/food/meat/slab/meat)
	var/amount_original = 0
	for(var/reagent_type in meat.food_reagents)
		amount_original += meat.food_reagents[reagent_type]
	var/amount_current = 0
	for(var/datum/reagent/reagent as anything in meat.reagents.reagent_list.Copy())
		if(!(reagent.type in meat.food_reagents))
			continue
		amount_current += reagent.volume
		meat.reagents.remove_reagent(reagent.type, reagent.volume)
	var/damaged_percent = amount_original ? clamp(1 - amount_current / amount_original, 0, 1) : 0
	if(damaged_percent > 0)
		receive_damage(brute = max_damage * damaged_percent)
	if(damaged_percent >= 0.9)
		to_chat(beefboy, span_alert("Prawie do niczego się nie nadaje. To mięso było do bani!"))
	else if(damaged_percent > 0.5)
		to_chat(beefboy, span_alert("[capitalize(meat.name)] jest całe w śladach zębów..."))
	else if(damaged_percent > 0)
		to_chat(beefboy, span_alert("[capitalize(meat.name)] jest trochę nadjedzone, ale ujdzie."))
	if(meat.reagents.total_volume)
		meat.reagents.trans_to(beefboy, meat.reagents.total_volume, ignore_stomach = TRUE)

/// Odłączona kończyna mięsoczłowieka zmienia się w płat mięsa: tym mniej odżywczy, im bardziej była uszkodzona.
/// Zwraca mięso. Kończyna znika, a to, co w niej tkwiło, spada na podłogę.
/obj/item/bodypart/proc/beefman_to_meat(mob/living/carbon/old_owner)
	if(owner || !IS_ORGANIC_LIMB(src))
		return null
	var/turf/drop_turf = get_turf(src) || get_turf(old_owner)
	if(!drop_turf)
		return null
	var/health_percent = max_damage ? clamp(1 - (brute_dam + burn_dam) / max_damage, 0, 1) : 1
	var/obj/item/food/meat/slab/new_meat = new(drop_turf)
	for(var/datum/reagent/reagent as anything in new_meat.reagents.reagent_list)
		reagent.volume *= health_percent
	new_meat.reagents.update_total()
	if(old_owner?.reagents?.total_volume)
		old_owner.reagents.trans_to(new_meat, 20)
	for(var/obj/item/stuck in src)
		stuck.forceMove(drop_turf)
	qdel(src)
	return new_meat

/// Rozerwane ciało mięsoczłowieka: ręce i nogi rozlatują się jako płaty mięsa
/mob/living/carbon/human/spread_bodyparts()
	var/list/meat_limbs = list()
	if(isbeefman(src))
		for(var/obj/item/bodypart/limb as anything in bodyparts)
			if(limb.limb_id == SPECIES_BEEFMAN && (limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
				meat_limbs += limb
	. = ..()
	for(var/obj/item/bodypart/limb as anything in meat_limbs)
		if(!QDELETED(limb) && !limb.owner)
			limb.beefman_to_meat(src)

// --- Ubiór: szarfa zamiast kombinezonu ---

/// Kombinezon z zawodu zamienia się w szarfę działu. Szarfa przejmuje pancerz i czujniki kombinezonu, kieszenie i identyfikator zostają.
/datum/species/beefman/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	. = ..()
	var/sash_type = beefman_sash_for_job(J?.title)
	var/obj/item/clothing/under/old_uniform = H.w_uniform
	if(istype(old_uniform, /obj/item/clothing/under/bodysash))
		return
	var/obj/item/clothing/under/bodysash/sash = new sash_type()
	if(istype(old_uniform))
		sash.armor = old_uniform.armor
		sash.has_sensor = old_uniform.has_sensor
		sash.sensor_mode = old_uniform.sensor_mode
		sash.random_sensor = old_uniform.random_sensor
		H.temporarilyRemoveItemFromInventory(old_uniform, TRUE, FALSE)
		qdel(old_uniform)
	if(!H.equip_to_slot_or_del(sash, ITEM_SLOT_ICLOTHING))
		return
	H.update_suit_sensors()

/// Typ szarfy dla zawodu (nazwy zawodów u nas są polskie, JOB_NAME_*)
/proc/beefman_sash_for_job(title)
	var/static/list/sashes = list(
		JOB_NAME_CAPTAIN = /obj/item/clothing/under/bodysash/captain,
		JOB_NAME_HEADOFPERSONNEL = /obj/item/clothing/under/bodysash/hop,
		JOB_NAME_ASSISTANT = /obj/item/clothing/under/bodysash,
		JOB_NAME_BARTENDER = /obj/item/clothing/under/bodysash/bartender,
		JOB_NAME_BOTANIST = /obj/item/clothing/under/bodysash/botanist,
		JOB_NAME_COOK = /obj/item/clothing/under/bodysash/cook,
		JOB_NAME_JANITOR = /obj/item/clothing/under/bodysash/janitor,
		JOB_NAME_CURATOR = /obj/item/clothing/under/bodysash/curator,
		JOB_NAME_LAWYER = /obj/item/clothing/under/bodysash/lawyer,
		JOB_NAME_CHAPLAIN = /obj/item/clothing/under/bodysash/chaplain,
		JOB_NAME_MIME = /obj/item/clothing/under/bodysash/mime,
		JOB_NAME_CLOWN = /obj/item/clothing/under/bodysash/clown,
		JOB_NAME_QUARTERMASTER = /obj/item/clothing/under/bodysash/qm,
		JOB_NAME_CARGOTECHNICIAN = /obj/item/clothing/under/bodysash/cargo,
		JOB_NAME_SHAFTMINER = /obj/item/clothing/under/bodysash/miner,
		JOB_NAME_BITRUNNER = /obj/item/clothing/under/bodysash/cargo,
		JOB_NAME_CHIEFENGINEER = /obj/item/clothing/under/bodysash/engineer/ce,
		JOB_NAME_STATIONENGINEER = /obj/item/clothing/under/bodysash/engineer,
		JOB_NAME_ATMOSPHERICTECHNICIAN = /obj/item/clothing/under/bodysash/engineer/atmos,
		JOB_NAME_CHIEFMEDICALOFFICER = /obj/item/clothing/under/bodysash/medical/cmo,
		JOB_NAME_MEDICALDOCTOR = /obj/item/clothing/under/bodysash/medical,
		JOB_NAME_PARAMEDIC = /obj/item/clothing/under/bodysash/medical/paramedic,
		JOB_NAME_CHEMIST = /obj/item/clothing/under/bodysash/medical/chemist,
		JOB_NAME_VIROLOGIST = /obj/item/clothing/under/bodysash/medical/virologist,
		JOB_NAME_GENETICIST = /obj/item/clothing/under/bodysash/geneticist,
		JOB_NAME_BRIGPHYSICIAN = /obj/item/clothing/under/bodysash/medical,
		JOB_NAME_PSYCHIATRIST = /obj/item/clothing/under/bodysash/psychologist,
		JOB_NAME_RESEARCHDIRECTOR = /obj/item/clothing/under/bodysash/rd,
		JOB_NAME_SCIENTIST = /obj/item/clothing/under/bodysash/scientist,
		JOB_NAME_ROBOTICIST = /obj/item/clothing/under/bodysash/roboticist,
		JOB_NAME_EXPLORATIONCREW = /obj/item/clothing/under/bodysash/scientist,
		JOB_NAME_HEADOFSECURITY = /obj/item/clothing/under/bodysash/security/hos,
		JOB_NAME_WARDEN = /obj/item/clothing/under/bodysash/security/warden,
		JOB_NAME_SECURITYOFFICER = /obj/item/clothing/under/bodysash/security,
		JOB_NAME_DETECTIVE = /obj/item/clothing/under/bodysash/security/detective,
		JOB_NAME_DEPUTY = /obj/item/clothing/under/bodysash/security/deputy,
		JOB_NAME_MASTERATARMS = /obj/item/clothing/under/bodysash/command,
		JOB_NAME_BRIDGESTAFF = /obj/item/clothing/under/bodysash/command,
		JOB_NAME_AIRTRAFFICCONTROLLER = /obj/item/clothing/under/bodysash/command,
		JOB_NAME_MUNITIONSTECHNICIAN = /obj/item/clothing/under/bodysash/engineer,
		JOB_NAME_DECKTECHNICIAN = /obj/item/clothing/under/bodysash/engineer,
		JOB_NAME_PILOT = /obj/item/clothing/under/bodysash/official,
		JOB_NAME_PRISONER = /obj/item/clothing/under/bodysash/prisoner,
	)
	return sashes[title] || /obj/item/clothing/under/bodysash/civilian

// --- Części ciała ---

/obj/item/bodypart/head/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	is_dimorphic = FALSE
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

/obj/item/bodypart/chest/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	is_dimorphic = FALSE
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

/obj/item/bodypart/l_arm/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

/obj/item/bodypart/r_arm/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

/obj/item/bodypart/l_leg/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

/obj/item/bodypart/r_leg/beef
	icon = BEEFMAN_BODYPARTS_ICON
	limb_id = SPECIES_BEEFMAN
	heavy_brute_msg = "zmielona na mielone"
	heavy_burn_msg = "spieczona na węgiel"

// Odcięta kończyna mięsoczłowieka spada jako płat mięsa (oryginał: drop_limb() bez special)

/obj/item/bodypart/l_arm/beef/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(. && !QDELETED(src) && !owner)
		beefman_to_meat(old_owner)

/obj/item/bodypart/r_arm/beef/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(. && !QDELETED(src) && !owner)
		beefman_to_meat(old_owner)

/obj/item/bodypart/l_leg/beef/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(. && !QDELETED(src) && !owner)
		beefman_to_meat(old_owner)

/obj/item/bodypart/r_leg/beef/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(. && !QDELETED(src) && !owner)
		beefman_to_meat(old_owner)

// --- Narządy ---

/obj/item/organ/brain/beefman
	name = "mózg z mielonego mięsa"
	desc = "Niewytłumaczalnie sprawny mózg mięsoczłowieka. Niektóre jego części wyglądają na nie do naprawienia..."

/// Mózg mięsoczłowieka niesie bezsenność i rozdarcia Fobetora, także w cudzej głowie
/obj/item/organ/brain/beefman/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	if(owner && !owner.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor))
		owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/item/organ/tongue/beefman
	name = "mięsisty język"
	desc = "Mięsisty, gruby mięsień, typowy dla mięsoludzi."
	icon = 'aquila/icons/mob/species/beefman/beef_tongue.dmi'
	icon_state = "beef_tongue"
	say_mod = "bulgocze"
	taste_sensitivity = 15
	liked_food = RAW | MEAT | FRIED
	disliked_food = VEGETABLES | FRUIT | CLOTH
	toxic_food = DAIRY | PINEAPPLE

// Bez tego mięsoczłowiek zna kosmiczny rosyjski, ale nie może go wybrać ani nim mówić
/obj/item/organ/tongue/beefman/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base.Copy()
	languages_possible[/datum/language/space_russian] = TRUE

// --- Język ---

/datum/language_holder/beefman
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/space_russian = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/space_russian = list(LANGUAGE_ATOM))

/datum/language/space_russian
	name = "Kosmiczny rosyjski"
	desc = "Archaiczny ziemski język, którym wciąż mówi się w Kosmicznej Rosji."
	key = "2"
	flags = TONGUELESS_SPEECH
	sentence_chance = 5
	space_chance = 50
	syllables = list(
		"bly", "bor", "cy", "da", "ko", "et", "sa", "gop", "grad", "kov",
		"ski", "vok", "nik", "cyka", "ka", "kor", "yov", "suk", "grad",
		"kov", "blyat", "vod", "ka",
	)
	icon = 'aquila/icons/mob/species/beefman/russian_language.dmi'
	icon_state = "commie"
	default_priority = 90
