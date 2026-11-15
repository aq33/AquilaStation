/**
 * AQUILA - wybór silnika statku przez inżynierów.
 *
 * Gracz ustawia w preferencjach „Preferowany silnik statku”. Przy ładowaniu mapy spawner silnika losuje wariant
 * jak dotąd (statek w lobby ma działający silnik). Po rozdaniu profesji, zanim gracze pojawią się na statku,
 * gra liczy wybór: decyduje Główny Inżynier, a bez niego (albo gdy wybrał „Losowy”) większość inżynierów.
 * Jeśli wynik różni się od wylosowanego wariantu, slot dostaje wybrany szablon. Na polach starego wariantu znikają
 * jego obiekty (to, co stało tam na mapie bazowej przed wczytaniem szablonu, zostaje), a turfy wracają do stanu z mapy.
 * Pola wspólne (template_noop we wszystkich wariantach) zostają nietknięte.
 * Trwała struktura statku robi nowe zdjęcie pól silnika i nakłada na nie zapis, jeśli pochodzi z tego samego wariantu.
 */

/datum/map_template/random_room
	/// ENGINE_CHOICE_* dla szablonów silników, które inżynier może wybrać, null dla zwykłych pokoi
	var/engine_type

/datum/map_template/random_room/sk_rdm_eng_atl_01
	engine_type = ENGINE_CHOICE_STORMDRIVE

/datum/map_template/random_room/sk_rdm_eng_atl_02
	engine_type = ENGINE_CHOICE_SUPERMATTER

/datum/map_template/random_room/sk_rdm_eng_atl_03
	engine_type = ENGINE_CHOICE_TESLA

/// Sloty silników wczytane przy starcie mapy (zob. engine_choice_snapshot())
GLOBAL_LIST_EMPTY(engine_choice_slots)

/datum/map_template/random_room/stationinitload(turf/T, centered = FALSE)
	var/list/slot = (engine_type && T && !centered) ? engine_choice_snapshot(src, T) : null
	. = ..()
	if(slot)
		GLOB.engine_choice_slots += list(slot)

/// Slot silnika z tym, co leży na jego polach przed wczytaniem szablonu
/proc/engine_choice_snapshot(datum/map_template/random_room/template, turf/origin)
	var/list/keep = list()
	var/list/base_turfs = list()
	for(var/turf/T as anything in template.get_affected_turfs(origin))
		base_turfs[T] = list(T.type, islist(T.baseturfs) ? T.baseturfs.Copy() : T.baseturfs)
		for(var/obj/O in T)
			keep += WEAKREF(O)
	return list(origin, template, keep, base_turfs)

/// Pola, które ten szablon stawia sam (bez template_noop), dla szablonu postawionego w origin
/datum/map_template/random_room/proc/engine_owned_turfs(turf/origin)
	. = list()
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	for(var/datum/grid_set/gset as anything in parsed.gridSets)
		var/y = gset.ycrd
		for(var/line in gset.gridLines)
			var/x = gset.xcrd
			for(var/pos = 1 to length(line) - parsed.key_len + 1 step parsed.key_len)
				var/model = parsed.grid_models[copytext(line, pos, pos + parsed.key_len)]
				// Pole wspólne ma tylko turf i obszar template_noop: nic nie stawia, więc zostaje z mapy
				if(findtext(replacetext(replacetext(model, "/turf/template_noop", ""), "/area/template_noop", ""), "/"))
					var/turf/T = locate(origin.x + x - 1, origin.y + y - 1, origin.z)
					if(T)
						. += T
				x++
			y--

/**
 * Wybór silnika z głosów. votes: lista list(rola, ENGINE_CHOICE_*), available: typy dostępne w slocie.
 * Główny Inżynier rozstrzyga sam, bez niego większość, remis losuje. Zwraca null, gdy nikt nic nie wybrał.
 */
