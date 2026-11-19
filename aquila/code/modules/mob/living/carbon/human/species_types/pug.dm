// Mops (Pug), port z Goonstation (goonstation/goonstation: code/datums/mutantraces.dm /datum/mutantrace/pug, cecha „Pug” z traits.dm,
// emotki woof/wheeze z human/procs/emote.dm, podwójne duszenie z mob/living/carbon.dm, zatrucie czekoladą z Reagents-FoodDrink.dm,
// padanie po sprincie z mob/input.dm). Licencja CC BY-NC-SA 3.0, autorzy: zespół Goonstation. Grafika i dźwięki też z Goona.
// W Goonie mops to mutantrace z cechy postaci. U nas zwykła rasa z oknem postaci i umaszczeniem do wyboru.
// Pominięte: ogon jako narząd (u nas nakładka ciała), oczy mopsa jako narząd, 1% szans na kolor skóry, reakcje kotów i psów
// na mopsa, psie herbatniki (nie mamy ich), zapach smrodu z bioefektów.

/// Ile razy więcej obrażeń od duszenia dostaje mops (Goon: amount *= 2)
#define PUG_OXY_MULTIPLIER 2
/// Koszt szczeknięcia: Goon STAMINA_DEFAULT_WOOF_COST 15 z 200, u nas przeliczone na 250
#define PUG_WOOF_STAMINA 19
/// Szansa, że mops rzuci się za rzuconym przedmiotem (kość i części ciała zawsze)
#define PUG_FETCH_CHANCE 15

/// Umaszczenia mopsa (Goon special_styles): odmiana -> polska nazwa
GLOBAL_LIST_INIT(pug_coats, list(
	"fawn" = "Płowe",
	"black" = "Czarne",
	"chocolate" = "Czekoladowe",
	"apricot" = "Morelowe",
))

/datum/species/pug
	name = "\improper Mops"
	id = SPECIES_PUG
	species_traits = list(EYECOLOR)
	inherent_traits = list(TRAIT_FAILED_SPRINT_FLOP)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	default_features = list(FEATURE_PUG_COAT = "fawn", "body_size" = "Normal")
	use_skintones = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	mutanttongue = /obj/item/organ/tongue/pug
	goon_voice = "pug"

	species_chest = /obj/item/bodypart/chest/pug
	species_head = /obj/item/bodypart/head/pug
	species_l_arm = /obj/item/bodypart/l_arm/pug
	species_r_arm = /obj/item/bodypart/r_arm/pug
	species_l_leg = /obj/item/bodypart/l_leg/pug
	species_r_leg = /obj/item/bodypart/r_leg/pug

	/// Do kiedy trwa zatrucie czekoladą (Goon: status „poisoned”)
	var/poisoned_until = 0
	COOLDOWN_DECLARE(oxy_wheeze_cooldown)
	COOLDOWN_DECLARE(woof_wheeze_cooldown)

/mob/living/carbon/human/species/pug
	race = /datum/species/pug

/datum/species/pug/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	// Goon: połowa mopsów szczeka głosem „pugg”
	goon_voice = prob(50) ? "pugg" : "pug"
	if(!(C.dna.features[FEATURE_PUG_COAT] in GLOB.pug_coats))
		C.dna.features[FEATURE_PUG_COAT] = default_features[FEATURE_PUG_COAT]

/// Mops jest zatruty czekoladą
/datum/species/pug/proc/is_poisoned()
	return world.time < poisoned_until

/datum/species/pug/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(!is_poisoned() || H.stat == DEAD)
		return
	// Goon statusEffects.dm „poisoned”: trochę toksyn, mdłości, jęki i rozmazany wzrok
	H.adjustToxLoss(0.1)
	if(prob(5))
		H.adjust_disgust(5)
	if(prob(2))
		H.emote(pick("groan", "moan", "shiver"))
	if(prob(2))
		H.blur_eyes(rand(2, 4))

