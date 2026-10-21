/datum/heretic_knowledge_tree_column/rust
	route = PATH_RUST
	ui_bgr = "node_rust"
	complexity = "Średnia"
	complexity_color = COLOR_YELLOW
	icon = list(
		"icon" = 'aquila/icons/obj/weapons/khopesh.dmi',
		"state" = "rust_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Ścieżka Rdzy to wytrzymałość, zepsucie i przebijanie się siłą przez przeszkody.",
		"Wybierz ją, jeśli lubisz trzymać pozycję i czekać, aż walka sama do ciebie przyjdzie.",
	)
	pros = list(
		"Na zardzewiałych polach jesteś bardzo wytrzymały: zasklepiasz rany i zrzucasz ogłuszenia.",
		"Zardzewiałe pola ranią i spowalniają twoich wrogów.",
		"Z łatwością niszczysz ściany, obiekty, mechy, struktury i śluzy.",
		"Swoim Mansus Grasp natychmiast unicestwiasz sylikony i syntetycznych członków załogi.",
		"Masz wiele zdolności zakłócających, które ułatwiają walkę na twoim terenie.",
	)
	cons = list(
		"Skrajnie jawna; o skradaniu się możesz zapomnieć.",
		"Poza zardzewiałymi polami jesteś znacznie bardziej bezbronny.",
		"Przywiązanie do własnego terenu ułatwia wrogom użycie przeciw tobie narzędzi niszczących (np. bomb).",
		"Twoja wielka siła obronna odbywa się kosztem siły ataku.",
	)
	tips = list(
		"Twój Mansus Grasp natychmiast niszczy mechy, sylikony i androidy. Uderzenie ostrzem w naznaczony cel wywołuje silne mdłości i wymioty, na chwilę go przewracając.",
		"Twój Mansus Grasp i zaklęcia rdzewią ściany i podłogi, co pomaga tobie, a szkodzi załodze i sylikonom. Szerz rdzę, ile się da.",
		"Zardzewiałe pola leczą cię, regulują temperaturę ciała, chronią przed przewróceniem pałką, odnawiają wytrzymałość i krew, a po ulepszeniu pasywki leczą też rany i kończyny.",
		"Zawsze walcz na swoim terenie. Przeciwnik, który na niego wejdzie, jest w dużo gorszym położeniu.",
		"Salvaged Remains działa w pełni tylko na zardzewiałych polach. Jeśli chcesz wycisnąć z niego wszystko, nie schodź z rdzy.",
		"Z każdym ulepszeniem pasywki łatwiej niszczysz obiekty i ściany; w końcu przetopisz śluzy, ściany wzmacniane, a nawet tytanowe.",
		"Szerzenie rdzy bywa powolne, zwłaszcza na początku. Przyzwij kilka Rust Walkerów, żeby pomogły ci poszerzyć domenę.",
		"Rust Construction pozwala stawiać osłony i drogi ucieczki, a w potrzebie odciąć komuś odwrót. Kształtuj nią otoczenie pod siebie.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	knowledge_tier1 = /datum/heretic_knowledge/spell/area_conversion
	guaranteed_side_tier1 = /datum/heretic_knowledge/rust_sower
	knowledge_tier2 = /datum/heretic_knowledge/spell/rust_construction
	guaranteed_side_tier2 = /datum/heretic_knowledge/summon/rusty
	robes = /datum/heretic_knowledge/armor/rust
	knowledge_tier3 = /datum/heretic_knowledge/spell/entropic_plume
	guaranteed_side_tier3 = /datum/heretic_knowledge/crucible
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	knowledge_tier4 = /datum/heretic_knowledge/spell/rust_charge
	ascension = /datum/heretic_knowledge/ultimate/rust_final

/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "Blacksmith's Tale"
	desc = "Otwiera przed tobą Ścieżkę Rdzy.<br>\
		Pozwala tworzyć Rusty Blade. \
		Naraz możesz mieć najwyżej dwa."
	transmute_text = "Transmutuj nóż i dowolny śmieć."
	gain_text = "\"Opowiem ci historię\" - rzekł Kowal, wpatrując się głęboko w swoje zardzewiałe ostrze."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'aquila/icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"
	mark_type = /datum/status_effect/eldritch/rust
	eldritch_passive = /datum/status_effect/heretic_passive/rust

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	user.RemoveElement(/datum/element/rust_healing, FALSE, 1.5, 5)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	user.AddElement(/datum/element/rust_healing, FALSE, 1.5, 5)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		for(var/obj/item/bodypart/robotic_limb as anything in carbon_target.get_bodyparts())
			if(IS_ROBOTIC_LIMB(robotic_limb))
				robotic_limb.receive_damage(500)

	if(!issilicon(target) && !(MOB_ROBOTIC in target.mob_biotypes))
		return

	source.do_rust_heretic_act(target)

/datum/heretic_knowledge/limited_amount/starting/base_rust/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/spell/rust_charge
	name = "Rust Charge"
	desc = "Pozwala wykonać potężną szarżę, gdy stoisz na zardzewiałym polu.<br>\
		Podczas szarży szerzysz rdzę, niszczysz zardzewiałe obiekty i zadajesz duże obrażenia każdemu, w kogo uderzysz."
	gain_text = "Wzgórza lśniły teraz, a gdy się do nich zbliżałem, mój umysł zaczął błądzić. Szybko odzyskałem determinację i parłem naprzód - ten ostatni odcinek miał być najzdradliwszy."

	// AQUILA - u nas nie ma /datum/action/cooldown/mob_cooldown/charge, szarża jest zaklęciem z celowaniem
	action_to_add = /datum/action/cooldown/spell/pointed/rust_charge
	cost = 2
	is_final_knowledge = TRUE
	max_charges = INFINITY

/datum/heretic_knowledge/spell/rust_construction
	name = "Rust Construction"
	desc = "Daje ci Rust Construction, zaklęcie wznoszące ścianę z zardzewiałej podłogi.<br>\
		Każdy, kto stoi w miejscu ściany, zostanie odrzucony na bok (albo w górę) i odniesie obrażenia."
	gain_text = "W mojej głowie zaczęły tańczyć obrazy obcych, złowieszczych budowli. Pokryte od stóp do głów grubą rdzą, \
		nie wyglądały już na dzieło człowieka. A może nigdy nim nie były."
	action_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 2
	max_charges = 20
	path_recharge_amount = 0.2
	focus_recharge_amount = 0.5
	holywater_drain_amount = 0.1

/datum/heretic_knowledge/armor/rust
	desc = "Stwórz Salvaged Remains.<br>\
		Na rdzy daje dodatkowy pancerz, odporność na powalenie i na strzykawki."
	transmute_text = "Transmutuj stół (albo kombinezon), maskę i dowolny śmieć."
	gain_text = "Spod pogiętego złomu Kowal wyciąga starożytną tkaninę. \
		\"Cokolwiek kiedyś oznaczała, zostało zapomniane. Więc nadamy jej nowy cel.\""
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust)
	research_tree_icon_state = "rust_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/trash = 1,
	)

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Daje ci Aggressive Spread, zaklęcie rozsiewające rdzę na pobliskie powierzchnie.<br>\
		Już zardzewiałe powierzchnie zostają zniszczone.<br>Wzmacnia rdzewienie u heretyków spoza Ścieżki Rdzy."
	gain_text = "Każdy mędrzec wie, by nie odwiedzać Rdzawych Wzgórz... A jednak opowieść Kowala była inspirująca."
	required_atoms = list(
		/obj/item/storage/toolbox = 1,
	)
	action_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 2
	research_tree_icon_frame = 5
	max_charges = 12
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.33
	holywater_drain_amount = 0.16
	transmute_text = "Można ją ręcznie doładować rytuałem ze skrzynką narzędziową."

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	desc = "Twój Rusty Blade przyprawia teraz trafionych wrogów o mdłości.<br>Pozwala rdzewieć tytan i plastytan."
	gain_text = "Kowal podaje ci swoje ostrze. \"Ostrze poprowadzi cię przez ciało, jeśli mu pozwolisz.\" \
		Ciężka rdza je przygniata. Wpatrujesz się w nie głęboko. Rdzawe Wzgórza cię teraz wzywają."
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.adjust_disgust(50)

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "Daje ci Entropic Plume, zaklęcie uwalniające dokuczliwą falę rdzy.<br>\
		Oślepia, truje i wpędza w amok każdego trafionego poganina, przez co atakuje on na oślep \
		przyjaciół i wrogów.<br>Rdzewieje też i niszczy powierzchnie, w które trafi, \
		i wzmacnia rdzewienie u heretyków spoza Ścieżki Rdzy."
	gain_text = "Korozji nie dało się powstrzymać. Rdzy nie dało się zadowolić. \
		Kowala już nie ma, a ty trzymasz jego ostrze. Czempioni nadziei, Zwiastun Rdzy nadchodzi!"

	action_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 2
	drafting_tier = 5
	max_charges = 4
	path_recharge_amount = 0.25
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.25

