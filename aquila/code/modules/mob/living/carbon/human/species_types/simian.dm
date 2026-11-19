// Małpoludzie (Simian), port z Monkestation2.0 (monkestation/code/modules/mob/living/carbon/human/species_type/simian.dm).
// U Monke to podtyp /datum/species/monkey. U nas małpa to osobny mob (/mob/living/carbon/monkey), więc małpolud jest
// zwykłym gatunkiem człowieka: małpie części ciała z Monke i to samo skrócenie sylwetki (filtry MONKEY_HEIGHT_MEDIUM z tg).
// Filtr leży na całym mobie (człowiek ma KEEP_TOGETHER), więc ubrania, czapki i trzymane przedmioty kurczą się razem z ciałem.

/// Klucze filtrów wzrostu (jak w tg/Monke)
#define SIMIAN_FILTER_TORSO "Monkey_Torso"
#define SIMIAN_FILTER_LEGS "Monkey_Legs"
#define SIMIAN_ICON 'aquila/icons/mob/species/simian/simian.dmi'
/// Monke: maxhealthmod 0.85
#define SIMIAN_HEALTH_MOD 0.85
/// Indeks języka w argumentach /mob/living/say() (SPEECH_LANGUAGE jest u nas zakomentowane)
#define SIMIAN_SPEECH_LANGUAGE 5
/// Monke: COLOR_MONKEY_BROWN
#define SIMIAN_DEFAULT_FUR "CD8765"

/datum/species/simian
	name = "\improper Małpolud"
	id = SPECIES_SIMIAN
	default_color = SIMIAN_DEFAULT_FUR
	species_traits = list(MUTCOLORS, EYECOLOR, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_VAULTING, TRAIT_MONKEYFRIEND)
	default_features = list("mcolor" = SIMIAN_DEFAULT_FUR, "tail_monkey" = "Monkey", "body_size" = "Normal")
	use_skintones = FALSE
	speedmod = -0.1 // u Monke małpie nogi: speed_modifier -0.05 każda
	stunmod = 1.3
	punchdamage = 3 // u Monke małpie ręce biją za 2 zamiast 1-10
	damage_overlay_type = "monkey"
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	meat = /obj/item/food/meat/slab/monkey
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	species_language_holder = /datum/language_holder/monkey
	mutanttongue = /obj/item/organ/tongue/simian
	deathsound = 'aquila/sound/voice/simian/deathsound.ogg'
	speech_sound = "monkey"

	species_chest = /obj/item/bodypart/chest/simian
	species_head = /obj/item/bodypart/head/simian
	species_l_arm = /obj/item/bodypart/l_arm/simian
	species_r_arm = /obj/item/bodypart/r_arm/simian
	species_l_leg = /obj/item/bodypart/l_leg/simian
	species_r_leg = /obj/item/bodypart/r_leg/simian

/mob/living/carbon/human/species/simian
	race = /datum/species/simian

/datum/species/simian/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	if(!C.dna.features["tail_monkey"])
		C.dna.features["tail_monkey"] = default_features["tail_monkey"]
	C.maxHealth = round(C.maxHealth * SIMIAN_HEALTH_MOD)
	C.updatehealth()
	apply_simian_height(C)

/datum/species/simian/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.maxHealth = round(C.maxHealth / SIMIAN_HEALTH_MOD)
	C.updatehealth()
	C.remove_filter(list(SIMIAN_FILTER_TORSO, SIMIAN_FILTER_LEGS))
	if(C.eyelid)
		C.eyelid.icon = 'icons/mob/human_face.dmi'

/// tg apply_height_filters dla MONKEY_HEIGHT_MEDIUM: tułów krótszy o 2 piksele, nogi o 4
/datum/species/simian/proc/apply_simian_height(mob/living/carbon/human/H)
	var/static/icon/cut_torso_mask = icon('aquila/icons/mutations/tg_core/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('aquila/icons/mutations/tg_core/cut.dmi', "Cut2")
	H.add_filter(SIMIAN_FILTER_TORSO, 1, displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2))
	H.add_filter(SIMIAN_FILTER_LEGS, 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4))

