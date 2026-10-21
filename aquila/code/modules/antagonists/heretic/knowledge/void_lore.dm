/datum/heretic_knowledge_tree_column/void
	route = PATH_VOID
	ui_bgr = "node_void"
	complexity = "Łatwa"
	complexity_color = COLOR_GREEN
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "void_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Pustki to skradanie się, przenikliwy mróz, mobilność i rozhermetyzowanie.",
		"Wybierz ją, jeśli lubisz być zwinnym zabójcą, za którym wrogowie nie nadążają.",
	)
	pros = list(
		"Ochrona przed zagrożeniami kosmosu.",
		"Twoje zaklęcia nakładają kumulujący się efekt, który wychładza i spowalnia cele.",
		"Dużo zaklęć ruchu.",
		"Świetnie nadaje się do skradania.",
	)
	cons = list(
		"Choć kosmos ci nie szkodzi, poruszasz się w nim dużo gorzej niż na nogach.",
		"Trudno ci walczyć z przeciwnikami odpornymi na zimno.",
		"Trudno ci walczyć z sylikonami.",
	)
	tips = list(
		"Twój Mansus Grasp ucisza cele, więc świetnie nadaje się do cichych zabójstw (nie wyłącza jednak czujników kombinezonu - zrób to sam po zabójstwie). Chwyt nakłada też znak, który po wyzwoleniu Void Blade nakłada na cel maksymalną liczbę ładunków wychłodzenia pustki i spowalnia go do pełzania.",
		"W Void Cloak możesz ukryć jedno ze swoich ostrzy i Codex Cicatrix.",
		"Wychłodzenie pustki nakładają twoje zaklęcia, chwyt, znak i - po ulepszeniu - ostrze. Każdy ładunek spowalnia cel o 10% i stopniowo go wychładza, maksymalnie do 5 ładunków.",
		"Przy 5 ładunkach wychłodzenie pustki nie pozwala też celowi się ogrzać.",
		"Od początku zmiany jesteś odporny na niskie ciśnienie i zimno. Po ulepszeniu pasywki do poziomu 2 nie musisz oddychać. Wykorzystaj to.",
		"Void Prison zamyka cel w stazie na 10 sekund. Idealne, gdy walczysz z kilkoma przeciwnikami i chcesz odizolować ich po kolei.",
		"Void Conduit to twoja popisowa zdolność. Powoli niszczy okna i śluzy w swoim zasięgu. Użyj jej, żeby rozhermetyzować stację i poszerzyć swoją domenę.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	knowledge_tier1 = /datum/heretic_knowledge/spell/void_phase
	guaranteed_side_tier1 = /datum/heretic_knowledge/void_cloak
	knowledge_tier2 = /datum/heretic_knowledge/void_prison
	guaranteed_side_tier2 = /datum/heretic_knowledge/ether
	robes = /datum/heretic_knowledge/armor/void
	knowledge_tier3 = /datum/heretic_knowledge/spell/void_pull
	guaranteed_side_tier3 = /datum/heretic_knowledge/summon/maid_in_mirror
	blade = /datum/heretic_knowledge/blade_upgrade/void
	knowledge_tier4 = /datum/heretic_knowledge/void_conduit
	ascension = /datum/heretic_knowledge/ultimate/void_final

/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Glimmer of Winter"
	desc = "Otwiera przed tobą Ścieżkę Pustki.<br>\
		Pozwala tworzyć Void Blade. \
		Naraz możesz mieć najwyżej dwa."
	transmute_text = "Transmutuj nóż w temperaturze poniżej zera."
	gain_text = "Czuję migotanie w powietrzu, robi się wokół mnie coraz zimniej. \
		Zaczynam dostrzegać pustkę istnienia. Coś mnie obserwuje."
	required_atoms = list(/obj/item/kitchen/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "void_blade"
	mark_type = /datum/status_effect/eldritch/void
	eldritch_passive = /datum/status_effect/heretic_passive/void

// AQUILA - w tg ta procedura jest (błędnie) na wszystkich wiedzach startowych
/datum/heretic_knowledge/limited_amount/starting/base_void/get_extra_requirements()
	return "temperatura poniżej zera"

/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "rytuał nieudany, złe miejsce!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "rytuał nieudany, za ciepło!")
		return FALSE

	return ..()

/datum/heretic_knowledge/limited_amount/starting/base_void/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.adjust_silence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/spell/void_phase
	name = "Void Phase"
	desc = "Daje ci Void Phase, zaklęcie teleportacji na dużą odległość we wskazane miejsce.<br>\
		Rani pogan wokół miejsca, z którego znikasz, i tego, w którym się pojawiasz."
	gain_text = "Istota nazywa siebie Arystokratą. Bez wysiłku kroczy przez powietrze, zostawiając za sobą ostry, \
		zimny powiew. Znika, a ja zostaję w zamieci."
	action_to_add = /datum/action/cooldown/spell/pointed/void_phase
	cost = 2
	research_tree_icon_frame = 7
	max_charges = 4
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/void_prison
	name = "Void Prison"
	desc = "Transmutuj kajdanki, pałkę ogłuszającą i szafę w temperaturze poniżej zera, by zdobyć Void Prison.<br>\
		Void Prison to kula, która po użyciu zamyka wszystkich nienaznaczonych pogan w pobliżu w kuli stazy na 10 sekund. \
		W kuli nie mogą mówić, działać ani odnieść obrażeń. Void Prison znika po jednym użyciu."
	transmute_text = "Transmutuj kajdanki, pałkę ogłuszającą i szafę w temperaturze poniżej zera."
	gain_text = "Najpierw widzę siebie, tańczącego walca na zasypanej śniegiem ulicy. \
		Próbuję krzyczeć, chwycić tego głupca i kazać mu uciekać. \
		Ale jedyne pręgi zostają na mojej własnej, bijącej pięści. \
		Moja uśmiechnięta twarz odwraca się ku mnie i w szklistych oczach odbija pustą ścieżkę, którą mnie poprowadzono."
	required_atoms = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/structure/closet = 1,
		/obj/item/melee/baton = 1,
	)
	result_atoms = list(/obj/item/void_prison)
	cost = 2
	drafting_tier = 5
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidball"

	var/list/closet_blacklist = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/body_bag,
		/obj/structure/closet/cardboard,
		/obj/structure/closet/infinite,
	)