/datum/heretic_knowledge/ultimate/rust_final
	name = "Rustbringer's Oath"
	desc = "Rytuał wniebowstąpienia Ścieżki Rdzy.<br>\
		Po jego ukończeniu z miejsca rytuału rdza rozleje się na każdą powierzchnię i nic jej nie zatrzyma.<br>\
		Dodatkowo na rdzy staniesz się niezwykle odporny: będziesz leczyć się trzy razy szybciej \
		i zyskasz odporność na wiele efektów i zagrożeń. Po wniebowstąpieniu zardzewisz niemal wszystko."
	transmute_text = "Transmutuj 3 zwłoki na mostku."
	gain_text = "Czempion rdzy. Kaziciel stali. Lękajcie się ciemności, bo nadszedł ZWIASTUN RDZY! \
		Kowal kuje naprzód! Rdzawe Wzgórza, WZYWAJCIE MOJE IMIĘ! UJRZYJCIE MOJE WNIEBOWSTĄPIENIE!"

	ascension_achievement = /datum/award/achievement/misc/rust_ascension
	announcement_text = "%SPOOKY% Lękajcie się rozkładu, bo Zwiastun Rdzy, %NAME%, dostąpił wniebowstąpienia! Nikt nie ucieknie przed korozją! %SPOOKY%"
	announcement_sound = 'aquila/sound/music/antag/heretic/ascend_rust.ogg'
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)

