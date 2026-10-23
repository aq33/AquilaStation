// AQUILA - organy z tg przepięte na nasze API: on_mob_insert/on_mob_remove -> Insert/Remove, on_life() bez argumentów (co ~2 s)

/// Renders you unable to see people who were heretics at the time that this organ is gained
/obj/item/organ/eyes/corrupt
	name = "corrupt orbs"
	desc = "Te oczy widziały coś, czego nie powinny."
	icon = 'aquila/icons/obj/heretic_corrupt_organs.dmi'
	icon_state = "eyes_voidwalker"
	eye_color = "53277E" // COLOR_VOID_PURPLE bez #
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// What the penlight shows in the owner's eyes
	var/penlight_message = "SĄ ZAMKIEM, A ŚWIATŁO KLUCZEM! IM WYŻEJ SIĘ WZNOSZĘ, TYM BARDZIEJ-"
	/// The override images we are applying
	var/list/hallucinations

/obj/item/organ/eyes/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ, FALSE)
	AddElement(/datum/element/noticable_organ, "Ma szeroko rozszerzone źrenice i żadnych tęczówek. Coś porusza się w tej ciemności.", BODY_ZONE_PRECISE_EYES)

/obj/item/organ/eyes/corrupt/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if (owner != M || !M.client)
		return

	// AQUILA - u nas brak GLOB.human_list
	for (var/mob/living/carbon/human/check_human in GLOB.carbon_list)
		if (check_human == M)
			continue
		if (!IS_HERETIC(check_human) && !prob(5)) // Throw in some false positives
			continue
		var/image/invisible_man = image('aquila/icons/blanks/32x32.dmi', check_human, "nothing")
		invisible_man.override = TRUE
		LAZYADD(hallucinations, invisible_man)

	if (LAZYLEN(hallucinations))
		M.client.images |= hallucinations

/obj/item/organ/eyes/corrupt/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if (!LAZYLEN(hallucinations))
		return
	M?.client?.images -= hallucinations
	LAZYNULL(hallucinations)

/// Co widzi ktoś, kto świeci latarką w te oczy (wołane z /obj/item/flashlight/attack, zob. _compat/sacrifice.dm)
/obj/item/organ/eyes/corrupt/proc/penlight_examine(mob/living/viewer, obj/item/examtool)
	viewer.playsound_local(src, 'aquila/sound/effects/magic/magic_block_mind.ogg', 75, FALSE)
	if(!viewer.is_blind() && !IS_HERETIC_OR_MONSTER(viewer))
		to_chat(viewer, span_danger("Twoje oczy skwierczą w oczodołach, gdy atakują je nieziemskie energie!"))
		viewer.emote("scream")
		viewer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		viewer.cultslurring += 8 // AQUILA - zamiast speech/slurring/heretic na 15 s
		viewer.adjust_temp_blindness(5 SECONDS) //debounce basically.
		var/obj/item/organ/eyes/parboiled = viewer.getorganslot(ORGAN_SLOT_EYES)
		parboiled?.applyOrganDamage(40) //enough to blind, but not enough to blind *permanently*
	return "Oczy [owner] [span_hypnophrase(penlight_message)]"

/// Sometimes speak in incomprehensible tongues
/obj/item/organ/tongue/corrupt
	name = "corrupt tongue"
	desc = "Ten język mówi same kłamstwa."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS

/obj/item/organ/tongue/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Wnętrze ust tej osoby jest pełne gwiazd.", BODY_ZONE_PRECISE_MOUTH)

/obj/item/organ/tongue/corrupt/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(owner == M)
		M.apply_status_effect(/datum/status_effect/shadowspeak, 60)

/obj/item/organ/tongue/corrupt/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	M?.remove_status_effect(/datum/status_effect/shadowspeak)

/// Randomly secretes alcohol or hallucinogens when you're drinking something
/obj/item/organ/liver/corrupt
	name = "corrupt liver"
	desc = "Po tym, co widziałeś, przydałby ci się drink."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// How much extra ingredients to add?
	var/amount_added = 5
	/// What extra ingredients can we add?
	var/list/extra_ingredients = list(
		/datum/reagent/consumable/ethanol/pina_colada, // AQUILA - u nas brak pina_olivada
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/superlaughter,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/space_drugs, // AQUILA - u nas brak blastoff
		/datum/reagent/drug/happiness,
		/datum/reagent/drug/mushroomhallucinogen,
	)

/obj/item/organ/liver/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/liver/corrupt/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M)
		RegisterSignal(M, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank), override = TRUE)

/obj/item/organ/liver/corrupt/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M)
		UnregisterSignal(M, COMSIG_ATOM_EXPOSE_REAGENTS)