/datum/heretic_knowledge/void_prison/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/structure/closet/closet in atoms)
		if(is_type_in_list(closet, closet_blacklist))
			atoms -= closet

/datum/heretic_knowledge/void_prison/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/closet in selected_atoms)
		closet.dump_contents()

	return ..()

/datum/heretic_knowledge/armor/void
	desc = "Stwórz Hollow Weave.<br>\
		Ta zbroja co jakiś czas niweluje ataki i daje ci krótki kamuflaż, żebyś mógł zmienić pozycję."
	transmute_text = "Transmutuj stół (albo kombinezon) i maskę w temperaturze poniżej zera."
	gain_text = "Idąc przez zimne powietrze, doznaję nowego, wstrząsającego uczucia. \
		Tysiące niemal niedostrzegalnych nici czepiają się mojej postaci. \
		Z każdym krokiem dryfuję. \
		Nawet gdy słyszę chrzęst śniegu pod stopą, nie czuję nic."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/void)
	research_tree_icon_state = "void_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)

/datum/heretic_knowledge/armor/void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "rytuał nieudany, złe miejsce!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "rytuał nieudany, za ciepło!")
		return FALSE

	return ..()

/datum/heretic_knowledge/spell/void_pull
	name = "Void Pull"
	desc = "Daje ci Void Pull, zaklęcie przyciągające do ciebie wszystkich pogan w pobliżu i krótko ich ogłuszające."
	gain_text = "Wszystko przemija, ale co jeszcze zostaje? Jestem blisko końca tego, co się zaczęło. \
		Arystokrata znów mi się ukazuje. Mówi, że się spóźniłem. Jego przyciąganie jest ogromne, nie mogę zawrócić."

	action_to_add = /datum/action/cooldown/spell/aoe/void_pull
	cost = 2
	research_tree_icon_frame = 6
	max_charges = 4
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/blade_upgrade/void
	name = "Seeking Blade"
	desc = "Twoje ostrze zamraża teraz wrogów.<br>\
		Dodatkowo możesz atakować Void Blade odległe naznaczone cele, teleportując się tuż obok nich."
	gain_text = "Ulotne wspomnienia, ulotne kroki. Znaczę drogę zamarzniętą krwią na śniegu. Zasypaną i zapomnianą."

	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_void"

/datum/heretic_knowledge/blade_upgrade/void/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, atom/target, obj/item/melee/sickly_blade/blade)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(!living_target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)

/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)