/datum/species/pug/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	// Goon: czekoladowe mleko truje 8 s za każdy tik, gorąca czekolada 4 s. U nas też kakao i budyń czekoladowy.
	if(istype(chem, /datum/reagent/consumable/milk/chocolate_milk))
		poisoned_until = max(poisoned_until, world.time) + 8 SECONDS
	else if(istype(chem, /datum/reagent/consumable/cocoa) || istype(chem, /datum/reagent/consumable/chocolatepudding))
		poisoned_until = max(poisoned_until, world.time) + 4 SECONDS
	return ..()

/datum/species/pug/handle_body(mob/living/carbon/human/H)
	. = ..()
	monke_replace_eye_icon(H, PUG_BODYPARTS_ICON)

/// Krótki ogonek mopsa (Goon: organ tail/pug, stany pug_under_suit i pug_over_suit). Widać go z tyłu i z boków, także na ubraniu.
/datum/species/pug/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	if(!H.get_bodypart(BODY_ZONE_CHEST) || HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/mutable_appearance/tail = mutable_appearance(PUG_BODYPARTS_ICON, "pug_[goon_species_variant(H, FEATURE_PUG_COAT, "pug_coats")]_tail", -BODY_FRONT_LAYER)
	monke_add_layer_overlays(H, list("[BODY_FRONT_LAYER]" = list(tail)))

/// Goon: każde duszenie boli mopsa podwójnie, a mops świszcze i kaszle
/mob/living/carbon/human/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && !forced && ispug(src))
		amount *= PUG_OXY_MULTIPLIER
		var/datum/species/pug/pug = dna.species
		if(stat == CONSCIOUS && COOLDOWN_FINISHED(pug, oxy_wheeze_cooldown))
			COOLDOWN_START(pug, oxy_wheeze_cooldown, 3 SECONDS)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), pick("wheeze", "cough"))
	return ..()

/// Goon: mops sprintuje do ostatka sił, a potem pada z zadyszką
/datum/component/carbon_sprint/commit_step(direct, turf/old_turf)
	. = ..()
	if(!HAS_TRAIT(carbon_parent, TRAIT_FAILED_SPRINT_FLOP) || !carbon_parent.stamina || carbon_parent.stamina.current >= SPRINT_COST)
		return
	if(carbon_parent.resting || carbon_parent.stat != CONSCIOUS)
		return
	stop_sprint()
	carbon_parent.set_resting(TRUE, TRUE)
	to_chat(carbon_parent, "<span class='warning'>Padasz na ziemię, zbyt zdyszany, by biec dalej!</span>")
	INVOKE_ASYNC(carbon_parent, TYPE_PROC_REF(/mob, emote), "wheeze")

/// Goon throw_response: mops czasem rzuca się za rzuconym przedmiotem, za kością albo kończyną zawsze
/mob/living/carbon/throw_item(atom/target)
	var/obj/item/thrown = get_active_held_item()
	. = ..()
	if(!. || !thrown || !thrown.throwing)
		return
	for(var/mob/living/carbon/human/dog in viewers(7, src))
		if(dog == src || !ispug(dog) || dog.incapacitated() || dog.stat != CONSCIOUS)
			continue
		if(!prob(PUG_FETCH_CHANCE) && !istype(thrown, /obj/item/bodypart) && !istype(thrown, /obj/item/stack/sheet/bone))
			continue
		dog.throw_at(get_turf(thrown), 1, 1)
		dog.visible_message("<span class='warning'>[dog] zatacza się.</span>")
		INVOKE_ASYNC(dog, TYPE_PROC_REF(/mob, emote), "woof")

// Mowa

/obj/item/organ/tongue/pug
	name = "język mopsa"
	desc = "Różowy, wiecznie wywieszony psi jęzor."
	say_mod = "szczeka"
	modifies_speech = TRUE

/// Goon speech modifier „pug”: rough -> ruff, pog -> pug
/obj/item/organ/tongue/pug/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return
	message = replacetext(message, "rough", "ruff")
	message = replacetext(message, "pog", "pug")
	speech_args[SPEECH_MESSAGE] = message