/// If we drank something, add a little extra
/obj/item/organ/liver/corrupt/proc/on_drank(mob/living/carbon/human, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
	// AQUILA - u nas metody podania to pojedyncze wartości, nie flagi
	if (methods != INGEST)
		return
	if (human.reagents?.has_reagent(/datum/reagent/water/holywater) || (locate(/datum/reagent/water/holywater) in reagents))
		return
	if (!human.reagents)
		return
	INVOKE_ASYNC(src, PROC_REF(add_extra_reagent), human)
	if (prob(20))
		to_chat(human, span_warning("Gdy bierzesz łyk, czujesz, że coś bulgocze ci w żołądku..."))

/// Dodaje losowy dodatek (poza obsługą sygnału, bo przelewanie odczynników może wywołać reakcje)
/obj/item/organ/liver/corrupt/proc/add_extra_reagent(mob/living/carbon/human)
	if (QDELETED(human) || !human.reagents)
		return
	human.reagents.add_reagent(pick(extra_ingredients), amount_added)

/// Rapidly become hungry if you are not digesting blood
/obj/item/organ/stomach/corrupt
	name = "corrupt stomach"
	desc = "Ten pasożyt domaga się plugawej diety, by dać się zaspokoić."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// Do we have an unholy thirst?
	var/thirst_satiated = FALSE
	/// Timer for when we get thirsty again
	var/thirst_timer
	/// How long until we prompt the player to drink blood again?
	COOLDOWN_DECLARE(message_cooldown)

/obj/item/organ/stomach/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Ta osoba jest niezdrowo blada.")

/obj/item/organ/stomach/corrupt/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M)
		RegisterSignal(M, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank), override = TRUE)

/obj/item/organ/stomach/corrupt/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M)
		UnregisterSignal(M, COMSIG_ATOM_EXPOSE_REAGENTS)

