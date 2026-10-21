/datum/heretic_knowledge_tree_column/moon
	route = PATH_MOON
	ui_bgr = "node_moon"
	complexity = "Trudna"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "moon_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Księżyca to poczytalność, sianie zamętu i niezgody oraz omijanie zwykłych zasad walki.",
		"Wybierz ją, jeśli masz już doświadczenie z heretykiem i chcesz spróbować czegoś zupełnie nietypowego, albo po prostu chcesz zagrać heretykiem-pacyfistą (tak, naprawdę!)."
	)
	pros = list(
		"Mnóstwo narzędzi do dezorientowania wrogów.",
		"Sieje chaos na stacji przez szaleńców.",
		"W Resplendent Regalia praktycznie nic cię nie unieruchomi."
	)
	cons = list(
		"Brak mobilności.",
		"Brak bezpośrednich sposobów na zadawanie obrażeń.",
		"Polega na zmyłkach i dezorientacji.",
		"Szaleńcy mogą stać się obciążeniem.",
		"Dość krucha mimo nietypowych mechanizmów ochrony.",
		"Śmierć w Resplendent Regalia kończy się krwawo.",
	)
	tips = list(
		"Twój Mansus Grasp wywołuje u ofiary krótkie halucynacje i nakłada znak, który po aktywacji Księżycowym ostrzem dezorientuje ją i uspokaja (spokój znika, jeśli ofiara naraz dostanie zbyt wiele obrażeń).",
		"Twoje Księżycowe ostrze jest wyjątkowe wśród ostrzy heretyka. Możesz go używać nawet jako pacyfista.",
		"Twoja pasywka daje pełną odporność na urazy mózgu i powoli leczy mózg. Ulepszaj ją, by wzmocnić leczenie.",
		"Resplendent Regalia całkiem zmienia zasady walki dla ciebie i przeciwników: jesteś odporny na wszelkie unieruchomienia, a wszystkie obrażenia (śmiertelne i nie) zamieniają się w uszkodzenia mózgu. Same szaty nie mają jednak pancerza, nie pozwalają używać broni palnej i czynią cię pacyfistą (Księżycowego ostrza nadal możesz używać).",
		"Księżycowy amulet pozwala przepuszczać jego moc przez Księżycowe ostrze. Gdy go włączysz, ostrze przestaje zadawać śmiertelne obrażenia, za to rani poczytalność i nie da się go zablokować. Możesz go wtedy używać także w szatach!",
		"Księżycowy amulet to kluczowa część twojego ekwipunku: gdy go nosisz, pasywka leczy mózg dwa razy szybciej.",
		"Gdy poczytalność przeciwników spadnie poniżej pewnego progu, stają się szaleńcami. Szaleńcy rzucają się na wszystkich (także na ciebie). Jeśli chcesz ich poświęcić (albo żeby dali ci spokój), uderz ich ponownie Księżycowym ostrzem, by ich uśpić.",
		"Ringleader's Rise przywołuje armię twoich klonów. Prawie nie zadają obrażeń, ale zaatakowane przez nie-heretyków wybuchają, raniąc poczytalność i mózg wszystkich wokół.",
		"Wniebowstąpienie daje aurę, która zamienia pobliskich w wiernych szaleńców. Osobom z implantem lojalności głowy wybuchają.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	knowledge_tier1 = /datum/heretic_knowledge/spell/mind_gate
	guaranteed_side_tier1 = /datum/heretic_knowledge/phylactery
	knowledge_tier2 = /datum/heretic_knowledge/moon_amulet
	guaranteed_side_tier2 = /datum/heretic_knowledge/codex_morbus
	robes = /datum/heretic_knowledge/armor/moon
	knowledge_tier3 = /datum/heretic_knowledge/spell/moon_parade
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	knowledge_tier4 = /datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final

/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Moonlight Troupe"
	desc = "Otwiera przed tobą Ścieżkę Księżyca.<br>\
		Pozwala tworzyć Lunar Blade. \
		Naraz możesz mieć tylko dwa."
	transmute_text = "Przemień 2 arkusze szkła i nóż."
	gain_text = "W świetle księżyca rozbrzmiewa śmiech."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/glass = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"
	mark_type = /datum/status_effect/eldritch/moon
	eldritch_passive = /datum/status_effect/heretic_passive/moon

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// AQUILA - tg daje komponent empatii; u nas empatię daje cecha (opis nastroju i stanu przy oględzinach)
	ADD_TRAIT(user, TRAIT_EMPATH, REF(src))

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_EMPATH, REF(src))

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		to_chat(target, span_danger("Słyszysz z góry echo śmiechu... ale stłumione i odległe."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("Słyszysz z góry echo śmiechu"))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")
	carbon_target.adjust_sanity(-30)

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Daje ci Mind Gate, zaklęcie, które przez 10 sekund ucisza, ogłusza, oślepia, \
		wywołuje halucynacje, dezorientację, niedotlenienie i uszkodzenia mózgu celu.<br>\
		Rzucenie zaklęcia uszkadza twój mózg."
	gain_text = "Mój umysł otwiera się jak brama, a jego wgląd pozwoli mi dostrzec prawdę."
	action_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 2
	max_charges = 6
	path_recharge_amount = 0.33
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.33

/datum/heretic_knowledge/moon_amulet
	name = "Moonlight Amulet"
	desc = "Wyrzeźbij Moonlight Amulet.<br>\
		Użyty na kimś o niskiej poczytalności doprowadza go do szału - atakuje każdego w pobliżu. \
		Jeśli poczytalność nie jest dość niska, psuje mu nastrój.<br>\
		Noszenie go leczy twój mózg i pozwala widzieć niewiernych przez ściany, \
		ale twoje ostrza przestają ranić ciało - zamiast tego ranią umysł."
	transmute_text = "Przemień 2 arkusze szkła, serce i krawat."
	gain_text = "Na czele parady stał on, księżyc skupiony w jedną masę, odbicie duszy."

	required_atoms = list(
		/obj/item/organ/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/neck/tie = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/moon_amulet)
	cost = 2

	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9

/datum/heretic_knowledge/armor/moon
	desc = "Stwórz Resplendant Regalia.<br>\
			Gdy je nosisz, jesteś pacyfistą, ale nic cię nie unieruchomi, \
			a wszystkie rodzaje obrażeń zamieniają się w uszkodzenia mózgu."
	gain_text = "Smugi światła i radości spływały z każdego rękawa tego wspaniałego stroju. \
			Trupa wirowała w opalizujących kaskadach, olśniewając widzów prawdą, której szukali. \
			Patrzyłem, skąpany w świetle, by odnaleźć samego siebie."
	notice = "Mimo pacyfikującego działania szat nadal możesz używać Księżycowych ostrzy, o ile nosisz TAKŻE Moonlight Amulet."
	transmute_text = "Przemień stół (albo strój), maskę i dwa arkusze szkła."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon)
	research_tree_icon_state = "moon_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/datum/heretic_knowledge/spell/moon_parade
	name = "Lunar Parade"
	desc = "Daje ci Lunar Parade, zaklęcie, które po krótkim ładowaniu wystrzeliwuje pocisk.<br>\
		Każdy trafiony musi dołączyć do parady i podążać za pociskiem, cierpiąc na halucynacje."
	gain_text = "Muzyka niczym odbicie duszy przyciągała ich, ciągnęli za nią jak ćmy do płomienia."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/moon_parade
	notice = "Ładunki z Moonlight Amulet nie mają limitu."
	cost = 2
	drafting_tier = 5
	max_charges = 4
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25
	path_recharge_can_surpass_cap = TRUE