// Emotki (Goon /datum/mutantrace/pug/emote)

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(ispug(user) && !user.mind?.miming && !user.is_muzzled())
		return "warczy!"

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(ispug(user) && !user.mind?.miming)
		var/mob/living/carbon/human/dog = user
		var/datum/species/pug/pug = dog.dna.species
		return pug.goon_voice == "pugg" ? 'aquila/sound/species/pug/growl_pugg.ogg' : 'aquila/sound/species/pug/growl_pug.ogg'
	return ..()

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(ispug(user) && !user.mind?.miming)
		return 'aquila/sound/species/pug/sneeze.ogg'
	return ..()

/// Goon: mops podskakuje przy kichnięciu
/datum/emote/living/sneeze/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ispug(user))
		animate(user, pixel_y = 3, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(pixel_y = -6, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
		animate(pixel_y = 3, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/living/sniff/get_sound(mob/living/user)
	if(ispug(user) && !user.mind?.miming)
		return 'aquila/sound/species/pug/sniff.ogg'
	return ..()

/datum/emote/living/snore/get_sound(mob/living/user)
	if(ispug(user) && !user.mind?.miming)
		return 'aquila/sound/species/pug/snore.ogg'
	return ..()

/// Goon: mopsowi przy chrapaniu wydmuchuje się z nosa bańka
/datum/emote/living/snore/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!. || !ispug(user))
		return
	var/mutable_appearance/bubble = mutable_appearance('aquila/icons/mob/species/pug/snore.dmi', "snore_bubble")
	user.add_overlay(bubble)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, cut_overlay), bubble), 1.5 SECONDS)

/// Emotki tylko dla mopsa
/datum/emote/living/carbon/human/pug
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/pug/can_run_emote(mob/user, status_check = TRUE, intentional)
	return ispug(user) && ..()

/datum/emote/living/carbon/human/pug/wheeze
	key = "wheeze"
	key_third_person = "wheezes"
	name = "zaświszcz"
	message = "świszcze"
	sound = 'aquila/sound/species/pug/wheeze.ogg'
	sound_volume = 80
	cooldown = 2 SECONDS

/datum/emote/living/carbon/human/pug/woof
	key = "woof"
	key_third_person = "woofs"
	name = "szczeknij"
	message = "szczeka!"
	sound = 'aquila/sound/species/pug/woof.ogg'
	sound_volume = 60

/// Goon: szczekanie męczy. Bez sił mops zamiast szczeknąć dusi się, przewraca i świszcze.
/datum/emote/living/carbon/human/pug/woof/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/dog = user
	var/datum/species/pug/pug = dog.dna?.species
	if(!istype(pug) || !can_run_emote(user, TRUE, intentional))
		return FALSE
	dog.stamina?.adjust(-PUG_WOOF_STAMINA)
	if(dog.stamina?.current > 0 && COOLDOWN_FINISHED(pug, woof_wheeze_cooldown))
		return ..()
	if(!COOLDOWN_FINISHED(pug, woof_wheeze_cooldown))
		return FALSE
	COOLDOWN_START(pug, woof_wheeze_cooldown, 3 SECONDS)
	dog.adjustOxyLoss(PUG_WOOF_STAMINA)
	dog.Knockdown(4 SECONDS)
	INVOKE_ASYNC(dog, TYPE_PROC_REF(/mob, emote), "wheeze")
	return TRUE

/datum/emote/living/carbon/human/pug/sleuth
	key = "sleuth"
	key_third_person = "sleuths"
	name = "wywęsz"
	message = "węszy"
	sound = 'aquila/sound/species/pug/sniff.ogg'
	sound_volume = 50
	cooldown = 5 SECONDS

/datum/emote/living/carbon/human/pug/sleuth/select_message_type(mob/user, intentional)
	. = ..()
	if(. == message)
		return "węszy [pick("przenikliwie", "wnikliwie", "uważnie", "od niechcenia", "wytrwale", "intrygująco")]"

/datum/emote/living/carbon/human/pug/sleuth/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/dog = user
	var/datum/species/pug/pug = dog.dna?.species
	if(istype(pug) && pug.is_poisoned())
		to_chat(user, "<span class='warning'>Jest ci niedobrze i zupełnie nie masz ochoty węszyć!</span>")
		return FALSE
	. = ..()
	if(. && intentional)
		INVOKE_ASYNC(src, PROC_REF(choose_sleuth_target), dog)

/// Goon sleuth(): wybór czegoś w zasięgu ręki (też siebie) i opis zapachów, które na tym zostały
/datum/emote/living/carbon/human/pug/sleuth/proc/choose_sleuth_target(mob/living/carbon/human/dog)
	var/list/targets = list()
	var/list/used_names = list()
	for(var/atom/movable/candidate in range(1, dog))
		if(candidate == dog || candidate.invisibility > dog.see_invisible || !(isitem(candidate) || isliving(candidate) || isstructure(candidate) || ismachinery(candidate)))
			continue
		targets[avoid_assoc_duplicate_keys("[candidate.name]", used_names)] = candidate
	targets[avoid_assoc_duplicate_keys("[dog.name] (ty)", used_names)] = dog
	var/choice = tgui_input_list(dog, "Co chcesz wywęszyć?", "Węszenie", targets, timeout = 20 SECONDS)
	var/atom/movable/sniffed = targets[choice]
	if(!sniffed || QDELETED(dog) || QDELETED(sniffed) || dog.stat != CONSCIOUS || !dog.Adjacent(sniffed))
		return
	to_chat(dog, pug_sleuth_text(sniffed))

/// Zapachy jak w Goonie: każda osoba pachnie „kolorem” wyliczonym z odcisku palca. Pierwszy to nazwa, drugi narzędnik.
GLOBAL_LIST_INIT(pug_scents, list(
	list("szkarłat", "szkarłatem"), list("błękit", "błękitem"), list("zieleń", "zielenią"), list("fiolet", "fioletem"),
	list("złoto", "złotem"), list("srebro", "srebrem"), list("bursztyn", "bursztynem"), list("turkus", "turkusem"),
	list("róż", "różem"), list("granat", "granatem"), list("oliwka", "oliwką"), list("pomarańcz", "pomarańczą"),
	list("cytryna", "cytryną"), list("mięta", "miętą"), list("lawenda", "lawendą"), list("brąz", "brązem"),
	list("purpura", "purpurą"), list("krem", "kremem"), list("węgiel", "węglem"), list("rdza", "rdzą"),
))

/// Zapach przypisany odciskowi palca. form: 1 = mianownik, 2 = narzędnik
/proc/pug_scent(fingerprint, form = 1)
	var/list/scent = GLOB.pug_scents[(text2num(copytext(fingerprint, 1, 5), 16) % length(GLOB.pug_scents)) + 1]
	return scent[form]

/// Raport z węszenia (Goon forensic_group/basic_list/sleuth/get_sleuth_text)
/proc/pug_sleuth_text(atom/movable/sniffed)
	var/list/lines = list()
	var/own_print
	if(ishuman(sniffed))
		var/mob/living/carbon/human/H = sniffed
		if(H.dna?.uni_identity)
			own_print = rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)
			lines += "[sniffed] pachnie głównie [pug_scent(own_print, 2)]."
	var/list/prints = sniffed.return_fingerprints()
	var/first = TRUE
	for(var/print in prints)
		if(print == own_print)
			continue
		if(first)
			var/intensity = (findtext(sniffed.fingerprintslast, print) ? "mocno" : pick("słabo", "wyraźnie", "lekko", "trochę", "śladowo"))
			lines += "[sniffed] pachnie [intensity] [pug_scent(print, 2)]."
			first = FALSE
		else
			lines += "[pick("Wyczuwasz", "Wychwytujesz", "Rozpoznajesz", "Wąchasz", "Tropisz")] też [pick("słabą", "wyraźną", "lekką", "ledwie uchwytną")] [pick("nutę", "woń", "smużkę", "zapach")]: [pug_scent(print)]."
	if(!length(lines))
		return "<span class='notice'>Pachnie jak [sniffed], nic więcej.</span>"
	return "<span class='notice'>[jointext(lines, "<br>")]</span>"