/// Check if we drank a little blood
/obj/item/organ/stomach/corrupt/proc/on_drank(atom/source, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
	if (methods != INGEST)
		return

	var/contains_blood = locate(/datum/reagent/blood) in reagents
	if (!contains_blood)
		return

	if (!thirst_satiated)
		to_chat(source, span_cult_italic("Pragnienie zostało zaspokojone... na razie."))
	thirst_satiated = TRUE
	deltimer(thirst_timer)
	thirst_timer = addtimer(VARSET_CALLBACK(src, thirst_satiated, FALSE), 3 MINUTES, TIMER_STOPPABLE | TIMER_DELETE_ME)

// AQUILA - u nas nie ma handle_hunger na żołądku, głód doliczamy w on_life() (co ~2 s)
/obj/item/organ/stomach/corrupt/on_life()
	. = ..()
	var/mob/living/carbon/human/human = owner
	if (!istype(human) || thirst_satiated || human.reagents?.has_reagent(/datum/reagent/water/holywater))
		return

	human.adjust_nutrition(-2)

	if (!COOLDOWN_FINISHED(src, message_cooldown))
		return
	COOLDOWN_START(src, message_cooldown, 30 SECONDS)

	var/static/list/blood_messages = list(
		"Krew...",
		"Wszyscy nagle wyglądają tak smakowicie.",
		"Ta krew...",
		"Jest w tobie pustka, którą wypełni tylko krew.",
		"Masz teraz wielką ochotę na krew.",
		"Czujesz, jak krew pędzi ci w żyłach.",
		"Myślisz o tym, by komuś przegryźć gardło.",
		"Burczy ci w brzuchu, a w ustach czujesz metaliczny posmak.",
	)
	to_chat(human, span_cult_italic(pick(blood_messages)))

/// Occasionally bombards you with spooky hands and lets everyone hear your pulse.
/obj/item/organ/heart/corrupt
	name = "corrupt heart"
	desc = "Jakie to zepsucie rozchodzi się wraz z krwią?"
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// What the stethoscope hears
	var/beat_noise = "ŁUP-ŁUP-ŁUPANIE DŁUTA O SZKŁO. OTWÓRZ PRZYSZŁOŚĆ, ROZBIJ-"
	/// How long until the next heart?
	COOLDOWN_DECLARE(hand_cooldown)

/obj/item/organ/heart/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/heart/corrupt/on_life()
	. = ..()
	if (!owner || !COOLDOWN_FINISHED(src, hand_cooldown) || IS_IN_MANSUS(owner) || !owner.needs_heart() || !beating || owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		return
	fire_curse_hand(owner)
	COOLDOWN_START(src, hand_cooldown, rand(6 SECONDS, 45 SECONDS)) // Wide variance to put you off guard

/// Co słyszy ktoś przykładający stetoskop (wołane z _compat/sacrifice.dm)
/obj/item/organ/heart/corrupt/proc/hear_beat_noise(mob/living/hearer)
	hearer.playsound_local(src, 'aquila/sound/effects/magic/hereticknock.ogg', 75, FALSE)
	if(!IS_HERETIC_OR_MONSTER(hearer))
		hearer.emote("scream")
		hearer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		hearer.cultslurring += 8 // AQUILA - zamiast speech/slurring/heretic na 15 s
		// AQUILA - tg: rana kłuta magicalearpain; u nas ciężka rana cięta głowy i uszkodzenie uszu
		if(iscarbon(hearer))
			var/mob/living/carbon/carbon_hearer = hearer
			var/obj/item/bodypart/head/regret = carbon_hearer.get_bodypart(BODY_ZONE_HEAD)
			if(!regret?.aq_force_wound(WOUND_SLASH, WOUND_SEVERITY_SEVERE))
				carbon_hearer.add_bleeding(BLEED_SURFACE)
			carbon_hearer.adjustEarDamage(15, 10)
			to_chat(hearer, span_userdanger("Z uszu cieknie ci krew!"))
	return "Serce [owner] wydaje z siebie [span_hypnophrase(beat_noise)]"

/// Sometimes cough out some kind of dangerous gas
/obj/item/organ/lungs/corrupt
	name = "corrupt lungs"
	desc = "Niektóre rzeczy POWINNY utonąć w smole."
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// What the stethoscope hears
	var/breath_noise = "TAJEMNE PIEŚNI ŁAMANIA, TWORZENIA I BUDZENIA SIĘ Z-"
	/// How likely are we not to cough every time we take a breath?
	var/cough_chance = 15
	/// How much gas to emit?
	var/gas_amount = 30
	/// What can we cough up?
	var/list/gas_types = list(
		GAS_BZ = 30,
		GAS_MIASMA = 50,
		GAS_PLASMA = 20,
	)

/obj/item/organ/lungs/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/lungs/corrupt/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	. = ..()
	if (!. || !H || IS_IN_MANSUS(H) || H.reagents?.has_reagent(/datum/reagent/water/holywater) || !prob(cough_chance))
		return
	H.emote("cough");
	var/chosen_gas = pick_weight(gas_types)
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.adjust_moles(chosen_gas, gas_amount)
	mix_to_spawn.set_temperature(H.bodytemperature)
	log_game("[key_name(H)] coughed some gas ([chosen_gas]) into the air due to their corrupted lungs at [AREACOORD(H)].")
	var/turf/open/our_turf = get_turf(H)
	if(istype(our_turf))
		our_turf.assume_air(mix_to_spawn)

/// Co słyszy ktoś przykładający stetoskop (wołane z _compat/sacrifice.dm)
/obj/item/organ/lungs/corrupt/proc/hear_breath_noise(mob/living/hearer)
	hearer.playsound_local(src, 'sound/magic/voidblink.ogg', 75, FALSE)
	if(!IS_HERETIC_OR_MONSTER(hearer))
		hearer.cultslurring += 8 // AQUILA - zamiast speech/slurring/heretic na 15 s
		hearer.emote("scream")
		hearer.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		hearer.adjustEarDamage(10, 20) // AQUILA - zamiast sound_damage(10, 40 SECONDS)
	return "Płuca [owner] wydają [span_hypnophrase(breath_noise)]"

/// It's full of worms
/obj/item/organ/appendix/corrupt
	name = "corrupt appendix"
	desc = "Jaka mroczna, kosmiczna siła w ogóle zawracałaby sobie głowę psuciem wyrostka?"
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	/// How likely are we to spawn worms?
	var/worm_chance = 2

/obj/item/organ/appendix/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Brzuch tej osoby jest wzdęty... i się wije.", BODY_ZONE_PRECISE_GROIN)

/obj/item/organ/appendix/corrupt/on_life()
	. = ..()
	if (!owner || IS_UNCONSCIOUS_OR_CRIT(owner) || owner.reagents?.has_reagent(/datum/reagent/water/holywater) || IS_IN_MANSUS(owner) || !SPT_PROB(worm_chance, 2))
		return
	// AQUILA - nasze vomit() nie przyjmuje typu wymiocin, więc robaki wymiotujemy ręcznie
	owner.visible_message(span_danger("[owner] wymiotuje robakami!"), span_userdanger("Wymiotujesz robakami!"))
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	owner.adjust_nutrition(-10)
	new /obj/effect/decal/cleanable/vomit/nebula/worms(get_turf(owner))
	owner.Knockdown(0.5 SECONDS)