/datum/heretic_knowledge/blade_upgrade/moon
	name = "Moonlight Blade"
	desc = "Twoje ostrze uszkadza mózg, wywołuje losowe halucynacje i rani poczytalność.<br>\
		Uszkadza mózg mocniej, jeśli ofiara jest obłąkana albo nieprzytomna."
	gain_text = "Jego dowcip był ostry jak brzytwa, przecinał kłamstwo, by dać nam radość."

	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"

/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		return

	target.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"upgraded path of moon blades", \
		)
	target.emote(pick("giggle", "laugh"))
	target.adjust_sanity(-10)
	var/datum/component/mood/target_mood = target.get_mood()
	if(!IS_UNCONSCIOUS_OR_CRIT(target) && (!target_mood || target_mood.sanity >= SANITY_NEUTRAL))
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10)
		return
	target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 25)

/datum/heretic_knowledge/spell/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Daje ci Ringleaders Rise, zaklęcie obszarowe, które uszkadza mózg i wywołuje halucynacje, tym silniejsze, im niższa poczytalność."
	gain_text = "Chwyciłem go za rękę i wznieśliśmy się, a ci, którzy ujrzeli prawdę, wznieśli się z nami. \
		Przewodnik wskazał w górę, a blade światło prawdy oświetliło nas jeszcze mocniej."
	notice = "Ładunki z Moonlight Amulet nie mają limitu."
	action_to_add = /datum/action/cooldown/spell/aoe/moon_ringleader
	cost = 2
	research_tree_icon_frame = 5
	is_final_knowledge = TRUE
	max_charges = 2
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25
	path_recharge_can_surpass_cap = TRUE