/proc/engine_choice_pick(list/votes, list/available)
	var/list/counts = list()
	for(var/list/vote as anything in votes)
		var/choice = vote[2]
		if(!(choice in available))
			continue
		if(vote[1] == JOB_NAME_CHIEFENGINEER)
			return choice
		counts[choice]++
	if(!length(counts))
		return null
	var/best = 0
	for(var/choice in counts)
		best = max(best, counts[choice])
	var/list/winners = list()
	for(var/choice in counts)
		if(counts[choice] == best)
			winners += choice
	return pick(winners)

/// Głosy inżynierów, którzy właśnie dostali profesję (lobby, przed stworzeniem postaci)
/proc/engine_choice_votes()
	. = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		var/role = player.mind?.assigned_role
		if(role != JOB_NAME_CHIEFENGINEER && role != JOB_NAME_STATIONENGINEER)
			continue
		var/choice = player.client?.prefs?.preferred_engine
		if(choice && choice != ENGINE_CHOICE_RANDOM)
			. += list(list(role, choice))

/// Warianty silnika możliwe w slocie: ENGINE_CHOICE_* => szablon o tym samym rozmiarze co wczytany
/proc/engine_choice_variants(datum/map_template/random_room/current)
	. = list()
	for(var/id in SSmapping.random_room_templates)
		var/datum/map_template/random_room/candidate = SSmapping.random_room_templates[id]
		if(candidate.engine_type && !.[candidate.engine_type] && candidate.template_width == current.template_width && candidate.template_height == current.template_height)
			.[candidate.engine_type] = candidate

/**
 * Stawia w slocie inny wariant silnika. Na polach starego wariantu znikają jego obiekty i moby bez gracza,
 * a turfy wracają do stanu z mapy bazowej. Pola, które stawia tylko nowy wariant, nie są czyszczone:
 * nowy szablon kładzie się na mapę tak jak przy starcie.
 */
/proc/engine_choice_swap(list/slot, datum/map_template/random_room/new_template)
	var/turf/origin = slot[ENGINE_SLOT_ORIGIN]
	var/datum/map_template/random_room/old_template = slot[ENGINE_SLOT_TEMPLATE]
	var/list/base_turfs = slot[ENGINE_SLOT_BASE_TURFS]
	var/list/keep = list()
	for(var/datum/weakref/ref as anything in slot[ENGINE_SLOT_KEEP])
		var/obj/O = ref.resolve()
		if(O)
			keep[O] = TRUE
	var/list/owned = old_template.engine_owned_turfs(origin)
	var/list/to_delete = list()
	for(var/turf/T as anything in owned)
		for(var/atom/movable/AM as anything in T)
			if(isobj(AM))
				if(!keep[AM] && !istype(AM, /obj/effect/abstract))
					to_delete += AM
			else if(isliving(AM))
				var/mob/living/critter = AM
				if(!critter.mind && !critter.client)
					to_delete += critter
	for(var/atom/movable/AM as anything in to_delete)
		if(!QDELETED(AM))
			qdel(AM)
	for(var/turf/T as anything in owned)
		var/list/base = base_turfs[T]
		if(base)
			T.ChangeTurf(base[1], base[2])
	if(!new_template.load(origin, centered = FALSE))
		return FALSE
	slot[ENGINE_SLOT_TEMPLATE] = new_template
	var/datum/ship_structure/structure = SSship_structure.structure
	if(structure)
		var/list/changed = owned | new_template.engine_owned_turfs(origin)
		structure.recapture(changed)
		structure.reapply_turfs(changed)
	return TRUE

/// Po rozdaniu profesji: wybór inżynierów zastępuje wylosowany silnik
/proc/engine_choice_apply()
	if(!length(GLOB.engine_choice_slots))
		return
	var/list/votes = engine_choice_votes()
	for(var/list/slot as anything in GLOB.engine_choice_slots)
		var/datum/map_template/random_room/current = slot[ENGINE_SLOT_TEMPLATE]
		var/list/variants = engine_choice_variants(current)
		var/choice = engine_choice_pick(votes, variants)
		if(!choice)
			continue
		if(choice == current.engine_type)
			engine_choice_announce(choice)
			continue
		var/datum/map_template/random_room/wanted = variants[choice]
		if(!wanted)
			continue
		var/old_name = current.name
		if(engine_choice_swap(slot, wanted))
			log_game("Engine choice: replaced [old_name] with [wanted.name] by the engineers' preference.")
			engine_choice_announce(choice)
		else
			log_game("Engine choice: failed to load [wanted.name] in place of [old_name].")