/datum/heretic_knowledge/ultimate/rust_final/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null

/datum/heretic_knowledge/ultimate/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(ritual_location)
		var/area/our_area = get_area(loc)
		if(!istype(our_area, ritual_location))
			loc.balloon_alert(user, "rytuał nieudany, musisz być w: [initial(ritual_location.name)]!") // "must be in bridge"
			return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	trigger(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	var/datum/action/cooldown/spell/aoe/rust_conversion/rust_spread_spell = locate() in user.actions
	rust_spread_spell?.cooldown_time /= 2

// I sure hope this doesn't have performance implications
/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (transform_turf.turf_flags & NO_RUST)
			continue
		var/dist = get_dist(center, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (2 SECONDS) * iterator)

/datum/heretic_knowledge/ultimate/rust_final/proc/transform_area(list/turfs)
	turfs = shuffle(turfs)
	var/numturfs = length(turfs)
	var/first_third = turfs.Copy(1, round(numturfs * 0.33))
	var/second_third = turfs.Copy(round(numturfs * 0.33), round(numturfs * 0.66))
	var/third_third = turfs.Copy(round(numturfs * 0.66), numturfs)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), first_third), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), second_third), 5 SECONDS * 0.33)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), third_third), 5 SECONDS * 0.66)

/datum/heretic_knowledge/ultimate/rust_final/proc/delay_transform_turfs(list/turfs)
	for(var/turf/turf as anything in turfs)
		turf.rust_heretic_act(RUST_RESISTANCE_ORGANIC)
		CHECK_TICK

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(source.is_touching_rust())
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			ADD_TRAIT(source, TRAIT_IGNOREDAMAGESLOWDOWN, type) // AQUILA - zamiast add_movespeed_mod_immunities
			immunities_active = TRUE
	else // If we're not on a rust turf, and we have given out our traits, nerf our guy
		if(immunities_active)
			source.remove_traits(conditional_immunities, type)
			REMOVE_TRAIT(source, TRAIT_IGNOREDAMAGESLOWDOWN, type)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER

	if(!source.is_touching_rust())
		return

	var/need_mob_update = FALSE
	var/base_heal_amt = 1 * DELTA_WORLD_TIME(SSmobs)
	need_mob_update += source.adjust_brute_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjust_oxy_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-base_heal_amt * 4, updating_stamina = FALSE)

	source.adjust_blood_volume(base_heal_amt, maximum = BLOOD_VOLUME_NORMAL)

	if(need_mob_update)
		source.updatehealth()