/datum/heretic_knowledge/void_conduit
	name = "Void Conduit"
	desc = "Wzmacnia twoje ostrze, pozwalając rozedrzeć samą przestrzeń.<br>\
		Atak jednym z twoich Void Blade w kosmos otworzy przejście do pustki, \
		które rani i wychładza pogan w pobliżu oraz niszczy okna i śluzy w okolicy."
	notice = "Ostrze przepada w trakcie. Możesz też użyć tej zdolności na śniegu albo na dowolnym polu w całkowitej próżni."
	gain_text = "Szum w nieruchomym, zimnym powietrzu zmienia się w kakofoniczny grzechot. \
		W tym hałasie nie da się odróżnić brzęku szyb od ziejącej wiedzy, która odbija się echem w mojej czaszce. \
		Drzwi się nie zamkną. Nie zatrzymam już zimna."
	cost = 2
	is_final_knowledge = TRUE
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "void_rift"
	research_tree_icon_frame = 12

/datum/heretic_knowledge/void_conduit/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_PREATTACK, PROC_REF(on_blade_preattack))

/datum/heretic_knowledge/void_conduit/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_PREATTACK)

/datum/heretic_knowledge/void_conduit/proc/is_valid_turf(turf/open/affected_turf)
	// space is the obvious one, snow is for icebox
	if(isspaceturf(affected_turf) || is_heretic_snow_turf(affected_turf))
		return TRUE
	// works in any vacuum as a backup
	var/datum/gas_mixture/air = affected_turf.return_air()
	if(air?.return_pressure() <= 0)
		return TRUE
	return FALSE

/datum/heretic_knowledge/void_conduit/proc/is_valid_turf_callback(turf/open/affected_turf, mob/living/source, obj/item/sword)
	if(!source.is_holding(sword))
		return FALSE
	if(!is_valid_turf(affected_turf))
		return FALSE
	if(affected_turf.GetTemperature() > T0C)
		return FALSE
	return TRUE

/datum/heretic_knowledge/void_conduit/proc/on_blade_preattack(mob/living/source, atom/target, obj/item/sword)
	SIGNAL_HANDLER
	if(!isopenturf(target))
		return NONE

	var/turf/open/affected_turf = target
	if(!is_valid_turf(affected_turf))
		return NONE

	if(affected_turf.GetTemperature() <= T0C)
		INVOKE_ASYNC(src, PROC_REF(create_conduit), affected_turf, source, sword)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	to_chat(source, span_mansus("[sword] buczy od mocy, ale [target] jest za ciepłe, by otworzyć przejście!"))
	return NONE

/datum/heretic_knowledge/void_conduit/proc/create_conduit(turf/open/affected_turf, mob/living/source, obj/item/sword)
	playsound(source, 'aquila/sound/effects/cloth_rip.ogg', 50, TRUE) // funny thing is, can't hear sound in a vacuum
	to_chat(source, span_mansus("Wbijasz [sword] głęboko w [affected_turf], próbując rozedrzeć przejście do pustki!"))
	source.visible_message(
		span_hypnophrase("[source] wbija [sword.name] w [affected_turf] - \
			[isspaceturf(affected_turf) ? "ale zamiast niczego" : "wbrew oczekiwaniom"] z tego miejsca zaczyna płynąć mroczna energia!"),
		ignored_mobs = source,
	)
	var/obj/effect/temp_visual/void_conduit_opening/animation = new(affected_turf)
	if(!do_after(source, 5 SECONDS, target = affected_turf, extra_checks = CALLBACK(src, PROC_REF(is_valid_turf_callback), affected_turf, source, sword)))
		animate(animation, alpha = 0, time = 1 SECONDS)
		QDEL_IN(animation, 1 SECONDS)
		return
	to_chat(source, span_mansus("Przejście się otwiera, uwalniając burzę energii pustki! [sword] rozpryskuje się na milion drobnych odłamków!"))
	source.visible_message(
		span_hypnophrase("Otwiera się przejście do pustki, uwalniając burzę energii pustki!"),
		ignored_mobs = source,
	)
	new /obj/structure/void_conduit(affected_turf)
	source.dropItemToGround(sword)
	qdel(sword)
	playsound(source, SFX_SHATTER, 50, FALSE)

