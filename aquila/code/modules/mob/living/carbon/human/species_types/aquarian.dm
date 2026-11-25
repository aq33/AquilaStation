// Akwarianin: własna rasa Aquili (bez oryginału w innych kodach). Sprite'y od twórcy projektu „Fish People” z r/ss14 (Resprited Fish People V2).
// Rybka w szklanym kloszu z wodą, który siedzi na kołnierzu mechanicznego pancerza.
// - Pancerz to robotyczne części ciała jak u IPC: bez krwi, naprawa spawarką i kablami, operacje robotyczne, EMP go paraliżuje.
// - Klosz to mózg (/obj/item/organ/brain/aquarian) z wodą w reagentach. Ryba oddycha wodą: mało wody = duszenie,
//   brak wody = śmierć. Duszenie ryby trzyma klosz (fish_oxyloss) i co cykl przepisuje je na oxyloss ciała,
//   bo TRAIT_NOBREATH zeruje oxyloss w spec_life.
// - Woda ubywa z pękniętego klosza (obrażenia głowy, kałuża z modułu cieczy) i paruje w gorącu. Dolewa się ją pojemnikiem
//   kliknięciem w głowę albo pustą ręką przy umywalce. Inne reagenty z wody przechodzą do organizmu, karma dla ryb karmi.
// - Po zniszczeniu pancerza żywa rybka odpada razem z kloszem (jak mózg do MMI). Klosz można włożyć w pusty pancerz
//   (kliknięcie, operacja albo nowy pancerz z fabrykatora egzoszkieletów) albo w MMI.

/// Ile każdego reagentu (poza wodą) przechodzi z klosza do organizmu na cykl życia
#define AQUARIAN_CHEM_RATE 2
/// Ile głodu zaspokaja garść karmy dla ryb
#define AQUARIAN_FEED_NUTRITION 75
/// O ile pikseli w dół przesunięty jest klosz leżący jako przedmiot (tak jak stany dome_item w .dmi)
#define AQUARIAN_ITEM_SHIFT 14
/// Klucz modyfikatora prędkości od zimnej wody
#define AQUARIAN_COLD_SLOWDOWN "aquarian_cold"

/// Rodzaj ryby -> polska nazwa (jak ryby akwariowe w code/modules/aquarium/fish.dm). Pierwsza jest domyślna.
GLOBAL_LIST_INIT(aquarian_fish, list(
	"goldfish" = "Złota rybka",
	"clownfish" = "Błazenek",
	"pufferfish" = "Rozdymka",
	"angelfish" = "Skalar",
	"guppy" = "Gupik",
	"firefish" = "Babka ogniowa",
	"cardinalfish" = "Apogon",
	"lanternfish" = "Świetlik",
	"dwarf_moonfish" = "Karłowaty księżycowiec",
	"greenchromis" = "Chromis zielony",
	"bleak" = "Ukleja",
))

/// Szare ryby (z paczki Fish People), które barwi kolor ryby z okna postaci
GLOBAL_LIST_INIT(aquarian_tinted_fish, list("bleak"))

/// Pancerz -> nazwa w oknie postaci. Pierwszy jest domyślny.
GLOBAL_LIST_INIT(aquarian_bodies, list(
	AQUARIAN_BODY_RED = "Czerwony pancerz",
	AQUARIAN_BODY_METAL = "Goły metal",
))

/// Wzór na ramionach (stany aquarian_pattern_X_l_arm i _r_arm, barwione kolorem pancerza) -> nazwa w oknie postaci
GLOBAL_LIST_INIT(aquarian_patterns, list(
	AQUARIAN_PATTERN_NONE = "Bez wzoru",
	"sleeves" = "Rękawy",
	"stripes" = "Paski na ramionach",
))

/// Rodzaj ryby z zapisu albo domyślny
/proc/aquarian_valid_fish(fish)
	if(fish in GLOB.aquarian_fish)
		return fish
	return GLOB.aquarian_fish[1]

/// Pancerz z zapisu albo domyślny
/proc/aquarian_valid_body(body)
	if(body in GLOB.aquarian_bodies)
		return body
	return GLOB.aquarian_bodies[1]

/// Wzór z zapisu albo brak
/proc/aquarian_valid_pattern(pattern)
	if(pattern in GLOB.aquarian_patterns)
		return pattern
	return AQUARIAN_PATTERN_NONE

/// Kolor rrggbb (bez #) albo domyślny
/proc/aquarian_valid_color(color, default)
	return sanitize_hexcolor(color, 6, FALSE, default)

/datum/species/aquarian
	name = "\improper Akwarianin"
	id = SPECIES_AQUARIAN
	species_traits = list(NOBLOOD, NOMOUTH, NOEYESPRITES, NOTRANSSTING, NO_DNA_COPY, NOZOMBIE, NOHUSK, NO_UNDERWEAR, REVIVESBYHEALING)
	// Klosz i pancerz są szczelne (ciśnienie), ale zimno dalej mrozi wodę
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_LIMBATTACHMENT, TRAIT_NOTHIRST, TRAIT_NOSHITTING)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	default_features = list(
		FEATURE_AQUARIAN_FISH = "goldfish",
		FEATURE_AQUARIAN_ARMOR = AQUARIAN_DEFAULT_ARMOR,
		FEATURE_AQUARIAN_WATER = AQUARIAN_DEFAULT_WATER,
		FEATURE_AQUARIAN_BODY = AQUARIAN_BODY_RED,
		FEATURE_AQUARIAN_PATTERN = AQUARIAN_PATTERN_NONE,
		FEATURE_AQUARIAN_FISH_COLOR = AQUARIAN_DEFAULT_FISH_COLOR,
		"body_size" = "Normal",
	)
	use_skintones = FALSE
	mutant_brain = /obj/item/organ/brain/aquarian
	mutanttongue = /obj/item/organ/tongue/aquarian
	// Hełmy są w can_equip, czapki wolno
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_EYES)
	siemens_coeff = 2 // woda w kloszu przewodzi
	damage_overlay_type = "synth"
	species_gibs = GIB_TYPE_ROBOTIC
	// Mniej żelaza niż kosztuje pancerz z fabrykatora (15 arkuszy), żeby gibber nie robił z niego kopalni
	meat = /obj/item/stack/sheet/iron{amount = 2}
	skinned_type = /obj/item/stack/sheet/iron{amount = 1}
	attack_sound = 'sound/items/trayhit1.ogg'
	deathsound = 'sound/effects/bubbles.ogg'
	special_step_sounds = list('sound/effects/servostep.ogg')
	goon_voice = "blub"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP

	species_chest = /obj/item/bodypart/chest/aquarian
	species_head = /obj/item/bodypart/head/aquarian
	species_l_arm = /obj/item/bodypart/l_arm/aquarian
	species_r_arm = /obj/item/bodypart/r_arm/aquarian
	species_l_leg = /obj/item/bodypart/l_leg/aquarian
	species_r_leg = /obj/item/bodypart/r_leg/aquarian

/mob/living/carbon/human/species/aquarian
	race = /datum/species/aquarian

/datum/species/aquarian/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C) && C.dna)
		C.dna.features[FEATURE_AQUARIAN_FISH] = aquarian_valid_fish(C.dna.features[FEATURE_AQUARIAN_FISH])
		C.dna.features[FEATURE_AQUARIAN_ARMOR] = aquarian_valid_color(C.dna.features[FEATURE_AQUARIAN_ARMOR], AQUARIAN_DEFAULT_ARMOR)
		C.dna.features[FEATURE_AQUARIAN_WATER] = aquarian_valid_color(C.dna.features[FEATURE_AQUARIAN_WATER], AQUARIAN_DEFAULT_WATER)
		C.dna.features[FEATURE_AQUARIAN_BODY] = aquarian_valid_body(C.dna.features[FEATURE_AQUARIAN_BODY])
		C.dna.features[FEATURE_AQUARIAN_PATTERN] = aquarian_valid_pattern(C.dna.features[FEATURE_AQUARIAN_PATTERN])
		C.dna.features[FEATURE_AQUARIAN_FISH_COLOR] = aquarian_valid_color(C.dna.features[FEATURE_AQUARIAN_FISH_COLOR], AQUARIAN_DEFAULT_FISH_COLOR)
	. = ..()
	RegisterSignal(C, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(C, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(C, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(C, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(on_fully_heal))

/datum/species/aquarian/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, list(COMSIG_PARENT_ATTACKBY, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, COMSIG_PARENT_EXAMINE, COMSIG_LIVING_POST_FULLY_HEAL))
	C.remove_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN)
	C.clear_alert("aquarian_water")
	C.clear_alert("aquarian_leak")

/// Klosz na kołnierzu albo null
/proc/aquarian_dome(mob/living/carbon/C)
	RETURN_TYPE(/obj/item/organ/brain/aquarian)
	var/obj/item/organ/brain/aquarian/dome = C?.getorganslot(ORGAN_SLOT_BRAIN)
	return istype(dome) ? dome : null

/// TRAIT_NOBREATH zeruje oxyloss w ..(), więc duszenie ryby przepisujemy z klosza. Leczenie oxyloss lekami z wody zmniejsza je w kloszu.
/datum/species/aquarian/spec_life(mob/living/carbon/human/H)
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(H)
	if(dome)
		var/healed = dome.synced_oxyloss - H.getOxyLoss()
		if(healed > 0)
			dome.fish_oxyloss = max(0, dome.fish_oxyloss - healed)
	. = ..()
	if(dome)
		H.setOxyLoss(dome.fish_oxyloss)
		dome.synced_oxyloss = dome.fish_oxyloss

/// Klosz siedzi na pancerzu w miejscu włosów: nad ubraniem, pod czapką
/datum/species/aquarian/handle_hair(mob/living/carbon/human/H, forced_colour)
	..()
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(H)
	if(!dome || !H.get_bodypart(BODY_ZONE_HEAD))
		return
	H.overlays_standing[HAIR_LAYER] = dome.dome_overlays(-HAIR_LAYER)
	H.apply_overlay(HAIR_LAYER)

/// Zwykłe hełmy nie mieszczą się na kloszu. Czapki tak.
/datum/species/aquarian/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot == ITEM_SLOT_HEAD && istype(I, /obj/item/clothing/head/helmet))
		if(!disable_warning)
			to_chat(H, "<span class='warning'>[I] nie zmieści się na twoim kloszu!</span>")
		return FALSE
	return ..()