// Okno wyboru gatunku

/datum/preference/choiced/goon_variant/pug_coat
	db_key = "feature_pug_coat"
	feature_key = FEATURE_PUG_COAT
	relevant_mutant_bodypart = FEATURE_PUG_COAT
	main_feature_name = "Umaszczenie"
	icon_file = PUG_BODYPARTS_ICON
	state_prefix = "pug"
	variant_list = "pug_coats"

/datum/species/pug/get_species_description()
	return "Czy mops naprawdę powinien być na stacji kosmicznej? Zupełnie się do kosmosu nie nadaje. \
		To właściwie obciążenie dla firm... Och, spójrz tylko na te uszka!"

/datum/species/pug/get_species_lore()
	return list(
		"Nikt już nie pamięta, który genetyk Nanotrasen uznał, że świat potrzebuje mopsów chodzących na dwóch nogach. \
		Pamięta za to każdy, kto choć raz próbował z takim przebiec korytarz: mops biegnie dzielnie, aż pada z zadyszką.",

		"Mopsy szczekają, chrapią, kichają i świszczą. Mają za to nos, który wywęszy, kto dotykał drzwi, kubka albo trupa, \
		i nie potrafią się powstrzymać, gdy ktoś rzuca kością.",
	)

/datum/species/pug/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "dog",
			SPECIES_PERK_NAME = "Psi nos",
			SPECIES_PERK_DESC = "Emotką *sleuth wywęszysz z bliska, kto dotykał przedmiotu albo osoby. Każdy pachnie po swojemu.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "lungs",
			SPECIES_PERK_NAME = "Płaski pysk",
			SPECIES_PERK_DESC = "Duszenie zadaje ci podwójne obrażenia, a do tego świszczesz i kaszlesz.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Zadyszka",
			SPECIES_PERK_DESC = "Sprintujesz do ostatka sił i wtedy padasz na ziemię. Szczekanie (*woof) też męczy, a bez sił kończy się upadkiem.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "cookie-bite",
			SPECIES_PERK_NAME = "Czekolada szkodzi",
			SPECIES_PERK_DESC = "Kakao, gorąca czekolada, czekoladowe mleko i budyń cię trują.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "Aport!",
			SPECIES_PERK_DESC = "Czasem rzucasz się za przedmiotem, który ktoś obok rzucił. Za kością albo kończyną zawsze.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "cut",
			SPECIES_PERK_NAME = "Bez fryzury",
			SPECIES_PERK_DESC = "Mopsy nie mają włosów ani zarostu, tylko krótką sierść w jednym z czterech umaszczeń.",
		),
	)

// Części ciała: stany pug_[umaszczenie]_[część], odmianę ustawia update_limb() (goon_species.dm)

/obj/item/bodypart/head/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_head"
	limb_id = "pug_fawn"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

/obj/item/bodypart/chest/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_chest"
	limb_id = "pug_fawn"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

/obj/item/bodypart/l_arm/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_l_arm"
	limb_id = "pug_fawn"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

/obj/item/bodypart/r_arm/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_r_arm"
	limb_id = "pug_fawn"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

/obj/item/bodypart/l_leg/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_l_leg"
	limb_id = "pug_fawn"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

/obj/item/bodypart/r_leg/pug
	icon = PUG_BODYPARTS_ICON
	static_icon = PUG_BODYPARTS_ICON
	icon_state = "pug_fawn_r_leg"
	limb_id = "pug_fawn"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_PUG_COAT
	goon_variant_prefix = "pug"
	goon_variant_list = "pug_coats"

#undef PUG_OXY_MULTIPLIER
#undef PUG_WOOF_STAMINA
#undef PUG_FETCH_CHANCE

// Wspólne z Żabą (amphibian.dm): nakładki oczu i dodatkowe warstwy rysowane po core (wcześniej w pliku małpoluda z Monke)
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