/datum/heretic_knowledge/ultimate/moon_final
	name = "The Last Act"
	desc = "Rytuał wniebowstąpienia Ścieżki Księżyca.<br>\
		Po jego ukończeniu stajesz się zwiastunem szaleństwa z aurą, która bez przerwy obniża poczytalność, \
		a członkowie załogi o dość niskiej poczytalności zamieniają się w akolitów.<br>\
		Jedna piąta załogi zamieni się w akolitów, którzy będą wykonywać twoje rozkazy i dostaną Moonlight Amulet."
	transmute_text = "Przemień 3 zwłoki z ponad 50 punktami uszkodzeń mózgu."
	gain_text = "Zanurkowaliśmy ku tłumowi, a jego dusza oderwała się w poszukiwaniu większej przygody. \
		Tam, gdzie Przewodnik zaczął paradę, ja poprowadzę ją aż do śmierci słońc. \
		BĄDŹCIE ŚWIADKAMI MOJEGO WNIEBOWSTĄPIENIA, KSIĘŻYC ZNÓW SIĘ UŚMIECHA I BĘDZIE SIĘ UŚMIECHAŁ NA WIEKI!"

	ascension_achievement = /datum/award/achievement/misc/moon_ascension
	announcement_text = "%SPOOKY% Śmiejcie się, bo przewodnik %NAME% wstąpił! \
						Prawda wreszcie pożre kłamstwo! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_moon.ogg'

/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)

	var/brain_damage = sacrifice.getOrganLoss(ORGAN_SLOT_BRAIN)
	// Checks if our target has enough brain damage
	if(brain_damage < 50)
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_MADNESS_IMMUNE, type)
	user.mind.add_antag_datum(/datum/antagonist/lunatic/master)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/amount_of_lunatics = 0
	var/list/lunatic_candidates = list()
	// AQUILA - u nas nie ma GLOB.human_list
	for(var/mob/living/carbon/human/crewmate in shuffle(GLOB.carbon_list))
		if(QDELETED(crewmate) || isnull(crewmate.client) || isnull(crewmate.mind) || IS_UNCONSCIOUS_OR_CRIT(crewmate) || crewmate.can_block_magic(MAGIC_RESISTANCE_MIND))
			continue
		var/turf/crewmate_turf = get_turf(crewmate)
		var/crewmate_z = crewmate_turf?.z
		if(!is_station_level(crewmate_z))
			continue
		lunatic_candidates += crewmate

	// Roughly 1/5th of the station will rise up as lunatics to the heretic.
	// We use either the (locked) manifest for the maximum, or the amount of candidates, whichever is larger.
	// If there's more eligible humans than crew, more power to them I guess.
	var/max_lunatics = CEILING(max(length(GLOB.data_core.locked), length(lunatic_candidates)) * 0.2, 1)

	for(var/mob/living/carbon/human/crewmate as anything in lunatic_candidates)
		if(amount_of_lunatics > max_lunatics)
			to_chat(crewmate, span_boldwarning("Czujesz niepokój, jakby przez krótką chwilę coś na ciebie patrzyło."))
			continue
		if(attempt_conversion(crewmate, user))
			amount_of_lunatics++

/datum/heretic_knowledge/ultimate/moon_final/proc/attempt_conversion(mob/living/carbon/convertee, mob/user)
	// Heretics, lunatics and monsters shouldn't become lunatics because they either have a master or have a mansus grasp
	if(IS_HERETIC_OR_MONSTER(convertee))
		to_chat(convertee, span_boldwarning("Wzniesienie [user] wpływa na słabych duchem. Ich umysły zostaną rozdarte." ))
		return FALSE
	// Mindshielded and anti-magic folks are immune against this effect because this is a magical mind effect
	// AQUILA - u nas implant lojalności daje TRAIT_MINDSHIELD, nie TRAIT_UNCONVERTABLE
	if(HAS_TRAIT(convertee, TRAIT_MINDSHIELD) || HAS_MIND_TRAIT(convertee, TRAIT_UNCONVERTABLE) || convertee.can_block_magic(MAGIC_RESISTANCE))
		to_chat(convertee, span_boldwarning("Czujesz, że coś cię przed czymś osłania." ))
		return FALSE

	if(!convertee.mind)
		return FALSE

	var/datum/antagonist/lunatic/lunatic = convertee.mind.add_antag_datum(/datum/antagonist/lunatic)
	if(!lunatic)
		return FALSE
	lunatic.set_master(user.mind, user)
	var/obj/item/clothing/neck/moon_amulet/amulet = new(convertee.drop_location())
	var/static/list/slots = list(
		LOCATION_NECK,
		LOCATION_HANDS,
		LOCATION_RPOCKET,
		LOCATION_LPOCKET,
		LOCATION_BACKPACK,
	)
	convertee.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
	INVOKE_ASYNC(convertee, TYPE_PROC_REF(/mob, emote), "laugh")
	return TRUE

/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER
	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS
	)

	for(var/mob/living/carbon/carbon_view in range(7, source))
		if(IS_UNCONSCIOUS_OR_CRIT(carbon_view))
			continue
		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue
		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MOON)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue
		// AQUILA - nastrój to u nas komponent; bez nastroju (np. małpy) nie ma poczytalności do rozbicia
		var/datum/component/mood/carbon_mood = carbon_view.get_mood()
		if(!carbon_mood)
			continue
		var/carbon_sanity = carbon_mood.sanity
		new /obj/effect/temp_visual/moon_ringleader(get_turf(carbon_view))
		if(carbon_view.confused > 0)
			to_chat(carbon_view, span_big(span_hypnophrase("TWOJA GŁOWA DUDNI TYSIĄCEM GŁOSÓW ZLANYCH W OBŁĄKAŃCZĄ KAKOFONIĘ DŹWIĘKÓW I MUZYKI. KAŻDA CZĄSTKA TWOJEJ ISTOTY KRZYCZY: „UCIEKAJ”.")))
		carbon_view.adjust_confusion(2 SECONDS)
		carbon_view.adjust_sanity(-20)

		if(carbon_sanity >= 10)
			continue
		// So our sanity is dead, time to fuck em up
		if(SPT_PROB(20, seconds_per_tick))
			to_chat(carbon_view, span_warning("to echo przechodzi przez ciebie!"))
		visible_hallucination_pulse(
			center = get_turf(carbon_view),
			radius = 7,
			hallucination_duration = 50 SECONDS
		)
		carbon_view.adjust_temp_blindness(5 SECONDS)
		if(should_mind_explode(carbon_view))
			to_chat(carbon_view, span_boldbig(span_red(\
				"TWOJE ZMYSŁY WIRUJĄ, GDY UMYSŁ OPLATA NIEZIEMSKA SIŁA, PRÓBUJĄCA NAPISAĆ CIĘ OD NOWA. \
				NIE ZDĄŻYSZ NAWET KRZYKNĄĆ, ZANIM TWÓJ IMPLANT URUCHOMI PSIONICZNE ZABEZPIECZENIE I ZABIERZE ZE SOBĄ TWOJĄ GŁOWĘ.")))
			var/obj/item/bodypart/head/head = carbon_view.get_bodypart(BODY_ZONE_HEAD)
			if(!head?.dismember())
				INVOKE_ASYNC(carbon_view, TYPE_PROC_REF(/mob, gib))
			var/datum/effect_system/reagents_explosion/explosion = new()
			explosion.set_up(1, get_turf(carbon_view), 0, 0)
			explosion.start()
		else
			attempt_conversion(carbon_view, source)


/datum/heretic_knowledge/ultimate/moon_final/proc/should_mind_explode(mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		return TRUE
	if(IS_CULTIST_OR_CULTIST_MOB(target))
		return TRUE
	return FALSE