/// Inżynierowie w lobby dowiadują się, jaki silnik wybrano
/proc/engine_choice_announce(choice)
	var/datum/preference/choiced/preferred_engine/preference = GLOB.preference_entries[/datum/preference/choiced/preferred_engine]
	var/engine_name = preference.get_display_names()[choice]
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		var/role = player.mind?.assigned_role
		if(role == JOB_NAME_CHIEFENGINEER || role == JOB_NAME_STATIONENGINEER)
			to_chat(player, "<span class='notice'>Zgodnie z wyborem inżynierów silnik statku to dziś: [engine_name].</span>")

/datum/controller/subsystem/job/DivideOccupations(list/required_jobs)
	. = ..()
	if(.)
		engine_choice_apply()

// Preferencja gracza

/datum/preferences
	/// ENGINE_CHOICE_*, zapisywany pod PREFERENCE_TAG_PREFERRED_ENGINE
	var/preferred_engine = ENGINE_CHOICE_RANDOM
	/// Wartość, która jest w bazie (domyślna, gdy wiersza nie ma): zapis tylko po zmianie
	var/preferred_engine_saved = ENGINE_CHOICE_RANDOM

/proc/engine_choice_values()
	return list(ENGINE_CHOICE_RANDOM, ENGINE_CHOICE_TESLA, ENGINE_CHOICE_STORMDRIVE, ENGINE_CHOICE_SUPERMATTER)

/datum/preference/choiced/preferred_engine
	db_key = "preferred_engine"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "preferred_engine"

/datum/preference/choiced/preferred_engine/init_possible_values()
	return engine_choice_values()

/datum/preference/choiced/preferred_engine/get_display_names()
	return list(
		ENGINE_CHOICE_RANDOM = "Losowy",
		ENGINE_CHOICE_TESLA = "Silnik Tesli",
		ENGINE_CHOICE_STORMDRIVE = "Napęd Stormdrive",
		ENGINE_CHOICE_SUPERMATTER = "Silnik supermaterii",
	)

// Zapis w tabeli preferencji osobnym zapytaniem, bez zmian w preferences2.dm (jak język gry)
/datum/preferences/load_from_database()
	. = ..()
	load_preferred_engine()

/datum/preferences/proc/load_preferred_engine()
	if(!SSdbcore.IsConnected() || !parent?.ckey)
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"SELECT preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey AND preference_tag=:ptag",
		list("ckey" = parent.ckey, "ptag" = PREFERENCE_TAG_PREFERRED_ENGINE)
	)
	if(query.Execute() && query.NextRow())
		preferred_engine = query.item[1]
	qdel(query)
	preferred_engine = sanitize_inlist(preferred_engine, engine_choice_values(), initial(preferred_engine))
	preferred_engine_saved = preferred_engine

/datum/preferences/save_preferences()
	. = ..()
	if(preferred_engine == preferred_engine_saved || !SSdbcore.IsConnected() || !parent?.ckey || IS_GUEST_KEY(parent.ckey))
		return
	var/datum/DBQuery/query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("preferences")] (ckey, preference_tag, preference_value) VALUES (:ckey, :ptag, :pvalue) ON DUPLICATE KEY UPDATE preference_value=:pvalue2",
		list("ckey" = parent.ckey, "ptag" = PREFERENCE_TAG_PREFERRED_ENGINE, "pvalue" = preferred_engine, "pvalue2" = preferred_engine)
	)
	if(query.Execute())
		preferred_engine_saved = preferred_engine
	qdel(query)