/datum/heretic_knowledge/ultimate/void_final
	name = "Waltz at the End of Time"
	desc = "Rytuał wniebowstąpienia Ścieżki Pustki.<br>\
		Po jego ukończeniu na stację spada gwałtowna burza śniegu pustki, \
		która zamraża i rani pogan. Ci w pobliżu zostaną uciszeni i zamrożeni jeszcze szybciej.<br>\
		Dodatkowo staniesz się odporny na skutki przebywania w kosmosie."
	transmute_text = "Transmutuj troje zwłok w temperaturze poniżej zera."
	gain_text = "Świat pogrąża się w ciemności. Stoję na pustym planie, z nieba spadają drobne płatki lodu. \
		Arystokrata stoi przede mną i przyzywa. Zatańczymy walca przy szeptach umierającej rzeczywistości, \
		gdy świat zginie na naszych oczach. Pustka obróci wszystko w nicość, UJRZYJCIE MOJE WNIEBOWSTĄPIENIE!"

	ascension_achievement = /datum/award/achievement/misc/void_ascension
	announcement_text = "%SPOOKY% Przybył szlachcic pustki, %NAME%, stąpający w Walcu, który kończy światy! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_void.ogg'
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/proximity_monitor/advanced/void_storm/heavy_storm

/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "rytuał nieudany, złe miejsce!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "rytuał nieudany, za ciepło!")
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), type)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(on_death))
	heavy_storm = new(user, 10)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.getorganslot(ORGAN_SLOT_EYES)
		// AQUILA - u nas zamiast color_cutoffs widzenie w ciemności
		if(heretic_eyes)
			heretic_eyes.see_in_dark = max(heretic_eyes.see_in_dark, 8)
			heretic_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		ascended_human.update_sight()

/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death() // Losing is pretty much dying. I think

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER

	for(var/atom/thing_in_range as anything in range(10, source))
		if(iscarbon(thing_in_range))
			var/mob/living/carbon/close_carbon = thing_in_range
			if(close_carbon.can_block_magic())
				continue
			if(IS_HERETIC_OR_MONSTER(close_carbon))
				close_carbon.apply_status_effect(/datum/status_effect/void_conduit)
				continue
			// AQUILA - adjust_silence_up_to(2 SECONDS, 20 SECONDS)
			if(close_carbon.silent < 10) // 20 sekund w tyknięciach Life
				close_carbon.adjust_silence(2 SECONDS)
			close_carbon.apply_status_effect(/datum/status_effect/void_chill, 1)
			close_carbon.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))
			close_carbon.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(istype(thing_in_range, /obj/machinery/door) || istype(thing_in_range, /obj/structure/door_assembly))
			var/obj/affected_door = thing_in_range
			affected_door.take_damage(rand(60, 80))

		if(istype(thing_in_range, /obj/structure/window) || istype(thing_in_range, /obj/structure/grille))
			var/obj/structure/affected_structure = thing_in_range
			affected_structure.take_damage(rand(20, 40))

		if(isturf(thing_in_range))
			var/turf/affected_turf = thing_in_range
			var/datum/gas_mixture/environment = affected_turf.return_air()
			environment?.set_temperature(environment.return_temperature() * 0.9)

	// Telegraph the storm in every area on the station.
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!storm)
		// AQUILA - podtyp bez obrażeń (nasz void_storm rani wszystkich na stacji)
		storm = new /datum/weather/void_storm/ascension(station_levels)
		storm.telegraph()

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_death(datum/source)
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)
	if(heavy_storm)
		QDEL_NULL(heavy_storm)
	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))

///Few checks to determine if we can deflect bullets
/datum/heretic_knowledge/ultimate/void_final/proc/can_deflect(mob/living/ascended_heretic)
	if(!(ascended_heretic.mobility_flags & MOBILITY_USE))
		return FALSE
	if(!isturf(ascended_heretic.loc))
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/void_final/proc/hit_by_projectile(mob/living/ascended_heretic, obj/item/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(ascended_heretic))
		return NONE

	ascended_heretic.visible_message(
		span_danger("Burza pustki wokół [ascended_heretic] odbija [hitting_projectile]!"),
		span_userdanger("Burza pustki chroni cię przed [hitting_projectile]!"),
	)
	// AQUILA - u nas brak klucza dźwięku SFX_VOID_DEFLECT
	playsound(ascended_heretic, pick('aquila/sound/effects/magic/void_deflect1.ogg', 'aquila/sound/effects/magic/void_deflect2.ogg', 'aquila/sound/effects/magic/void_deflect3.ogg'), 75, TRUE)
	var/atom/original_firer = hitting_projectile.firer
	hitting_projectile.firer = ascended_heretic
	// AQUILA - tg liczy kąt od (nowego) strzelca do broni; celujemy z powrotem w strzelca albo broń
	var/atom/bounce_target = hitting_projectile.fired_from || original_firer
	if(prob(75) && bounce_target)
		hitting_projectile.setAngle(get_angle(ascended_heretic, bounce_target))
	else
		hitting_projectile.setAngle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED
