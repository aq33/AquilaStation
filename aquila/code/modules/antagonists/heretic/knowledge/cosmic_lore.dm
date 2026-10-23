/datum/heretic_knowledge_tree_column/cosmic
	route = PATH_COSMIC
	ui_bgr = "node_cosmos"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "cosmic_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Kosmosu to kontrola terenu, teleportacja i panowanie nad przestrzenią.",
		"Wybierz ją, jeśli lubisz dostosowywać się do otoczenia i myśleć nieszablonowo.",
	)
	pros = list(
		"Kontrolujesz ruch wrogów polami kosmicznymi.",
		"Swobodnie poruszasz się w kosmosie i wokół niego.",
		"Błyskawicznie teleportujesz się po stacji.",
		"Mylisz przeciwników barierą za barierą.",
	)
	cons = list(
		"Pola kosmiczne działają na wrogów dopiero, gdy rozsiejesz na nich gwiezdny znak.",
		"Stosunkowo niskie obrażenia.",
		"Słaba bezpośrednia obrona; wiele zależy od dobrego użycia zdolności.",
	)
	tips = list(
		"Twój Mansus Grasp nakłada gwiezdny znak i zostawia znak, który po zdetonowaniu przenosi przeciwnika z powrotem tam, gdzie go naznaczono, i na chwilę go paraliżuje.",
		"Kosmiczne runy błyskawicznie przenoszą cię między dwoma miejscami. Uwaga: korzystać z nich mogą też nie-heretycy. Bądź kreatywny i wprowadź przeciwników prosto w pułapkę - wychodzą z gwiezdnym znakiem!",
		"Stojąc na kosmicznej runie, kliknij siebie pustą ręką, żeby ją użyć.",
		"Osoby z gwiezdnym znakiem nie przejdą same przez twoje pola kosmiczne. Można je jednak przez nie przeciągnąć!",
		"Star Blast to zarówno sposób na przemieszczenie, jak i na unieruchomienie. Użyj go, żeby złapać kilka osób naraz w pola kosmiczne.",
		"Star Touch uniemożliwia celowi teleportację. Jeśli nie zerwie więzi, zaśnie i zostanie przeniesiony do twoich stóp.",
		"Zawsze warto zostawić jedną kosmiczną runę obok runy rytualnej - szybko porwiesz cele na ofiarę.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	knowledge_tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	knowledge_tier2 = /datum/heretic_knowledge/spell/star_blast
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/space_phase
	robes = /datum/heretic_knowledge/armor/cosmic
	knowledge_tier3 = /datum/heretic_knowledge/spell/star_touch
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	knowledge_tier4 = /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final

/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Eternal Gate"
	desc = "Otwiera przed tobą Ścieżkę Kosmosu.<br>\
		Pozwala tworzyć Cosmic Blades. \
		Możesz mieć naraz tylko dwa."
	transmute_text = "Przemień arkusz plazmy i nóż."
	gain_text = "Na niebie pojawiła się mgławica, a jej piekielne narodziny rozświetliły mnie. To był początek wielkiej transcendencji."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"
	mark_type = /datum/status_effect/eldritch/cosmic
	eldritch_passive = /datum/status_effect/heretic_passive/cosmic

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/limited_amount/starting/base_cosmic/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	to_chat(target, span_danger("Nad twoją głową pojawił się kosmiczny pierścień!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	create_cosmic_field(get_turf(source), source)

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Daje ci Cosmic Runes, zaklęcie tworzące dwie połączone runy do szybkiej teleportacji. \
		Przenoszony jest tylko ten, kto użyje runy, a użyć jej może każdy bez gwiezdnego znaku. \
		Osoby z gwiezdnym znakiem zostaną jednak przeniesione razem z kimś, kto użyje runy."
	gain_text = "Odległe gwiazdy wkradały się w moje sny, ryczące i wrzeszczące bez powodu. \
		Przemówiłem i usłyszałem echo własnych słów."
	action_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 2
	drafting_tier = 5
	max_charges = INFINITY

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Wystrzeliwuje bardzo wolny pocisk, który zostawia za sobą krótkotrwałą ścianę pól kosmicznych. \
		Trafieni zostają powaleni, a osoby w promieniu trzech pól dostają gwiezdny znak."
	gain_text = "Bestia była teraz zawsze za mną, a z każdą ofiarą przepływały przeze mnie słowa aprobaty."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 2
	max_charges = 4
	path_recharge_amount = 0.5
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/armor/cosmic
	desc = "Tworzy Starwoven Cloak.<br>Chroni przed zagrożeniami kosmosu \
		i pozwala noszącemu lewitować do woli."
	transmute_text = "Przemień stół (albo strój), maskę i arkusz plazmy."
	gain_text = "Niczym promienne sznury gwiazdy połączyły się w jedno na jedwabistym kształcie łopoczącego płaszcza, który jednocześnie okrywa i nie okrywa moich ramion. \
		Oczy Bestii spoczęły na mnie i patrzyły przeze mnie."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic)
	research_tree_icon_state = "cosmic_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Daje ci Star Touch, zaklęcie, które nakłada na cel gwiezdny znak \
		i tworzy pole kosmiczne pod tobą i na polach obok. Cele, które już mają gwiezdny znak, \
		zasną na 4 sekundy. Trafiona ofiara zostaje też połączona z tobą palącym promieniem. \
		Promień trwa, dopóki coś go nie przesłoni albo nie znajdziesz nowego celu."
	gain_text = "Obudziłem się zlany zimnym potem i poczułem dłoń na głowie i wypalony na mnie znak. \
		Moje żyły promieniowały teraz dziwnym fioletowym blaskiem; Bestia wie, że przerosnę jej oczekiwania."
	action_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 2
	max_charges = 4
	path_recharge_amount = 0.5
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Twoje ostrze nakłada gwiezdny znak i pozwala atakować naznaczonych pogan z większej odległości. \
		Twoje ataki przenoszą dodatkowe obrażenia na maksymalnie dwie poprzednie ofiary. \
		Kombinacja resetuje się po dwóch sekundach bez ataku albo gdy zaatakujesz kogoś, kto już jest w kombinacji. \
		Po trzech atakach z rzędu zostawiasz kosmiczny ślad, a czas kombinacji rośnie do dziesięciu sekund."
	gain_text = "Bestia wzięła moje ostrza w dłoń; uklęknąłem i poczułem ostry ból. \
		Ostrza lśniły teraz rozszczepioną mocą. Upadłem i płakałem u stóp bestii."
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/datum/weakref/second_target
	/// Storage for the third target.
	var/datum/weakref/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0
	/// How much further we can hit people, modified by ascension
	var/max_attack_range = 2
	/// AQUILA - czy mamy teraz kosmiczny ślad (żeby nie dodawać/zdejmować elementu na ślepo)
	var/trail_element

/datum/heretic_knowledge/blade_upgrade/cosmic/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	. = ..()
	if(!isliving(target) || get_dist(source, target) > max_attack_range || !target.has_status_effect(/datum/status_effect/star_mark))
		return
	source.changeNext_move(CLICK_CD_MELEE)
	return blade.attack(target, source)

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	target.adjust_fire_loss(5)
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'aquila/sound/effects/magic/cosmic_energy.ogg', 25, FALSE)
		second_target_resolved.adjust_fire_loss(14)
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'aquila/sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
			third_target_resolved.adjust_fire_loss(28)
			if(combo_counter == 3)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					if(!trail_element)
						trail_element = cosmic_trail_based_on_passive(source)
						source.AddElement(trail_element, /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = WEAKREF(target)

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	if(trail_element && source)
		source.RemoveElement(trail_element, /obj/effect/forcefield/cosmic_field/fast)
	trail_element = null
	combo_duration = combo_duration_amount
	combo_counter = 0
	if(source)
		new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = null

/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration < max_combo_duration)
		combo_duration += increase_amount

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "Daje ci Cosmic Expansion, zaklęcie, które tworzy wokół ciebie obszar 5x5 pól kosmicznych. \
		Pobliskie istoty dostają też gwiezdny znak."
	gain_text = "Ziemia zatrzęsła się pode mną. Bestia zamieszkała we mnie, a jej głos był odurzający."
	action_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 2
	is_final_knowledge = TRUE
	max_charges = 2
	path_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "Rytuał wzniesienia Ścieżki Kosmosu.<br>\
		Po jego ukończeniu otrzymujesz Star Gazera. \
		Rozkazujesz mu Alt+kliknięciem, przyciskiem akcji albo mową (\"za mną\", \"zostań\", \"wolny\", \"atakuj\" i wskazanie celu).<br>\
		Star Gazer to potężny sojusznik, który przebija się nawet przez wzmocnione ściany. \
		Jego aura leczy ciebie i rani przeciwników.<br>\
		Star Touch użyty w dłoni przeniesie cię do Star Gazera.<br>\
		Twoje zaklęcie Cosmic Expansion i ostrza stają się znacznie potężniejsze."
	transmute_text = "Przemień trzy zwłoki z gwiezdnym znakiem."
	gain_text = "Bestia wyciągnęła dłoń, chwyciłem ją, a ona przyciągnęła mnie do siebie. Jej ciało było ogromne, a jednak wydawało się tak małe i kruche wobec wszystkich opowieści, które zebrałem w głowie. \
		Przylgnąłem do niej - ona będzie chronić mnie, a ja ją. \
		Zamknąłem oczy z głową wspartą o jej ciało. Byłem bezpieczny. \
		UJRZYJCIE MOJE WZNIESIENIE!"

	ascension_achievement = /datum/award/achievement/misc/cosmic_ascension
	announcement_text = "%SPOOKY% Na stację przybył Star Gazer, %NAME% wzniósł się! Ta stacja to domena Kosmosu! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_cosmic.ogg'
	/// List of traits given once ascended
	var/static/list/ascended_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_XRAY_VISION)
	/// List of traits given to our cute lil guy
	var/static/list/stargazer_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_BOMBIMMUNE, TRAIT_XRAY_VISION)

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_status_effect(/datum/status_effect/star_mark)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(ascended_traits, type)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.getorganslot(ORGAN_SLOT_EYES)
		if(heretic_eyes) // tg: color_cutoffs = list(30, 30, 30)
			heretic_eyes.see_in_dark = 8
			heretic_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		ascended_human.update_sight()

	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/simple_animal/hostile/heretic_summon/star_gazer(loc, user)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	// AQUILA - zamiast /datum/component/obeys_commands: rozkazy przez Alt+klik, przycisk i mowę (zob. star_gazer.dm)
	var/datum/action/cooldown/star_gazer_commands/commands_action = new(user)
	commands_action.set_gazer(star_gazer_mob)
	commands_action.Grant(user)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = locate() in user.actions
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE
	star_gazer_mob.add_traits(stargazer_traits, type)
	star_gazer_mob.leash_to(star_gazer_mob, user)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	if(blade_upgrade)
		blade_upgrade.combo_duration = 10 SECONDS
		blade_upgrade.combo_duration_amount = 10 SECONDS
		blade_upgrade.max_combo_duration = 30 SECONDS
		blade_upgrade.increase_amount = 2 SECONDS
		blade_upgrade.max_attack_range = 3

	var/datum/action/cooldown/spell/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.actions
	cosmic_expansion_spell?.ascended = TRUE

	var/datum/action/cooldown/replace_star_gazer/replace_gazer = new(user)
	replace_gazer.Grant(user)
	replace_gazer.bad_dog = WEAKREF(star_gazer_mob)

/// Replace an annoying griefer you were paired up to with a different but probably no less annoying player.
/datum/action/cooldown/replace_star_gazer
	name = "Reset Star Gazer Consciousness"
	desc = "Zastępuje umysł twojego przywołańca umysłem innego ducha."
	icon_icon = 'aquila/icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"
	background_icon_state = "bg_ecult"
	check_flags = NONE
	cooldown_time = 5 SECONDS
	/// Weakref to the stargazer we care about
	var/datum/weakref/bad_dog

/datum/action/cooldown/replace_star_gazer/Trigger()
	if(!..())
		return FALSE
	var/mob/living/to_reset = bad_dog?.resolve()
	if(!to_reset)
		return FALSE
	// Na czas ankiety długie odnowienie, żeby nie spamować
	next_use_time = world.time + 5 MINUTES
	UpdateButtonIcon()
	INVOKE_ASYNC(src, PROC_REF(do_reset), to_reset)
	return TRUE

/datum/action/cooldown/replace_star_gazer/proc/do_reset(mob/living/to_reset)
	to_chat(owner, span_mansus("Nakłaniasz [to_reset] do zmiany osobowości..."))
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(new /datum/poll_config(
		question = "Czy chcesz zagrać jako [span_danger("[owner.real_name]")] - [span_notice(to_reset.name)]?",
		check_jobban = ROLE_PAI,
		poll_time = 10 SECONDS,
		alert_pic = to_reset,
		jump_target = owner,
		role_name_text = to_reset.name,
		amount_to_pick = 1,
	))
	if(isnull(chosen_one) || QDELETED(to_reset))
		to_chat(owner, span_mansus("Twoja prośba o zmianę osobowości [to_reset] chyba została odrzucona... Na razie musisz z nim wytrzymać."))
		StartCooldown()
		return FALSE
	to_chat(to_reset, span_mansus("Twój przywoływacz cię zresetował, a twoje ciało przejął duch. Chyba nie był zadowolony z twojej roboty."))
	to_chat(owner, span_mansus("Umysł [to_reset] przekształcił się, by lepiej ci służyć."))
	message_admins("[key_name_admin(chosen_one)] has taken control of ([ADMIN_LOOKUPFLW(to_reset)])")
	to_reset.ghostize(FALSE)
	to_reset.key = chosen_one.key
	StartCooldown()
	return TRUE