/datum/species/aquarian/spec_emp_act(mob/living/carbon/human/H, severity)
	to_chat(H, "<span class='userdanger'>Pancerz drętwieje od impulsu! Rybka w kloszu nerwowo krąży, ale nic jej nie jest.</span>")

/// Po zniszczeniu pancerza żywa rybka odpada razem z kloszem
/datum/species/aquarian/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquarian_eject_dome), H), 2 SECONDS)

/proc/aquarian_eject_dome(mob/living/carbon/human/H)
	if(QDELETED(H) || H.stat != DEAD || !isaquarian(H))
		return
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(H)
	if(!dome?.fish_alive())
		return
	var/turf/T = H.drop_location()
	dome.Remove(H)
	dome.forceMove(T)
	playsound(T, 'sound/machines/click.ogg', 50, TRUE)
	H.visible_message("<span class='warning'>Zniszczony pancerz [H] wyłącza się, a klosz z rybką odczepia się od kołnierza i spada na podłogę!</span>")

/datum/species/aquarian/proc/on_fully_heal(mob/living/carbon/human/source, admin_revive)
	SIGNAL_HANDLER
	aquarian_dome(source)?.refill_completely()

/datum/species/aquarian/proc/on_examine(mob/living/carbon/human/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(source)
	if(!dome)
		if(source.get_bodypart(BODY_ZONE_HEAD))
			examine_list += "<span class='warning'>Kołnierz pancerza jest pusty: nie ma na nim klosza z rybką.</span>"
		return
	examine_list += dome.water_examine_text()

/// Pojemnik z wodą albo karma dla ryb kliknięte w głowę: wlewamy do klosza zamiast pić
/datum/species/aquarian/proc/on_attackby(mob/living/carbon/human/source, obj/item/W, mob/living/user, params)
	SIGNAL_HANDLER
	if(!istype(user) || user.combat_mode || !(user.zone_selected in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)))
		return
	if(!istype(W, /obj/item/fish_feed) && !aquarian_pourable(W))
		return
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(source)
	if(!dome)
		return
	INVOKE_ASYNC(dome, TYPE_PROC_REF(/obj/item/organ/brain/aquarian, fill_from), W, user)
	return COMPONENT_NO_AFTERATTACK

/// Pusta ręka na umywalce (przy celowaniu w głowę): dolewanie wody do klosza zamiast mycia twarzy
/datum/species/aquarian/proc/on_unarmed_attack(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity || !istype(target, /obj/structure/sink) || source.combat_mode)
		return
	if(!(source.zone_selected in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)))
		return
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(source)
	if(!dome)
		return
	INVOKE_ASYNC(dome, TYPE_PROC_REF(/obj/item/organ/brain/aquarian, refill_from_sink), target, source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Naczynia, z których da się nalać do klosza (nie strzykawki, spraye ani pigułki)
/proc/aquarian_pourable(obj/item/I)
	if(!I.reagents || !I.is_drainable())
		return FALSE
	return istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks) || istype(I, /obj/item/reagent_containers/food/condiment)

/datum/species/aquarian/get_harm_descriptors()
	return list("bleed" = "cieknie", "brute" = "wgniecenia", "burn" = "nadtopienia")

// Klosz z rybką

/obj/item/organ/brain/aquarian
	name = "klosz z rybką"
	desc = "Szklany klosz pełen wody, a w nim mała rybka: to właśnie jest Akwarianin. Bez pancerza się nie ruszy, ale przeżyje, póki ma wodę. \
		Robotyka może go włożyć w pusty pancerz albo w MMI."
	icon = AQUARIAN_ICON
	icon_state = "dome_item"
	organ_flags = ORGAN_VITAL
	attack_verb = list("uderza", "wali")
	/// Rodzaj ryby (stan fish_X), wędruje z kloszem do nowego pancerza
	var/fish_type
	/// Zabarwienie wody rrggbb
	var/water_tint
	/// Kolor ryby rrggbb (tylko szare ryby z GLOB.aquarian_tinted_fish), wędruje z kloszem jak rodzaj ryby
	var/fish_tint
	/// Czy kolor przedmiotu ustawiła martwa szara ryba (żeby zdjąć go po zmianie stanu, a cudzego koloru nie ruszać)
	var/fish_body_colored = FALSE
	/// Duszenie się ryby (0-200), przepisywane na oxyloss pancerza
	var/fish_oxyloss = 0
	/// Wartość oxyloss ustawiona w ostatnim cyklu (do wykrycia leczenia)
	var/synced_oxyloss = 0
	/// Czy klosz jest teraz pęknięty
	var/cracked = FALSE
	/// Czy z rozbitego pancerza wycieka woda
	var/body_leaking = FALSE
	/// Poziom wody na rysunku: 0 pusto, 1 mało, 2 dość
	var/drawn_water_state = 2
	/// Klosz się rozbił: zostaje sama rybka (na podłodze albo w naczyniu)
	var/shattered = FALSE
	/// Naczynie z wodą, do którego przełożono rybkę z rozbitego klosza (woda z niego jest w reagentach organu)
	var/obj/item/reagent_containers/vessel
	/// Ile siły uderzeń wytrzyma jeszcze leżący klosz
	var/dome_integrity = AQUARIAN_DOME_INTEGRITY
	COOLDOWN_DECLARE(warning_cooldown)

/obj/item/organ/brain/aquarian/Initialize(mapload)
	. = ..()
	create_reagents(AQUARIAN_DOME_VOLUME, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/water, AQUARIAN_DOME_VOLUME, reagtemp = T20C)
	update_icon()

/obj/item/organ/brain/aquarian/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	var/carried_name = brainmob?.real_name // brainmob znika w ..(), a pusty pancerz nie ma imienia postaci
	if(ishuman(C) && C.dna)
		// Klosz niesie rybę ze sobą. Świeży klosz bierze rybę i kolor wody z wyglądu postaci.
		if(fish_type)
			C.dna.features[FEATURE_AQUARIAN_FISH] = fish_type
		else
			fish_type = aquarian_valid_fish(C.dna.features[FEATURE_AQUARIAN_FISH])
		if(water_tint)
			C.dna.features[FEATURE_AQUARIAN_WATER] = water_tint
		else
			water_tint = aquarian_valid_color(C.dna.features[FEATURE_AQUARIAN_WATER], AQUARIAN_DEFAULT_WATER)
		if(fish_tint)
			C.dna.features[FEATURE_AQUARIAN_FISH_COLOR] = fish_tint
		else
			fish_tint = aquarian_valid_color(C.dna.features[FEATURE_AQUARIAN_FISH_COLOR], AQUARIAN_DEFAULT_FISH_COLOR)
	..() // woła też C.update_hair(), które rysuje klosz
	name = initial(name)
	synced_oxyloss = 0
	if(carried_name && C.real_name == AQUARIAN_SHELL_NAME)
		C.fully_replace_character_name(C.real_name, carried_name)

/obj/item/organ/brain/aquarian/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	..()
	C.remove_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN)
	C.clear_alert("aquarian_water")
	C.clear_alert("aquarian_leak")
	update_icon()

/obj/item/organ/brain/aquarian/transfer_identity(mob/living/L)
	. = ..()
	name = "[initial(name)] ([L.real_name])"

/obj/item/organ/brain/aquarian/emp_act(severity)
	return // rybka nie ma elektroniki

/// Leżący klosz: woda i kołnierz są w stanie dome_item, nad nimi ryba (przesunięta w dół jak cały klosz) i przód
/obj/item/organ/brain/aquarian/update_overlays()
	. = ..()
	var/fish_state = aquarian_valid_fish(fish_type)
	if(shattered && !vessel)
		// Sama rybka: rysuje ją icon_state (fish_flop_X albo fish_dead_X). Rzucająca się szara ryba ma w icon_state same krople,
		// a ciało w nakładce, żeby kolor ryby nie barwił wody. Martwą barwi kolor przedmiotu (update_icon_state).
		if(fish_tinted() && fish_alive_out_of_water())
			var/mutable_appearance/lying = mutable_appearance(AQUARIAN_ICON, "fish_dead_[fish_state]")
			lying.color = fish_color()
			. += lying
		return
	if(vessel?.fill_icon_thresholds && reagents.total_volume)
		// Poziom wody jak w samym naczyniu (woda jest w reagentach organu, nie naczynia)
		var/fill_name = vessel.fill_icon_state || vessel.icon_state
		var/percent = round(reagents.total_volume / reagents.maximum_volume * 100)
		var/fill_level = vessel.fill_icon_thresholds[1]
		for(var/threshold in vessel.fill_icon_thresholds)
			if(threshold <= percent)
				fill_level = threshold
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_level]")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling
	var/mutable_appearance/fish = mutable_appearance(AQUARIAN_ICON, "fish_[fish_state]")
	fish.pixel_y = -AQUARIAN_ITEM_SHIFT
	fish.color = fish_color()
	. += fish
	if(!vessel)
		. += mutable_appearance(AQUARIAN_ICON, "dome_item_front")

/obj/item/organ/brain/aquarian/update_icon_state()
	. = ..()
	// W naczyniu przedmiot wygląda jak to naczynie (z rybką w nakładce)
	icon = vessel ? vessel.icon : AQUARIAN_ICON
	// Kolor przedmiotu ma tylko martwa szara ryba leżąca sama (cały obraz to wtedy jej ciało)
	var/body_color = null
	if(!shattered)
		icon_state = "dome_item"
	else if(vessel)
		icon_state = vessel.icon_state
	else
		// Rzucająca się szara ryba: w icon_state same krople, ciało w nakładce (update_overlays)
		icon_state = "[fish_alive_out_of_water() ? "fish_flop" : "fish_dead"]_[aquarian_valid_fish(fish_type)]"
		if(fish_tinted() && !fish_alive_out_of_water())
			body_color = fish_color()
	if(body_color || fish_body_colored)
		color = body_color
		fish_body_colored = !!body_color

/obj/item/organ/brain/aquarian/examine(mob/user)
	. = ..()
	. += water_examine_text()
	if(!shattered || vessel)
		. += "<span class='notice'>[vessel ? "W naczyniu" : "W kloszu"] pływa [lowertext(GLOB.aquarian_fish[aquarian_valid_fish(fish_type)])].</span>"
	if(shattered && !vessel && !brain_death)
		. += "<span class='notice'>Można ją wpuścić do zlewki, wiadra albo szklanki z wodą, przełożyć do nowego klosza z fabrykatora egzoszkieletów albo dobić w trybie walki.</span>"
	if(vessel)
		. += "<span class='notice'>Użyj w ręce, żeby wylać rybkę z naczynia. Do nowego klosza przełożysz ją, klikając naczyniem w pusty klosz.</span>"

/// Woda (bez innych reagentów), którą rybka może oddychać
/obj/item/organ/brain/aquarian/proc/water_amount()
	return reagents.get_reagent_amount(/datum/reagent/water)

/// 0 pusto, 1 mało, 2 dość: do rysunku i opisu
/obj/item/organ/brain/aquarian/proc/water_state()
	if(reagents.total_volume < 1)
		return 0
	if(reagents.total_volume < AQUARIAN_WATER_LOW)
		return 1
	return 2

/obj/item/organ/brain/aquarian/proc/fish_alive()
	return !brain_death && !(organ_flags & ORGAN_FAILING) && water_amount() >= 1 && fish_oxyloss < 150

/// Rybka jeszcze żyje (choćby rzucała się bez wody)
/obj/item/organ/brain/aquarian/proc/fish_alive_out_of_water()
	return !brain_death && !(organ_flags & ORGAN_FAILING)

/// Warstwy klosza na kołnierzu, od tyłu: woda (zabarwiona, przy małej ilości blada, przy pustym kloszu brak), ryba, przód z odblaskiem
/obj/item/organ/brain/aquarian/proc/dome_overlays(layer, dir = 0)
	var/list/output = list()
	var/state = water_state()
	if(state)
		// Zabarwiona woda jest szara (dome_back_grey), żeby kolor z okna postaci wyszedł taki, jaki wybrano
		var/tinted = water_tint && water_tint != AQUARIAN_DEFAULT_WATER
		var/image/water = image(icon = AQUARIAN_ICON, icon_state = tinted ? "dome_back_grey" : "dome_back", layer = layer, dir = dir)
		if(tinted)
			water.color = "#[water_tint]"
		if(state == 1)
			water.alpha = 110
		output += water
	var/image/fish = image(icon = AQUARIAN_ICON, icon_state = "fish_[aquarian_valid_fish(fish_type)]", layer = layer, dir = dir)
	fish.color = fish_color()
	output += fish
	output += image(icon = AQUARIAN_ICON, icon_state = "dome_front", layer = layer, dir = dir)
	return output

/// Czy ryba jest szara i barwi ją kolor ryby
/obj/item/organ/brain/aquarian/proc/fish_tinted()
	return (aquarian_valid_fish(fish_type) in GLOB.aquarian_tinted_fish)

/// Kolor szarej ryby ("#rrggbb") albo null dla ryb we własnych kolorach
/obj/item/organ/brain/aquarian/proc/fish_color()
	if(!fish_tinted() || !fish_tint || fish_tint == AQUARIAN_DEFAULT_FISH_COLOR)
		return null
	return "#[fish_tint]"

/obj/item/organ/brain/aquarian/proc/water_examine_text()
	var/list/lines = list()
	if(shattered && !vessel)
		if(fish_alive_out_of_water())
			return "<span class='danger'>Rybka rzuca się bez wody i się dusi!</span>"
		return "<span class='warning'>Rybka nie żyje.</span>"
	if(vessel)
		if(water_state())
			return "<span class='notice'>W naczyniu jest [round(water_amount())] j. wody.</span>"
		return "<span class='danger'>W naczyniu nie ma wody, a rybka rzuca się na dnie!</span>"
	switch(water_state())
		if(0)
			lines += "<span class='danger'>Klosz jest pusty, a rybka rzuca się na dnie!</span>"
		if(1)
			lines += "<span class='warning'>W kloszu zostało mało wody.</span>"
		else
			lines += "<span class='notice'>Klosz jest pełen wody.</span>"
	if(cracked)
		lines += "<span class='warning'>Klosz jest pęknięty i cieknie.</span>"
	if(reagents.chem_temp < AQUARIAN_WATER_FREEZE)
		lines += "<span class='warning'>Woda w kloszu zamarzła.</span>"
	else if(reagents.chem_temp >= AQUARIAN_WATER_BOIL)
		lines += "<span class='danger'>Woda w kloszu wrze!</span>"
	return jointext(lines, "\n")

/obj/item/organ/brain/aquarian/proc/refill_completely()
	reagents.clear_reagents()
	reagents.add_reagent(/datum/reagent/water, AQUARIAN_DOME_VOLUME, reagtemp = T20C)
	fish_oxyloss = 0
	synced_oxyloss = 0
	cracked = FALSE
	update_water_visual()

/obj/item/organ/brain/aquarian/proc/update_water_visual()
	var/state = water_state()
	if(state == drawn_water_state)
		return
	drawn_water_state = state
	owner?.update_hair()
	update_icon()

/obj/item/organ/brain/aquarian/proc/warn(message)
	if(!owner || !COOLDOWN_FINISHED(src, warning_cooldown))
		return
	COOLDOWN_START(src, warning_cooldown, 10 SECONDS)
	to_chat(owner, message)

/// Wylewa trochę zawartości klosza na podłogę (kałuża z modułu cieczy)
/obj/item/organ/brain/aquarian/proc/spill(amount)
	amount = min(amount, reagents.total_volume)
	if(amount <= 0)
		return
	var/turf/T = get_turf(owner || src) // w ciele organ jest w nullspace
	T?.add_liquid_from_reagents(reagents, amount = amount)
	reagents.remove_all(amount)

/obj/item/organ/brain/aquarian/on_life()
	. = ..()
	if(owner && owner.stat != DEAD)
		process_water(owner)

/// Klosz w żywym pancerzu: temperatura, wycieki, parowanie, chemia i oddychanie ryby. Woła się co cykl życia (2 s).
/obj/item/organ/brain/aquarian/proc/process_water(mob/living/carbon/C)
	reagents.expose_temperature(C.bodytemperature, 0.25)
	var/temperature = reagents.chem_temp

	// Pęknięty klosz cieknie, póki ktoś nie zaspawa głowy
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	// Mocno rozbita głowa: klosz rozpryskuje się, a rybka wypada na podłogę
	if(head && head.brute_dam >= AQUARIAN_SHATTER_DAMAGE)
		shatter()
		return
	if(head && head.brute_dam >= AQUARIAN_CRACK_DAMAGE && reagents.total_volume)
		if(!cracked)
			cracked = TRUE
			to_chat(C, "<span class='userdanger'>Twój klosz pęka! Woda zaczyna wyciekać.</span>")
		spill(head.brute_dam / AQUARIAN_CRACK_DAMAGE)
	else if(cracked && (!head || head.brute_dam < AQUARIAN_CRACK_DAMAGE))
		cracked = FALSE
		to_chat(C, "<span class='notice'>Pęknięcie klosza jest uszczelnione.</span>")

	// Rozbity pancerz „krwawi” wodą: przez przewody z kołnierza ucieka woda z klosza, póki ktoś nie zaspawa wgnieceń
	var/body_brute = 0
	for(var/obj/item/bodypart/part as anything in C.bodyparts)
		if(part.body_zone != BODY_ZONE_HEAD)
			body_brute += part.brute_dam
	if(body_brute >= AQUARIAN_BODY_LEAK_DAMAGE && reagents.total_volume)
		if(!body_leaking)
			body_leaking = TRUE
			to_chat(C, "<span class='userdanger'>Z wgniecionego pancerza sączy się woda z twojego klosza!</span>")
		spill(body_brute / AQUARIAN_BODY_LEAK_DIVISOR)
	else if(body_leaking && body_brute < AQUARIAN_BODY_LEAK_DAMAGE)
		body_leaking = FALSE
		to_chat(C, "<span class='notice'>Pancerz przestaje przeciekać.</span>")
	// Stały alert jak krwawienie u ludzi: rasa nie ma krwi, więc alert krwawienia jej nie dotyczy, a jedna linijka w czacie ginie w walce
	if((cracked || body_leaking) && reagents.total_volume)
		var/atom/movable/screen/alert/aquarian_leak/leak_alert = C.throw_alert("aquarian_leak", /atom/movable/screen/alert/aquarian_leak)
		leak_alert?.update_leak(cracked, body_leaking, water_amount())
	else
		C.clear_alert("aquarian_leak")

	// Parowanie w gorącu
	if(temperature >= AQUARIAN_WATER_BOIL)
		reagents.remove_reagent(/datum/reagent/water, 3)
	else if(temperature >= AQUARIAN_WATER_HOT)
		reagents.remove_reagent(/datum/reagent/water, 0.5)

	// Reagenty w wodzie działają na rybę. Zmielone jedzenie (pożywka, białko, witaminy) rybka zjada od razu: daje tyle sytości,
	// ile przy zwykłym trawieniu, a nie trafia do ciała, bo pancerz go nie trawi
	for(var/datum/reagent/reagent as anything in reagents.reagent_list.Copy())
		if(reagent.type == /datum/reagent/water)
			continue
		if(istype(reagent, /datum/reagent/consumable/nutriment))
			var/datum/reagent/consumable/nutriment/food = reagent
			var/eaten = min(food.volume, AQUARIAN_CHEM_RATE)
			C.adjust_nutrition(food.nutriment_factor * eaten / max(food.metabolization_rate, 0.01))
			reagents.remove_reagent(food.type, eaten)
			continue
		reagents.trans_id_to(C, reagent.type, AQUARIAN_CHEM_RATE)

	// Oddychanie wodą
	var/water = water_amount()
	if(water < 1)
		fish_oxyloss += AQUARIAN_SUFFOCATION_EMPTY
		warn("<span class='userdanger'>W kloszu nie ma wody! Rybka się dusi!</span>")
	else if(temperature < AQUARIAN_WATER_FREEZE)
		fish_oxyloss += AQUARIAN_SUFFOCATION_LOW
		warn("<span class='danger'>Woda w kloszu zamarza! Rybka ledwo może oddychać i ruszać płetwami.</span>")
	else if(water < AQUARIAN_WATER_LOW)
		fish_oxyloss += AQUARIAN_SUFFOCATION_LOW
		warn("<span class='danger'>W kloszu jest za mało wody, rybka łapie powietrze!</span>")
	else
		fish_oxyloss -= 4
	fish_oxyloss = clamp(fish_oxyloss, 0, 200)
	if(water < AQUARIAN_WATER_LOW)
		C.throw_alert("aquarian_water", /atom/movable/screen/alert/aquarian_water)
	else
		C.clear_alert("aquarian_water")

	// Gorąca woda parzy rybę (obrażenia klosza leczy np. mannitol wlany do wody)
	if(temperature >= AQUARIAN_WATER_HOT)
		applyOrganDamage(temperature >= AQUARIAN_WATER_BOIL ? 4 : 1)
		warn("<span class='danger'>Woda w kloszu parzy rybkę!</span>")

	// Zimna woda spowalnia, zamarzająca prawie unieruchamia
	if(temperature < AQUARIAN_WATER_FREEZE)
		C.add_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN, TRUE, 100, override = TRUE, multiplicative_slowdown = 2)
	else if(temperature < AQUARIAN_WATER_COLD)
		C.add_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN, TRUE, 100, override = TRUE, multiplicative_slowdown = 0.75)
		warn("<span class='warning'>Woda w kloszu jest lodowata, rybka robi się ospała.</span>")
	else
		C.remove_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN)

	update_water_visual()

/// Poza pancerzem (i w martwym pancerzu) ryba żyje, póki ma wodę. MMI (ORGAN_FROZEN) trzyma ją przy życiu.
/obj/item/organ/brain/aquarian/on_death(delta_time = 2)
	if(organ_flags & ORGAN_FROZEN)
		return
	if(water_amount() >= 1)
		fish_oxyloss = max(0, fish_oxyloss - delta_time)
		return
	fish_oxyloss = min(200, fish_oxyloss + AQUARIAN_SUFFOCATION_EMPTY * delta_time / 2)
	if(fish_oxyloss >= 200 && !brain_death)
		brain_death = TRUE
		setOrganDamage(maxHealth)
		brainmob?.death()
		update_appearance()

/obj/item/organ/brain/aquarian/attackby(obj/item/O, mob/user, params)
	if(!isliving(user))
		return ..()
	var/mob/living/living_user = user
	if(shattered && !vessel)
		if(O.is_sharp() && !living_user.combat_mode)
			make_sushi(living_user, O)
		else if(living_user.combat_mode)
			squash(living_user, O)
		else if(istype(O, /obj/item/reagent_containers))
			enter_vessel(O, living_user)
		return TRUE // rybki nie bijemy jak mózgu
	if(istype(O, /obj/item/fish_feed) || aquarian_pourable(O))
		fill_from(O, living_user)
		return TRUE
	if(!shattered && !owner && living_user.combat_mode && O.force && O.damtype == BRUTE)
		hit_dome(O, living_user)
		return TRUE
	if(O.force && !(O.item_flags & NOBLUDGEON))
		return TRUE // attackby mózgu od razu go zabija, a szkło klosza (i naczynie) ma chronić rybkę
	return ..()

/// Rybka (albo naczynie z rybką) kliknięta w naczynie z wodą albo w pusty klosz
/obj/item/organ/brain/aquarian/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !shattered || !isliving(user) || !istype(target, /obj/item/reagent_containers))
		return
	if(vessel && !istype(target, /obj/item/reagent_containers/glass/aquarian_dome))
		return
	enter_vessel(target, user)

/// W trybie walki pustą ręką rozgniata się rybkę leżącą na podłodze
/obj/item/organ/brain/aquarian/attack_hand(mob/user, modifiers)
	if(shattered && !vessel && isturf(loc) && isliving(user) && user.combat_mode)
		squash(user)
		return TRUE
	return ..()

/// Wylewanie rybki z naczynia: woda chlusta na podłogę, rybka razem z nią
/obj/item/organ/brain/aquarian/attack_self(mob/user)
	if(!vessel)
		return ..()
	var/turf/T = get_turf(src)
	var/obj/item/reagent_containers/old_vessel = vessel
	vessel = null
	spill(reagents.total_volume)
	reagents.maximum_volume = AQUARIAN_DOME_VOLUME
	old_vessel.forceMove(T)
	leave_holder()
	forceMove(T)
	user.put_in_hands(old_vessel)
	user.visible_message("<span class='warning'>[user] wylewa rybkę z [old_vessel] na podłogę!</span>", \
		"<span class='warning'>Wylewasz rybkę z [old_vessel] na podłogę.</span>")
	to_chat(brainmob, "<span class='userdanger'>Wylatujesz z wody na podłogę!</span>")
	refresh_fish_name()
	update_appearance()

/// Rzucony klosz rozbija się o to, w co trafi (chyba że ktoś go złapie)
/obj/item/organ/brain/aquarian/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!shattered && !owner && !QDELETED(src) && !ismob(loc))
		shatter()

/// Uderzenie bronią w leżący klosz. Po kilku mocnych ciosach szkło nie wytrzymuje.
/obj/item/organ/brain/aquarian/proc/hit_dome(obj/item/weapon, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	dome_integrity -= weapon.force
	log_combat(user, brainmob || src, "hit the aquarian dome", weapon)
	if(dome_integrity <= 0)
		shatter()
		return
	playsound(src, 'sound/effects/glasshit.ogg', 50, TRUE)
	user.visible_message("<span class='danger'>[user] uderza w [src] za pomocą [weapon]! Szkło pęka.</span>", \
		"<span class='danger'>Uderzasz w [src] za pomocą [weapon]. Szkło pęka.</span>")

/// Klosz rozpryskuje się: woda na podłogę, odłamki obok, a rybka zostaje sama i rzuca się bez wody
/obj/item/organ/brain/aquarian/proc/shatter()
	if(shattered)
		return
	var/mob/living/carbon/wearer = owner
	var/turf/T = get_turf(wearer || src)
	if(!T)
		return
	shattered = TRUE
	cracked = FALSE
	if(wearer)
		Remove(wearer)
	leave_holder()
	forceMove(T)
	T.add_liquid_from_reagents(reagents, amount = reagents.total_volume)
	reagents.clear_reagents()
	new /obj/item/shard(T)
	playsound(T, 'sound/effects/glassbr3.ogg', 70, TRUE)
	if(wearer)
		wearer.visible_message("<span class='danger'>Klosz [wearer] rozpryskuje się na kawałki, a rybka wypada na podłogę!</span>")
		if(wearer.stat != DEAD)
			wearer.death()
	else
		T.visible_message("<span class='danger'>Klosz rozpryskuje się na kawałki, a rybka wypada na podłogę!</span>")
	to_chat(brainmob, "<span class='userdanger'>Twój klosz pęka! Wypadasz na podłogę i rzucasz się bez wody!</span>")
	refresh_fish_name()
	update_appearance()

/// Wyjmuje rybkę z rąk, zanim przeniesiemy ją gdzie indziej: samo forceMove zostawia ją w held_items
/obj/item/organ/brain/aquarian/proc/leave_holder()
	var/mob/holder = loc
	if(istype(holder) && holder.is_holding(src))
		holder.temporarilyRemoveItemFromInventory(src, TRUE)

/// Rybka do naczynia z wodą (zlewka, wiadro, szklanka) albo do nowego klosza
/obj/item/organ/brain/aquarian/proc/enter_vessel(obj/item/reagent_containers/new_vessel, mob/living/user)
	if(istype(new_vessel, /obj/item/reagent_containers/glass/aquarian_dome))
		restore_dome(new_vessel, user)
		return
	if(vessel)
		return
	if(!new_vessel.is_open_container() || new_vessel.reagents.maximum_volume < AQUARIAN_VESSEL_MIN_VOLUME || \
		!(istype(new_vessel, /obj/item/reagent_containers/glass) || istype(new_vessel, /obj/item/reagent_containers/food/drinks)))
		to_chat(user, "<span class='warning'>Rybka nie zmieści się w [new_vessel]. Potrzeba otwartego naczynia na co najmniej [AQUARIAN_VESSEL_MIN_VOLUME] j.: zlewki, wiadra albo szklanki.</span>")
		return
	if(new_vessel.reagents.get_reagent_amount(/datum/reagent/water) < AQUARIAN_VESSEL_MIN_WATER)
		to_chat(user, "<span class='warning'>W [new_vessel] jest za mało wody dla rybki.</span>")
		return
	var/vessel_in_hand = (new_vessel.loc == user)
	var/fish_in_hand = (loc == user)
	if(vessel_in_hand && !user.temporarilyRemoveItemFromInventory(new_vessel))
		return
	var/turf/T = get_turf(new_vessel)
	new_vessel.forceMove(src)
	vessel = new_vessel
	reagents.maximum_volume = new_vessel.reagents.maximum_volume
	new_vessel.reagents.trans_to(src, new_vessel.reagents.total_volume, transfered_by = user)
	if(!fish_in_hand)
		forceMove(T)
		if(vessel_in_hand)
			user.put_in_hands(src)
	playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	user.visible_message("<span class='notice'>[user] wpuszcza rybkę do [new_vessel].</span>", \
		"<span class='notice'>Wpuszczasz rybkę do [new_vessel]. Rybka znów ma wodę.</span>")
	to_chat(brainmob, "<span class='notice'>Znów jesteś w wodzie!</span>")
	refresh_fish_name()
	update_appearance()

/// Rybka do nowego, pustego klosza: znów jest klosz, który zamocuje się na pancerzu
/obj/item/organ/brain/aquarian/proc/restore_dome(obj/item/reagent_containers/glass/aquarian_dome/new_dome, mob/living/user)
	var/dome_in_hand = (new_dome.loc == user)
	var/fish_in_hand = (loc == user)
	var/turf/T = get_turf(new_dome)
	if(vessel)
		var/obj/item/reagent_containers/old_vessel = vessel
		vessel = null
		old_vessel.forceMove(T)
		if(fish_in_hand)
			user.temporarilyRemoveItemFromInventory(src)
			user.put_in_hands(old_vessel)
	if(reagents.total_volume > AQUARIAN_DOME_VOLUME)
		spill(reagents.total_volume - AQUARIAN_DOME_VOLUME)
	reagents.maximum_volume = AQUARIAN_DOME_VOLUME
	new_dome.reagents.trans_to(src, new_dome.reagents.total_volume, transfered_by = user)
	shattered = FALSE
	cracked = FALSE
	dome_integrity = initial(dome_integrity)
	if(dome_in_hand)
		user.temporarilyRemoveItemFromInventory(new_dome)
	qdel(new_dome)
	leave_holder()
	forceMove(T)
	if(dome_in_hand || fish_in_hand)
		user.put_in_hands(src)
	playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	user.visible_message("<span class='notice'>[user] przekłada rybkę do nowego klosza.</span>", \
		"<span class='notice'>Przekładasz rybkę do nowego klosza. Teraz można go zamocować na pancerzu.</span>")
	to_chat(brainmob, "<span class='notice'>Pływasz w nowym kloszu!</span>")
	refresh_fish_name()
	update_appearance()

/// Dobicie rybki leżącej bez wody
/obj/item/organ/brain/aquarian/proc/squash(mob/living/user, obj/item/weapon)
	if(!fish_alive_out_of_water())
		to_chat(user, "<span class='warning'>Ta rybka już nie żyje.</span>")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] rozgniata rybkę[weapon ? " za pomocą [weapon]" : ""]!</span>", \
		"<span class='danger'>Rozgniatasz rybkę[weapon ? " za pomocą [weapon]" : ""].</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	log_combat(user, brainmob || src, "squashed the aquarian fish", weapon)
	fish_oxyloss = 200
	brain_death = TRUE
	setOrganDamage(maxHealth)
	brainmob?.death()
	refresh_fish_name()
	update_appearance()

/// Rybka leżąca na podłodze krojona ostrym narzędziem na sushi. Żywa rybka przy tym ginie.
/obj/item/organ/brain/aquarian/proc/make_sushi(mob/living/user, obj/item/knife)
	var/turf/T = get_turf(src)
	if(!T)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(!do_after(user, 2 SECONDS * knife.toolspeed, target = src) || QDELETED(src) || !shattered || vessel)
		return
	if(fish_alive_out_of_water())
		log_combat(user, brainmob || src, "made sushi out of the aquarian fish", knife)
		to_chat(brainmob, "<span class='userdanger'>[user] kroi cię na sushi!</span>")
		brainmob?.death()
	playsound(T, 'sound/weapons/slice.ogg', 50, TRUE)
	user.visible_message("<span class='warning'>[user] kroi rybkę za pomocą [knife] na sushi.</span>", \
		"<span class='notice'>Kroisz rybkę za pomocą [knife] na sushi.</span>")
	for(var/i in 1 to AQUARIAN_SUSHI_PIECES)
		new /obj/item/food/nigiri_sushi/aquarian(T)
	qdel(src)