/datum/species/simian/random_name(gender, unique, lastname, attempts)
	if(unique)
		for(var/i in 1 to 10)
			. = simian_name(gender)
			if(!findname(.))
				break
		return
	return simian_name(gender)

/proc/simian_name(gender)
	return "[pick(gender == FEMALE ? GLOB.simian_names_female : GLOB.simian_names_male)] [pick(GLOB.simian_last_names)]"

// Pliki w pojedynczych cudzysłowach trafiają do .rsc, więc działają też po tools/deploy.sh (ten nie kopiuje aquila/strings)
GLOBAL_LIST_INIT(simian_names_male, splittext(trim(file2text('aquila/strings/names/simian_male_first.txt')), "\n"))
GLOBAL_LIST_INIT(simian_names_female, splittext(trim(file2text('aquila/strings/names/simian_female_first.txt')), "\n"))
GLOBAL_LIST_INIT(simian_last_names, splittext(trim(file2text('aquila/strings/names/simian_last.txt')), "\n"))

// Oczy małpoluda siedzą w innym miejscu niż ludzkie, więc podmieniamy plik ikony nakładki oczu z core
/datum/species/simian/handle_body(mob/living/carbon/human/H)
	. = ..()
	monke_replace_eye_icon(H, SIMIAN_ICON)

/// Podmienia plik ikony nakładki oczu narysowanej przez handle_body() (core rysuje oczy zawsze z human_face.dmi)
/datum/species/proc/monke_replace_eye_icon(mob/living/carbon/human/H, eye_icon)
	var/list/standing = H.overlays_standing[BODY_LAYER]
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(!length(standing) || !eyes || !icon_exists(eye_icon, eyes.eye_icon_state))
		return
	var/list/old_eyes = list()
	for(var/mutable_appearance/overlay in standing)
		if(overlay.icon == 'icons/mob/human_face.dmi' && overlay.icon_state == eyes.eye_icon_state)
			old_eyes += overlay
	if(!length(old_eyes))
		return
	// Najpierw zdejmujemy nakładki w starej postaci: cut_overlay szuka dokładnie tego wyglądu, który został nałożony
	H.remove_overlay(BODY_LAYER)
	for(var/mutable_appearance/overlay as anything in old_eyes)
		overlay.icon = eye_icon
	H.overlays_standing[BODY_LAYER] = standing
	H.apply_overlay(BODY_LAYER)
	// Mruganie bierze kształt oczu z tego samego pliku
	if(H.eyelid)
		H.eyelid.icon = eye_icon

/// Dokłada nakładki rasy do warstw już narysowanych przez core. to_add: "[warstwa]" -> lista nakładek
/datum/species/proc/monke_add_layer_overlays(mob/living/carbon/human/H, list/to_add)
	for(var/layer_key in to_add)
		var/layer = text2num(layer_key)
		var/list/existing = H.overlays_standing[layer]
		H.remove_overlay(layer)
		var/list/combined = existing ? existing.Copy() : list()
		combined += to_add[layer_key]
		H.overlays_standing[layer] = combined
		H.apply_overlay(layer)

/datum/species/simian/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	var/datum/sprite_accessory/simian_tail/tail = GLOB.simian_tails_list[H.dna.features["tail_monkey"] || default_features["tail_monkey"]]
	if(!tail || tail.icon_state == "none" || !H.get_bodypart(BODY_ZONE_CHEST))
		return
	if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
		return
	var/tail_color = forced_colour
	if(!tail_color && !HAS_TRAIT(H, TRAIT_HUSK))
		tail_color = "#[H.dna.features["mcolor"] || SIMIAN_DEFAULT_FUR]"
	var/list/to_add = list()
	for(var/layer in list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER))
		var/mutable_appearance/tail_overlay = mutable_appearance(tail.icon, "m_tail_monkey_[tail.icon_state]_[mutant_bodyparts_layertext(layer)]", -layer)
		tail_overlay.color = tail_color
		to_add["[layer]"] = list(tail_overlay)
	monke_add_layer_overlays(H, to_add)

/datum/species/simian/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source = null)
	. = ..()
	// Monke daje tłumacz na szyję przed ubraniem stroju. U nas po stroju, żeby nie wypchnąć krawata ani stetoskopu.
	var/obj/item/clothing/mask/translator/translator = new(H)
	if(H.equip_to_slot_if_possible(translator, ITEM_SLOT_NECK, disable_warning = TRUE))
		return
	if(H.equip_to_slot_if_possible(translator, ITEM_SLOT_MASK, disable_warning = TRUE))
		return
	if(H.equip_to_slot_if_possible(translator, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
		return
	if(!H.put_in_hands(translator))
		translator.forceMove(H.drop_location())

// Ogon (u Monke zewnętrzny organ z preferencją „Monkey Tail”)

GLOBAL_LIST_INIT(simian_tails_list, monke_init_accessories(/datum/sprite_accessory/simian_tail))

/// Lista akcesoriów jednego typu (nazwa -> datum), jak listy z make_datum_references_lists()
/proc/monke_init_accessories(prototype)
	var/list/accessories = list()
	init_sprite_accessory_subtypes(prototype, accessories)
	return accessories

/datum/sprite_accessory/simian_tail
	icon = SIMIAN_ICON

/datum/sprite_accessory/simian_tail/monkey
	name = "Monkey"
	icon_state = "default"

/datum/sprite_accessory/simian_tail/none
	name = "None"
	icon_state = "none"

/datum/preference/choiced/species_feature/simian_tail
	db_key = "feature_monkey_tail"
	feature_key = "tail_monkey"
	relevant_mutant_bodypart = "tail_monkey"
	main_feature_name = "Małpi ogon"
	should_generate_icons = TRUE
	accessory_list = "simian_tails_list"
	icon_key = "tail_monkey"
	icon_base_file = SIMIAN_ICON
	icon_base_state = "simian_chest"
	icon_color = "#cd8765"
	icon_dir = EAST
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/simian_tail/get_display_names()
	return list("Monkey" = "Małpi", "None" = "Brak")

/// Monke: Simian to część zestawu ras startowych, więc brakujące cechy dostają domyślne wartości od razu przy wyborze gatunku
/datum/preference/choiced/species/write_value(datum/preferences/prefs, value)
	. = ..()
	var/datum/character_save/character = prefs.active_character
	var/datum/species/species = character.pref_species
	if(!istype(species, /datum/species/simian))
		return
	for(var/feature in species.default_features)
		if(isnull(character.features[feature]))
			character.features[feature] = species.default_features[feature]

// Język i mowa

/obj/item/organ/tongue/simian
	name = "prymitywny język"
	desc = "Do agresywnego pokrzykiwania. I jedzenia bananów."
	say_mod = "pokrzykuje"
	liked_food = MEAT | FRUIT | BUGS
	disliked_food = CLOTH

// Krzyk i śmiech jak u Monke: małpie piski (SFX_SCREECH) i śmiech małpy
/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(issimian(user) && !user.mind?.miming)
		return pick_emote_sound(user, list('sound/creatures/monkey/monkey_screech_1.ogg', 'sound/creatures/monkey/monkey_screech_2.ogg',
			'sound/creatures/monkey/monkey_screech_3.ogg', 'sound/creatures/monkey/monkey_screech_4.ogg', 'sound/creatures/monkey/monkey_screech_5.ogg',
			'sound/creatures/monkey/monkey_screech_6.ogg', 'sound/creatures/monkey/monkey_screech_7.ogg', 'aquila/sound/voice/scream/skyrat_scream_monkey.ogg'))
	return ..()

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(issimian(user) && !user.mind?.miming)
		return 'aquila/sound/voice/simian/monkey_laugh_1.ogg'
	return ..()

/// AutoTłumacz MonkeTech: małpolud mówi tylko po małpiemu, a tłumacz na szyi albo twarzy przekłada jego mowę na wybrany język
/obj/item/clothing/mask/translator
	name = "AutoTłumacz MonkeTech"
	desc = "Małe urządzenie, które tłumaczy mowę."
	icon = 'aquila/icons/obj/clothing/simian_translator.dmi'
	icon_state = "translator"
	worn_icon = 'aquila/icons/obj/clothing/simian_translator.dmi'
	worn_icon_state = "translator_worn"
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_SMALL
	/// Na jaki język przekłada mowę
	var/current_language = /datum/language/common

/obj/item/clothing/mask/translator/examine(mob/user)
	. = ..()
	var/datum/language/language = current_language
	. += "<span class='notice'>Tłumaczy na: [initial(language.name)]. Użyj go w ręce, aby wybrać język.</span>"

/obj/item/clothing/mask/translator/attack_self(mob/user)
	. = ..()
	var/datum/language_holder/holder = user.get_language_holder()
	var/list/choices = list()
	for(var/datum/language/language as anything in holder.understood_languages)
		if(language in holder.blocked_languages)
			continue
		choices[initial(language.name)] = language
	if(length(choices) < 2)
		return
	var/choice = tgui_input_list(user, "Wybierz język, na który tłumacz ma przekładać mowę", "AutoTłumacz MonkeTech", sortList(choices))
	if(!choice || QDELETED(src) || !user.is_holding(src))
		return
	current_language = choices[choice]
	to_chat(user, "<span class='notice'>Tłumacz przekłada teraz na: [choice].</span>")

/obj/item/clothing/mask/translator/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_MASK || slot == ITEM_SLOT_NECK)
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech), override = TRUE)
	else
		UnregisterSignal(user, COMSIG_MOB_SAY)

