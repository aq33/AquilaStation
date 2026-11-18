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
))

/// Rodzaj ryby z zapisu albo domyślny
/proc/aquarian_valid_fish(fish)
	if(fish in GLOB.aquarian_fish)
		return fish
	return GLOB.aquarian_fish[1]

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
	meat = /obj/item/stack/sheet/iron{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 5}
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
	/// Duszenie się ryby (0-200), przepisywane na oxyloss pancerza
	var/fish_oxyloss = 0
	/// Wartość oxyloss ustawiona w ostatnim cyklu (do wykrycia leczenia)
	var/synced_oxyloss = 0
	/// Czy klosz jest teraz pęknięty
	var/cracked = FALSE
	/// Poziom wody na rysunku: 0 pusto, 1 mało, 2 dość
	var/drawn_water_state = 2
	COOLDOWN_DECLARE(warning_cooldown)

/obj/item/organ/brain/aquarian/Initialize(mapload)
	. = ..()
	create_reagents(AQUARIAN_DOME_VOLUME, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/water, AQUARIAN_DOME_VOLUME, reagtemp = T20C)
	update_icon()

/obj/item/organ/brain/aquarian/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
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
	..() // woła też C.update_hair(), które rysuje klosz
	name = initial(name)
	synced_oxyloss = 0

/obj/item/organ/brain/aquarian/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	..()
	C.remove_movespeed_modifier(AQUARIAN_COLD_SLOWDOWN)
	C.clear_alert("aquarian_water")
	update_icon()

/obj/item/organ/brain/aquarian/transfer_identity(mob/living/L)
	. = ..()
	name = "[initial(name)] ([L.real_name])"

/obj/item/organ/brain/aquarian/emp_act(severity)
	return // rybka nie ma elektroniki

/// Leżący klosz: woda i kołnierz są w stanie dome_item, nad nimi ryba (przesunięta w dół jak cały klosz) i przód
/obj/item/organ/brain/aquarian/update_overlays()
	. = ..()
	var/mutable_appearance/fish = mutable_appearance(AQUARIAN_ICON, "fish_[aquarian_valid_fish(fish_type)]")
	fish.pixel_y = -AQUARIAN_ITEM_SHIFT
	. += fish
	. += mutable_appearance(AQUARIAN_ICON, "dome_item_front")

/obj/item/organ/brain/aquarian/examine(mob/user)
	. = ..()
	. += water_examine_text()
	. += "<span class='notice'>Pływa w nim [lowertext(GLOB.aquarian_fish[aquarian_valid_fish(fish_type)])].</span>"

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

/// Warstwy klosza na kołnierzu, od tyłu: woda (zabarwiona, przy małej ilości blada, przy pustym kloszu brak), ryba, przód z odblaskiem
/obj/item/organ/brain/aquarian/proc/dome_overlays(layer, dir = 0)
	var/list/output = list()
	var/state = water_state()
	if(state)
		var/image/water = image(icon = AQUARIAN_ICON, icon_state = "dome_back", layer = layer, dir = dir)
		if(water_tint && water_tint != AQUARIAN_DEFAULT_WATER)
			water.color = "#[water_tint]"
		if(state == 1)
			water.alpha = 110
		output += water
	output += image(icon = AQUARIAN_ICON, icon_state = "fish_[aquarian_valid_fish(fish_type)]", layer = layer, dir = dir)
	output += image(icon = AQUARIAN_ICON, icon_state = "dome_front", layer = layer, dir = dir)
	return output

/obj/item/organ/brain/aquarian/proc/water_examine_text()
	var/list/lines = list()
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
	if(head && head.brute_dam >= AQUARIAN_CRACK_DAMAGE && reagents.total_volume)
		if(!cracked)
			cracked = TRUE
			to_chat(C, "<span class='userdanger'>Twój klosz pęka! Woda zaczyna wyciekać.</span>")
		spill(head.brute_dam / AQUARIAN_CRACK_DAMAGE)
	else if(cracked && (!head || head.brute_dam < AQUARIAN_CRACK_DAMAGE))
		cracked = FALSE
		to_chat(C, "<span class='notice'>Pęknięcie klosza jest uszczelnione.</span>")

	// Parowanie w gorącu
	if(temperature >= AQUARIAN_WATER_BOIL)
		reagents.remove_reagent(/datum/reagent/water, 3)
	else if(temperature >= AQUARIAN_WATER_HOT)
		reagents.remove_reagent(/datum/reagent/water, 0.5)

	// Reagenty w wodzie działają na rybę
	for(var/datum/reagent/reagent as anything in reagents.reagent_list.Copy())
		if(reagent.type == /datum/reagent/water)
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

/obj/item/organ/brain/aquarian/attackby(obj/item/O, mob/user, params)
	if(isliving(user) && (istype(O, /obj/item/fish_feed) || aquarian_pourable(O)))
		fill_from(O, user)
		return TRUE
	return ..()

/// Wkładanie klosza w pancerz bez klosza (np. nowy z fabrykatora egzoszkieletów)
/obj/item/organ/brain/aquarian/attack(mob/living/carbon/human/target, mob/living/user, params)
	if(!ishuman(target) || !isaquarian(target) || user.combat_mode || aquarian_dome(target))
		return ..()
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
	if(istype(source, /obj/item/fish_feed))
		feed_from(source, user)
		return
	if(!source.reagents?.total_volume)
		to_chat(user, "<span class='warning'>[source] jest pusty.</span>")
		return
	if(reagents.holder_full())
		to_chat(user, "<span class='warning'>Klosz jest pełny.</span>")
		return
	if(wearer && user != wearer)
		user.visible_message("<span class='warning'>[user] próbuje wlać zawartość [source] do klosza [wearer].</span>", \
			"<span class='notice'>Próbujesz wlać zawartość [source] do klosza [wearer].</span>")
		if(!do_after(user, 3 SECONDS, target = wearer) || owner != wearer || !source.reagents?.total_volume)
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

/// Karma dla ryb z akwarium: zaspokaja głód i trafia do wody razem z tym, co w niej było
/obj/item/organ/brain/aquarian/proc/feed_from(obj/item/fish_feed/feed, mob/living/user)
	if(owner && owner.nutrition >= NUTRITION_LEVEL_FULL)
		to_chat(user, "<span class='warning'>Rybka nie chce już jeść.</span>")
		return
	feed.reagents?.copy_to(src, feed.reagents.total_volume)
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
		to_chat(user, "<span class='warning'>[sink] jest sucha!</span>")
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

/atom/movable/screen/alert/aquarian_water
	name = "Mało wody w kloszu"
	desc = "Rybka dusi się bez wody. Dolej wody do klosza: kliknij pojemnikiem w swoją głowę albo pustą ręką w umywalkę (celując w głowę)."
	icon_state = "not_enough_oxy"

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

/obj/item/bodypart
	/// Kolor pancerza akwarianina (rrggbb), null = fabryczna czerwień
	var/aquarian_paint

/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(limb_id != SPECIES_AQUARIAN || dropping_limb || no_update)
		return
	var/mob/living/carbon/human/H = source || owner
	if(!ishuman(H) || !H.dna)
		return
	var/paint = aquarian_valid_color(H.dna.features[FEATURE_AQUARIAN_ARMOR], AQUARIAN_DEFAULT_ARMOR)
	aquarian_paint = paint == AQUARIAN_DEFAULT_ARMOR ? null : paint

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(!aquarian_paint || is_husked || !length(.))
		return
	var/state = "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]_paint"
	if(!(state in aq_pref_icon_states(AQUARIAN_ICON)))
		return
	var/image/paint = image(icon = AQUARIAN_ICON, icon_state = state, layer = -BODYPARTS_LAYER, dir = dropped ? SOUTH : 0)
	paint.color = "#[aquarian_paint]"
	. += paint

/// Inny kolor pancerza = inna ikona kończyny w pamięci podręcznej
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(BP.aquarian_paint)
		. += "-aqpaint[BP.aquarian_paint]"

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
	shell.real_name = "pusty pancerz akwarianina"
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

/datum/techweb_node/cyborg/New()
	. = ..()
	design_ids += "aquarian_shell"

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
				a głód zaspokaja karma dla ryb z akwarium. Wodę dolejesz też pustą ręką przy umywalce, celując w głowę.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Ryba bez wody",
			SPECIES_PERK_DESC = "Rybka oddycha wodą z klosza. Gdy wody jest mało, dusi się, a w pustym kloszu umiera. \
				Od uderzeń w głowę klosz pęka i woda wycieka, dopóki ktoś nie zaspawa głowy.",
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