/// Nazwa zależna od tego, gdzie jest rybka, z imieniem postaci
/obj/item/organ/brain/aquarian/proc/refresh_fish_name()
	var/base = initial(name)
	desc = initial(desc)
	if(shattered)
		if(vessel)
			base = "[vessel.name] z rybką"
			desc = "Akwarianin bez klosza: mała rybka w naczyniu z wodą. Przeżyje, póki ma wodę, ale żeby wrócić do pancerza, potrzebuje nowego klosza."
		else if(fish_alive_out_of_water())
			base = "rybka"
			desc = "Akwarianin bez klosza: mała rybka, która rzuca się na podłodze i dusi bez wody. Trzeba ją szybko wpuścić do wody."
		else
			base = "martwa rybka"
			desc = "Mała, martwa rybka. Kiedyś był to Akwarianin."
	name = brainmob ? "[base] ([brainmob.real_name])" : base

/// Wkładanie klosza w pancerz bez klosza (np. nowy z fabrykatora egzoszkieletów)
/obj/item/organ/brain/aquarian/attack(mob/living/carbon/human/target, mob/living/user, params)
	if(!ishuman(target) || !isaquarian(target) || user.combat_mode || aquarian_dome(target))
		return ..()
	if(shattered)
		to_chat(user, "<span class='warning'>Rybki nie zamocujesz na pancerzu bez klosza. Najpierw przełóż ją do nowego klosza z fabrykatora egzoszkieletów.</span>")
		return TRUE
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, "<span class='warning'>[target] nie ma kołnierza, na który dałoby się założyć klosz.</span>")
		return TRUE
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		return ..()
	user.visible_message("<span class='notice'>[user] zaczyna mocować [src] na kołnierzu pancerza [target].</span>", \
		"<span class='notice'>Zaczynasz mocować [src] na kołnierzu pancerza [target].</span>")
	if(!do_after(user, 5 SECONDS, target = target))
		return TRUE
	if(QDELETED(src) || target.getorganslot(ORGAN_SLOT_BRAIN) || !user.temporarilyRemoveItemFromInventory(src))
		return TRUE
	Insert(target)
	playsound(target, 'sound/machines/click.ogg', 50, TRUE)
	user.visible_message("<span class='notice'>[user] mocuje [src] na pancerzu [target].</span>", \
		"<span class='notice'>Mocujesz [src] na pancerzu [target].</span>")
	if(target.stat == DEAD && target.health > 0 && fish_alive())
		target.revive()
	return TRUE

/// Wlewa zawartość pojemnika do klosza albo sypie karmę. Do cudzego klosza wlewa się chwilę.
/obj/item/organ/brain/aquarian/proc/fill_from(obj/item/source, mob/living/user)
	var/mob/living/carbon/wearer = owner
	var/is_feed = istype(source, /obj/item/fish_feed)
	if(!is_feed)
		if(!source.reagents?.total_volume)
			to_chat(user, "<span class='warning'>Pojemnik jest pusty: [source].</span>")
			return
		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>Klosz jest pełny.</span>")
			return
	if(wearer && user != wearer)
		if(is_feed)
			user.visible_message("<span class='warning'>[user] próbuje nasypać karmy do klosza [wearer].</span>", \
				"<span class='notice'>Próbujesz nasypać karmy do klosza [wearer].</span>")
		else
			user.visible_message("<span class='warning'>[user] próbuje wlać zawartość [source] do klosza [wearer].</span>", \
				"<span class='notice'>Próbujesz wlać zawartość [source] do klosza [wearer].</span>")
		if(!do_after(user, 3 SECONDS, target = wearer) || owner != wearer || (!is_feed && !source.reagents?.total_volume))
			return
	if(is_feed)
		if(feed_from(source, user) && wearer && user != wearer)
			log_combat(user, wearer, "fed the fish in the dome of", source)
		return
	var/amount = 10
	var/obj/item/reagent_containers/container = source
	if(istype(container))
		amount = container.amount_per_transfer_from_this
	var/contents = source.reagents.log_list()
	var/transferred = source.reagents.trans_to(src, amount, transfered_by = user)
	if(!transferred)
		return
	playsound(wearer || src, 'sound/effects/slosh.ogg', 25, TRUE)
	if(wearer)
		if(user == wearer)
			to_chat(user, "<span class='notice'>Wlewasz [transferred] j. z [source] do swojego klosza.</span>")
		else
			wearer.visible_message("<span class='notice'>[user] wlewa coś z [source] do klosza [wearer].</span>", \
				"<span class='notice'>[user] wlewa coś do twojego klosza.</span>")
			log_combat(user, wearer, "poured [contents] into the dome of", source)
	else
		to_chat(user, "<span class='notice'>Wlewasz [transferred] j. z [source] do [src].</span>")
	update_water_visual()

/// Karma dla ryb z akwarium: zaspokaja głód. Puszka sama wytwarza karmę, więc chemia z puszki nie trafia do wody
/// (inaczej puszka powielałaby każdą wlaną do niej truciznę). Zwraca TRUE, gdy rybka zjadła.
/obj/item/organ/brain/aquarian/proc/feed_from(obj/item/fish_feed/feed, mob/living/user)
	if(owner && owner.nutrition >= NUTRITION_LEVEL_FULL)
		to_chat(user, "<span class='warning'>Rybka nie chce już jeść.</span>")
		return FALSE
	. = TRUE
	if(owner)
		owner.adjust_nutrition(AQUARIAN_FEED_NUTRITION)
	playsound(owner || src, 'sound/effects/bubbles.ogg', 25, TRUE)
	if(owner && user != owner)
		owner.visible_message("<span class='notice'>[user] sypie karmę do klosza [owner].</span>", \
			"<span class='notice'>[user] sypie ci karmę do klosza. Rybka łapczywie je.</span>")
	else
		to_chat(user, "<span class='notice'>Sypiesz karmę do klosza. Rybka łapczywie je.</span>")