/obj/item/clothing/mask/translator/handle_speech(datum/source, list/speech_args)
	if(obj_flags & EMAGGED)
		speech_args[SIMIAN_SPEECH_LANGUAGE] = pick(GLOB.all_languages)
	else
		speech_args[SIMIAN_SPEECH_LANGUAGE] = current_language

/obj/item/clothing/mask/translator/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	icon_state = "translator_emag"
	playsound(src, "sparks", 100, TRUE)
	to_chat(user, "<span class='warning'>Tłumacz iskrzy i zaczyna mieszać języki.</span>")

// Przeskakiwanie przez stoły (Monke: TRAIT_VAULTING w /datum/element/climbable)

/obj/structure/climb_structure(mob/living/user)
	if(!climbable || !HAS_TRAIT(user, TRAIT_VAULTING) || user.m_intent != MOVE_INTENT_RUN)
		return ..()
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] bierze rozbieg do [src].</span>", "<span class='notice'>Bierzesz rozbieg do [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained())
		adjusted_climb_time *= 2
	if(HAS_TRAIT(user, TRAIT_FREERUNNING))
		adjusted_climb_time *= 0.8
	if(HAS_TRAIT(user, TRAIT_FAST_CLIMBER))
		adjusted_climb_time *= 0.3
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time) && !QDELETED(src) && loc)
		. = simian_vault(user)
	structureclimber = null

/// Monke vault_over_object: rzut przez przeszkodę na 3 pola, czasem z przewróceniem się
/obj/structure/proc/simian_vault(mob/living/user)
	var/dir_step = get_dir(user, src)
	var/turf/target
	if((flags_1 & ON_BORDER_1) && (loc == user.loc || !(dir_step & REVERSE_DIR(dir))))
		target = get_step(src, dir)
	else
		target = get_ranged_target_turf(user, dir_step || user.dir, 3)
	density = FALSE
	. = user.throw_at(target, 3, 0.5)
	density = TRUE
	if(prob((locate(/obj/machinery) in get_turf(src)) ? 70 : 25))
		user.Knockdown(8)
	if(climb_stun)
		user.Immobilize(climb_stun)
	user.visible_message("<span class='warning'>[user] przeskakuje przez [src]!</span>", "<span class='notice'>Przeskakujesz przez [src]!</span>")
	log_combat(user, src, "vaulted over")

// Małpy nie atakują małpoludów (Monke: TRAIT_MONKEYFRIEND w monkey_behaviors.dm), chyba że te wcześniej je skrzywdziły
/datum/ai_behavior/monkey_set_combat_target/perform(delta_time, datum/ai_controller/controller, set_key, enemies_key)
	. = ..()
	var/mob/living/target = controller.blackboard[set_key]
	if(!isliving(target) || !HAS_TRAIT(target, TRAIT_MONKEYFRIEND))
		return
	var/list/enemies = controller.blackboard[enemies_key]
	if(enemies && enemies[target])
		return
	controller.clear_blackboard_key(set_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

// Opis do okna wyboru gatunku

/datum/species/simian/get_species_description()
	return "Małpoludzie to najbliżsi krewni ludzi. Nie myl ich z małpami: tak nazywa się bioinżynieryjne, \
		masowo produkowane stworzenia, które da się zapakować w małpią kostkę."

/datum/species/simian/get_species_lore()
	return list(
		"Na małpoludzi zawsze patrzono z góry. Porwane z Ooga-9 jako jednorazowe obiekty doświadczalne, \
		te rozumne małpy walczą o wolność, odkąd sięgają archiwa Nanotrasen, przez tajną organizację zwaną Gorączką Dżungli.",

		"Gdy jednak wynaleziono małpią kostkę, Nanotrasen przestało potrzebować rozumnych istot do doświadczeń, \
		więc nadało małpoludom podstawowe prawa i dalej je zatrudniało.",

		"Dla organizacji był to szczęśliwy zbieg okoliczności. Nagle stała się legalna, zyskała ogromne poparcie \
		i zbierała pochwały za walkę w małpim ruchu oporu. Z czasem zaczęły ją finansować wielkie małpie firmy, takie jak Bananotrasen.",

		"Organizacja skupia się wokół tak zwanej Alfy, czyli tego, kto dzierży największy kij.",
	)

/datum/species/simian/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Mała małpka",
			SPECIES_PERK_DESC = "Jesteś słabą istotą i masz mniej zdrowia niż większość (85%).",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Zwinność",
			SPECIES_PERK_DESC = "Małpoludzie biegają nieco szybciej niż inne gatunki.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Przeskakiwanie",
			SPECIES_PERK_DESC = "W biegu małpoludzie przeskakują przez stoły i barierki zamiast się na nie wspinać. Czasem kończy się to upadkiem.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Łatwo ich powalić",
			SPECIES_PERK_DESC = "Ogłuszenia trzymają cię dłużej. Małe pięści zadają też mniej obrażeń.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart",
			SPECIES_PERK_NAME = "Małpa małpy nie skrzywdzi",
			SPECIES_PERK_DESC = "Małpy bardziej cię lubią i nie atakują cię, chyba że je skrzywdzisz. Goryle już tak.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "language",
			SPECIES_PERK_NAME = "Małpia mowa",
			SPECIES_PERK_DESC = "Rozumiesz Wspólny, ale mówisz tylko po szympansiemu. Na start dostajesz AutoTłumacz MonkeTech, \
				który na szyi albo twarzy przekłada twoją mowę na Wspólny.",
		),
	)

// Części ciała z Monke (icons/mob/human/species/monkey/bodyparts.dmi): narysowane w ludzkim wzroście, skraca je filtr wzrostu

/obj/item/bodypart/head/simian
	icon = SIMIAN_ICON
	icon_state = "simian_head"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN
	is_dimorphic = FALSE

/obj/item/bodypart/chest/simian
	icon = SIMIAN_ICON
	icon_state = "simian_chest"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN
	is_dimorphic = FALSE

/obj/item/bodypart/l_arm/simian
	icon = SIMIAN_ICON
	icon_state = "simian_l_arm"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN

/obj/item/bodypart/r_arm/simian
	icon = SIMIAN_ICON
	icon_state = "simian_r_arm"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN

/obj/item/bodypart/l_leg/simian
	icon = SIMIAN_ICON
	icon_state = "simian_l_leg"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN

/obj/item/bodypart/r_leg/simian
	icon = SIMIAN_ICON
	icon_state = "simian_r_leg"
	husk_icon = SIMIAN_ICON
	husk_type = "simian"
	limb_id = SPECIES_SIMIAN

#undef SIMIAN_FILTER_TORSO
#undef SIMIAN_FILTER_LEGS
#undef SIMIAN_HEALTH_MOD
#undef SIMIAN_DEFAULT_FUR
#undef SIMIAN_ICON
#undef SIMIAN_SPEECH_LANGUAGE