/// Dolewanie wody z umywalki pustą ręką
/obj/item/organ/brain/aquarian/proc/refill_from_sink(obj/structure/sink/sink, mob/living/user)
	if(reagents.holder_full())
		to_chat(user, "<span class='notice'>Klosz jest pełny.</span>")
		return
	if(sink.busy)
		to_chat(user, "<span class='notice'>Ktoś już korzysta z [sink].</span>")
		return
	if(sink.reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Z kranu nie leci woda: [sink].</span>")
		return
	user.visible_message("<span class='notice'>[user] nachyla się nad [sink] i nalewa wody do klosza.</span>", \
		"<span class='notice'>Nachylasz się nad [sink] i nalewasz wody do klosza.</span>")
	sink.busy = TRUE
	var/done = do_after(user, 4 SECONDS, target = sink)
	sink.busy = FALSE
	if(!done || QDELETED(sink) || QDELETED(src))
		return
	sink.reagents.trans_to(src, reagents.maximum_volume - reagents.total_volume, transfered_by = user)
	sink.begin_reclamation()
	playsound(sink, 'sound/effects/slosh.ogg', 25, TRUE)
	to_chat(user, "<span class='notice'>Klosz jest znów pełen wody.</span>")
	update_water_visual()

/atom/movable/screen/alert/aquarian_leak
	icon = 'aquila/icons/hud/screen_alert_bleeding.dmi'
	name = "Wyciek wody"
	desc = "Z pancerza wycieka woda z klosza. Zaspawaj wgniecenia spawarką, zanim rybka zostanie bez wody."
	icon_state = "bleed"

/// Opis i ikona zależą od tego, co cieknie; liczba na ikonie to woda, która została w kloszu
/atom/movable/screen/alert/aquarian_leak/proc/update_leak(cracked, body_leaking, water)
	if(cracked)
		name = "Wyciek wody (pęknięty klosz)"
		desc = "Klosz jest pęknięty i woda ucieka z niego szybko. Zaspawaj głowę spawarką, zanim rybka zostanie bez wody."
		icon_state = "bleed_heavy"
	else
		name = "Wyciek wody"
		desc = "Z wgniecionego pancerza sączy się woda z klosza. Zaspawaj wgniecenia spawarką, zanim rybka zostanie bez wody."
		icon_state = "bleed"
	maptext = MAPTEXT("[round(water)]j")

/atom/movable/screen/alert/aquarian_water
	name = "Mało wody w kloszu"
	desc = "Rybka dusi się bez wody. Dolej wody do klosza: kliknij pojemnikiem w swoją głowę albo pustą ręką w umywalkę (celując w głowę)."
	icon_state = "not_enough_oxy"

/// Sushi z rybki Akwarianina (jak zwykłe nigiri, ale z odrobiną wody z klosza)
/obj/item/food/nigiri_sushi/aquarian
	name = "sushi z akwarianina"
	desc = "Nigiri z drobnej rybki, która jeszcze niedawno chodziła po okręcie w szklanym kloszu. Lepiej nie pytać, czy miała imię."
	tastes = list("filet rybny" = 3, "woda z akwarium" = 1)

// Mowa: bulgotanie przez głośnik pancerza

/obj/item/organ/tongue/aquarian
	name = "głośnik pancerza"
	desc = "Mały głośnik z mikrofonem zanurzonym w kloszu. Zamienia bulgotanie rybki na mowę, ale bulgotanie zostaje."
	icon_state = "tonguerobot"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	say_mod = "bulgocze"
	ask_mod = "bulgocze pytająco"
	yell_mod = "bulgocze głośno"
	exclaim_mod = "bulgocze z przejęciem"
	taste_sensitivity = 25

// Pancerz: robotyczne części ciała. Czerwone płyty można przemalować w oknie postaci (nakładka *_paint).
// Drugi pancerz do wyboru to goły metal (stany aquarian_metal_*, sprite'y z paczki Fish People): bez płyt do malowania,
// kolor pancerza barwi wtedy tylko wzór na ramionach (rękawy, paski), który można nałożyć na oba pancerze.

/obj/item/bodypart
	/// Kolor pancerza akwarianina (rrggbb), null = fabryczna czerwień albo goły metal
	var/aquarian_paint
	/// Pancerz z gołego metalu (stany aquarian_metal_*)
	var/aquarian_metal = FALSE
	/// Wzór na ramieniu (aquarian_pattern_X_strefa) albo null
	var/aquarian_pattern
	/// Kolor wzoru na ramieniu ("#rrggbb"): kolor pancerza
	var/aquarian_pattern_color

/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(limb_id != SPECIES_AQUARIAN || dropping_limb || no_update)
		return
	var/mob/living/carbon/human/H = source || owner
	if(!ishuman(H) || !H.dna)
		return
	var/paint = aquarian_valid_color(H.dna.features[FEATURE_AQUARIAN_ARMOR], AQUARIAN_DEFAULT_ARMOR)
	aquarian_metal = aquarian_valid_body(H.dna.features[FEATURE_AQUARIAN_BODY]) == AQUARIAN_BODY_METAL
	aquarian_paint = (aquarian_metal || paint == AQUARIAN_DEFAULT_ARMOR) ? null : paint
	var/pattern = aquarian_valid_pattern(H.dna.features[FEATURE_AQUARIAN_PATTERN])
	aquarian_pattern = pattern == AQUARIAN_PATTERN_NONE ? null : pattern
	aquarian_pattern_color = aquarian_pattern ? "#[paint]" : null

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(is_husked || !length(.) || limb_id != SPECIES_AQUARIAN)
		return
	var/list/states = aq_pref_icon_states(AQUARIAN_ICON)
	if(aquarian_metal)
		// Kończyna i dłoń w gołym metalu; kołnierz jest ten sam w obu pancerzach (brak stanu aquarian_metal_head_*)
		for(var/image/part in .)
			if(part.icon != AQUARIAN_ICON || !findtext(part.icon_state, "[SPECIES_AQUARIAN]_", 1, length(SPECIES_AQUARIAN) + 2))
				continue
			var/metal_state = "[SPECIES_AQUARIAN]_metal_[copytext(part.icon_state, length(SPECIES_AQUARIAN) + 2)]"
			if(metal_state in states)
				part.icon_state = metal_state
	var/image_dir = dropped ? SOUTH : 0
	if(aquarian_paint)
		var/state = "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]_paint"
		if(state in states)
			var/image/paint = image(icon = AQUARIAN_ICON, icon_state = state, layer = -BODYPARTS_LAYER, dir = image_dir)
			paint.color = "#[aquarian_paint]"
			. += paint
	if(aquarian_pattern)
		var/pattern_state = "aquarian_pattern_[aquarian_pattern]_[body_zone]"
		if(pattern_state in states)
			var/image/pattern = image(icon = AQUARIAN_ICON, icon_state = pattern_state, layer = -BODYPARTS_LAYER, dir = image_dir)
			pattern.color = aquarian_pattern_color
			. += pattern

/// Inny kolor, pancerz albo wzór = inna ikona kończyny w pamięci podręcznej
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(BP.aquarian_paint)
		. += "-aqpaint[BP.aquarian_paint]"
	if(BP.aquarian_metal)
		. += "-aqmetal"
	if(BP.aquarian_pattern)
		. += "-aqpattern[BP.aquarian_pattern][BP.aquarian_pattern_color]"

/obj/item/bodypart/head/aquarian
	name = "kołnierz pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowany"
	medium_brute_msg = "wgnieciony"
	heavy_brute_msg = "rozdarty"
	light_burn_msg = "osmalony"
	medium_burn_msg = "nadtopiony"
	heavy_burn_msg = "przepalony"

/// Odcięta głowa pokazuje klosz, jeśli został w kołnierzu
/obj/item/bodypart/head/aquarian/get_limb_icon(dropped)
	. = ..()
	var/obj/item/organ/brain/aquarian/dome = brain
	if(dropped && istype(dome))
		. += dome.dome_overlays(-BODYPARTS_LAYER, SOUTH)

/obj/item/bodypart/chest/aquarian
	name = "napierśnik pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowany"
	medium_brute_msg = "wgnieciony"
	heavy_brute_msg = "rozdarty"
	light_burn_msg = "osmalony"
	medium_burn_msg = "nadtopiony"
	heavy_burn_msg = "przepalony"

/obj/item/bodypart/l_arm/aquarian
	name = "lewe ramię pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowane"
	medium_brute_msg = "wgniecione"
	heavy_brute_msg = "rozdarte"
	light_burn_msg = "osmalone"
	medium_burn_msg = "nadtopione"
	heavy_burn_msg = "przepalone"

/obj/item/bodypart/r_arm/aquarian
	name = "prawe ramię pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowane"
	medium_brute_msg = "wgniecione"
	heavy_brute_msg = "rozdarte"
	light_burn_msg = "osmalone"
	medium_burn_msg = "nadtopione"
	heavy_burn_msg = "przepalone"

/obj/item/bodypart/l_leg/aquarian
	name = "lewa noga pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowana"
	medium_brute_msg = "wgnieciona"
	heavy_brute_msg = "rozdarta"
	light_burn_msg = "osmalona"
	medium_burn_msg = "nadtopiona"
	heavy_burn_msg = "przepalona"

/obj/item/bodypart/r_leg/aquarian
	name = "prawa noga pancerza"
	icon = AQUARIAN_ICON
	static_icon = AQUARIAN_ICON
	limb_id = SPECIES_AQUARIAN
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	light_brute_msg = "porysowana"
	medium_brute_msg = "wgnieciona"
	heavy_brute_msg = "rozdarta"
	light_burn_msg = "osmalona"
	medium_burn_msg = "nadtopiona"
	heavy_burn_msg = "przepalona"

// Nowy pancerz z fabrykatora egzoszkieletów: składany korpus bez klosza

/obj/item/aquarian_shell_kit
	name = "złożony pancerz akwarianina"
	desc = "Zestaw płyt i siłowników, który po rozłożeniu staje się pustym pancerzem akwarianina. Klosz z rybką mocuje się na kołnierzu."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/aquarian_shell_kit/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		return
	user.visible_message("<span class='notice'>[user] zaczyna rozkładać [src].</span>", "<span class='notice'>Zaczynasz rozkładać [src].</span>")
	if(!do_after(user, 5 SECONDS, target = user) || QDELETED(src))
		return
	aquarian_create_shell(T)
	user.visible_message("<span class='notice'>[user] rozkłada pusty pancerz akwarianina.</span>", "<span class='notice'>Rozkładasz pusty pancerz akwarianina.</span>")
	qdel(src)

/// Pusty pancerz: akwarianin bez klosza, wyłączony
/proc/aquarian_create_shell(turf/T)
	var/mob/living/carbon/human/species/aquarian/shell = new(T)
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(shell)
	if(dome)
		dome.Remove(shell, TRUE, TRUE)
		qdel(dome)
	shell.real_name = AQUARIAN_SHELL_NAME
	shell.name = shell.real_name
	shell.death()
	return shell

/datum/design/aquarian_shell
	name = "Pancerz akwarianina"
	desc = "Pusty pancerz, na którego kołnierzu można zamocować klosz z rybką."
	id = "aquarian_shell"
	build_type = MECHFAB
	build_path = /obj/item/aquarian_shell_kit
	materials = list(/datum/material/iron = 30000, /datum/material/glass = 5000)
	construction_time = 400
	category = list("Cyborg")

// Nowy klosz z fabrykatora egzoszkieletów: do niego przekłada się rybkę z rozbitego klosza

/obj/item/reagent_containers/glass/aquarian_dome
	name = "pusty klosz akwarianina"
	desc = "Nowy szklany klosz z kołnierzem. Nalej do niego wody, przełóż rybkę (albo naczynie z rybką), a potem zamocuj klosz na pancerzu."
	icon = AQUARIAN_ICON
	icon_state = "dome_item"
	alpha = 90
	volume = AQUARIAN_DOME_VOLUME
	possible_transfer_amounts = list(5, 10, 25, 50, 100)
	w_class = WEIGHT_CLASS_NORMAL

/// update_icon() pojemników przekazuje dont_fill jako updates i nie odświeża stanu ikony, więc odświeżamy wprost
/obj/item/reagent_containers/glass/aquarian_dome/on_reagent_change(changetype)
	. = ..()
	update_appearance()

/// Szkło klosza to warstwa wody: pusty klosz jest jej bladą wersją, oprawa zostaje w pełnym kolorze
/obj/item/reagent_containers/glass/aquarian_dome/update_icon_state()
	. = ..()
	icon_state = "dome_item"
	alpha = reagents?.total_volume ? 255 : 90

/obj/item/reagent_containers/glass/aquarian_dome/update_overlays()
	. = ..()
	var/mutable_appearance/frame = mutable_appearance(AQUARIAN_ICON, "dome_item_front")
	frame.appearance_flags |= RESET_ALPHA
	. += frame

/datum/design/aquarian_dome
	name = "Klosz akwarianina"
	desc = "Pusty szklany klosz z kołnierzem. Przełożysz do niego rybkę z rozbitego klosza."
	id = "aquarian_dome"
	build_type = MECHFAB
	build_path = /obj/item/reagent_containers/glass/aquarian_dome
	materials = list(/datum/material/glass = 4000)
	construction_time = 100
	category = list("Cyborg")

/datum/techweb_node/cyborg/New()
	. = ..()
	design_ids += list("aquarian_shell", "aquarian_dome")

// Okno postaci

/// Rodzaj ryby w kloszu: przyciski z podglądem klosza
/datum/preference/choiced/aquarian_fish
	db_key = "feature_aquarian_fish"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	feature_key = FEATURE_AQUARIAN_FISH
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH
	main_feature_name = "Ryba"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/aquarian_fish/init_possible_values()
	var/list/values = list()
	for(var/fish in GLOB.aquarian_fish)
		values += fish
	return values

/datum/preference/choiced/aquarian_fish/get_display_names()
	return GLOB.aquarian_fish.Copy()

/datum/preference/choiced/aquarian_fish/read_value(datum/preferences/prefs)
	return aquarian_valid_fish(..())

/datum/preference/choiced/aquarian_fish/icon_for(value)
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	for(var/state in list("aquarian_head_m", "dome_back", "fish_[value]", "dome_front"))
		final_icon.Blend(icon(AQUARIAN_ICON, state, SOUTH, 1), ICON_OVERLAY)
	final_icon.Crop(9, 18, 24, 33)
	final_icon.Scale(32, 32)
	return final_icon

/datum/preference/choiced/aquarian_fish/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_aquarian_water"
	return data

/// Zabarwienie wody w kloszu (mnoży kolor wody, biały = bez zmian)
/datum/preference/color/aquarian_water
	db_key = "feature_aquarian_water"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	feature_key = FEATURE_AQUARIAN_WATER
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH

/datum/preference/color/aquarian_water/read_value(datum/preferences/prefs)
	return ..() || AQUARIAN_DEFAULT_WATER

/// Kolor płyt pancerza (fabrycznie czerwone)
/datum/preference/color/aquarian_armor
	db_key = "feature_aquarian_armor"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_AQUARIAN_ARMOR
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH
	can_randomize = TRUE

/datum/preference/color/aquarian_armor/read_value(datum/preferences/prefs)
	return ..() || AQUARIAN_DEFAULT_ARMOR

/// Pancerz: czerwony (z płytami do przemalowania) albo goły metal
/datum/preference/choiced/aquarian_body
	db_key = "feature_aquarian_body"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_AQUARIAN_BODY
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH
	can_randomize = TRUE

/datum/preference/choiced/aquarian_body/init_possible_values()
	var/list/values = list()
	for(var/body in GLOB.aquarian_bodies)
		values += body
	return values

/datum/preference/choiced/aquarian_body/get_display_names()
	return GLOB.aquarian_bodies.Copy()

/datum/preference/choiced/aquarian_body/read_value(datum/preferences/prefs)
	return aquarian_valid_body(..())

/// Wzór na ramionach w kolorze pancerza
/datum/preference/choiced/aquarian_pattern
	db_key = "feature_aquarian_pattern"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_AQUARIAN_PATTERN
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH
	can_randomize = TRUE

/datum/preference/choiced/aquarian_pattern/init_possible_values()
	var/list/values = list()
	for(var/pattern in GLOB.aquarian_patterns)
		values += pattern
	return values

/datum/preference/choiced/aquarian_pattern/get_display_names()
	return GLOB.aquarian_patterns.Copy()

/datum/preference/choiced/aquarian_pattern/read_value(datum/preferences/prefs)
	return aquarian_valid_pattern(..())

/// Kolor szarej ryby (ukleja); przy rybach we własnych kolorach ustawienie jest ukryte
/datum/preference/color/aquarian_fish_color
	db_key = "feature_aquarian_fish_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_AQUARIAN_FISH_COLOR
	relevant_mutant_bodypart = FEATURE_AQUARIAN_FISH

/datum/preference/color/aquarian_fish_color/is_accessible(datum/preferences/prefs)
	if(!..())
		return FALSE
	return (aquarian_valid_fish(prefs.active_character?.features[FEATURE_AQUARIAN_FISH]) in GLOB.aquarian_tinted_fish)

/datum/preference/color/aquarian_fish_color/read_value(datum/preferences/prefs)
	return ..() || AQUARIAN_DEFAULT_FISH_COLOR

// Opis w oknie wyboru gatunku

/datum/species/aquarian/get_species_description()
	return "Akwarianie to małe, rozumne ryby, które po stacji chodzą w szklanym kloszu z wodą \
		osadzonym na mechanicznym pancerzu. Pancerz da się naprawić spawarką, rybki już nie."

/datum/species/aquarian/get_species_lore()
	return list(
		"Na rodzimej planecie akwarian nie ma lądu, więc przez tysiące lat nie mieli powodu z wody wychodzić. \
			Zmienił to pierwszy kontakt z Nanotrasen: korporacja zaproponowała pancerze w zamian za kontrakty \
			pracownicze, a ciekawość świata za szybą okazała się silniejsza od rozsądku.",
		"Pancerz akwarianina to w połowie skafander, w połowie wózek inwalidzki. Rybka steruje nim drganiami płetw, \
			a głośnik zamienia jej bulgotanie na słowa, choć nigdy do końca. Pancerz można przemalować, wymienić albo \
			złożyć na nowo w robotyce. Klosza i rybki w środku już nie.",
		"Akwarianie bardzo pilnują swojej wody. Pęknięty klosz to dla nich to samo, co dla człowieka przebity skafander, \
			a kubek kawy wylany „do środka” bywa najgorszym żartem w ich życiu.",
	)

/datum/species/aquarian/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Mechaniczny pancerz",
			SPECIES_PERK_DESC = "Ciało to pancerz: nie krwawi, nie oddycha powietrzem i znosi próżnię. Naprawisz go spawarką i kablami, \
				a robotyka może go operować jak IPC. Po zniszczeniu pancerza żywa rybka odpada razem z kloszem i można ją przełożyć do nowego.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fish",
			SPECIES_PERK_NAME = "Chemia przez wodę",
			SPECIES_PERK_DESC = "Nie jesz ani nie pijesz jak inni. Co wlejesz do klosza (kubkiem, butelką, wiadrem), działa na rybkę, \
				a głód zaspokaja karma dla ryb z akwarium albo zmielone jedzenie wlane do wody. Wodę dolejesz też pustą ręką przy umywalce, celując w głowę.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Ryba bez wody",
			SPECIES_PERK_DESC = "Rybka oddycha wodą z klosza. Gdy wody jest mało, dusi się, a w pustym kloszu umiera. \
				Od uderzeń w głowę klosz pęka i woda wycieka, dopóki ktoś nie zaspawa głowy, a przez mocno wgnieciony pancerz woda sączy się jak krew. Mocno rozbity klosz rozpryskuje się, \
				a rybka wypada na podłogę: przeżyje tylko, jeśli ktoś szybko wpuści ją do wody albo do nowego klosza. Nożem da się z niej zrobić sushi.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Zimnokrwista rybka",
			SPECIES_PERK_DESC = "Zimna woda spowalnia rybkę, zamarzająca ją dusi, a gorąca parzy i paruje.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Woda przewodzi",
			SPECIES_PERK_DESC = "Porażenia prądem są dwa razy silniejsze, a impuls EMP na chwilę paraliżuje pancerz.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "hard-hat",
			SPECIES_PERK_NAME = "Klosz zamiast głowy",
			SPECIES_PERK_DESC = "Na kloszu nie zmieści się hełm, maska ani okulary. Czapki można nosić.",
		),
	)

#undef AQUARIAN_CHEM_RATE
#undef AQUARIAN_FEED_NUTRITION
#undef AQUARIAN_ITEM_SHIFT
#undef AQUARIAN_COLD_SLOWDOWN
