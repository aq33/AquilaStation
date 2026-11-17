/*
	AQUILA - mutacje od odczynnika (wzór: Goon, Monke)
	Konkretny odczynnik w tacy zmienia część rośliny w konkretną odmianę, obok losowego pieca radiacyjnego.
	Owoc sprawdza listę przy każdym cyklu wzrostu: gdy w tacy jest dość wszystkich odczynników z wpisu,
	ma REAGENT_MUTATION_CHANCE % na sekundę, że zużyje je i zmieni się w nową część.
*/

/// Szansa na mutację w procentach na sekundę, gdy w tacy jest dość odczynników
#define REAGENT_MUTATION_CHANCE 2

/datum/plant_feature
	/// AQUILA - mutacje od odczynnika: list(typ nowej części = list(odczynnik = ilość)). Wszystkie odczynniki z wpisu muszą być w tacy naraz
	var/list/reagent_mutations

/*
	Dopiski mutacji do istniejących części bez nadpisywania ich list.
	Każda partia portu roślin ma własny podtyp /datum/plant_mutation_set, więc kilka plików może dopisać
	mutacje do tej samej rośliny (np. pomidora) i żaden nie zgubi cudzych. Scalane dla dokładnego typu części.
*/
/datum/plant_mutation_set
	/// list(typ części = list(typ mutacji = koszt w piecu)), dopisywane do mutations
	var/list/mutations = list()
	/// list(typ części = list(typ mutacji = list(odczynnik = ilość))), dopisywane do reagent_mutations
	var/list/reagent_mutations = list()

GLOBAL_LIST_INIT(plant_extra_mutations, build_plant_mutation_sets(FALSE))
GLOBAL_LIST_INIT(plant_extra_reagent_mutations, build_plant_mutation_sets(TRUE))

/proc/build_plant_mutation_sets(reagent)
	var/list/merged = list()
	for(var/set_type in subtypesof(/datum/plant_mutation_set))
		var/datum/plant_mutation_set/mutation_set = new set_type
		var/list/entries = reagent ? mutation_set.reagent_mutations : mutation_set.mutations
		for(var/part_type in entries)
			var/list/part_entries = merged[part_type] || list()
			for(var/new_type in entries[part_type])
				part_entries[new_type] = entries[part_type][new_type]
			merged[part_type] = part_entries
	return merged

/datum/plant_feature/New(datum/component/plant/_parent)
	. = ..()
	var/list/extra = GLOB.plant_extra_mutations[type]
	if(length(extra))
		mutations = mutations ? mutations.Copy() : list()
		for(var/new_type in extra)
			mutations[new_type] = extra[new_type]
	var/list/extra_reagent = GLOB.plant_extra_reagent_mutations[type]
	if(length(extra_reagent))
		reagent_mutations = reagent_mutations ? reagent_mutations.Copy() : list()
		for(var/new_type in extra_reagent)
			reagent_mutations[new_type] = extra_reagent[new_type]

/datum/plant_feature/fruit/process(delta_time)
	. = ..()
	if(!QDELETED(src) && length(reagent_mutations))
		try_reagent_mutation(delta_time)

/// Sprawdza odczynniki w tacy i ewentualnie mutuje. force pomija losowanie (testy). Zwraca nową część albo null
/datum/plant_feature/proc/try_reagent_mutation(delta_time, force = FALSE)
	if(!parent?.plant_item || !length(reagent_mutations))
		return null
	var/atom/tray = parent.plant_item.loc
	if(!istype(tray) || SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT))
		return null
	//Uschnięta roślina już nie urośnie, więc nie zużywa odczynnika na mutację
	for(var/datum/plant_feature/body/body_feature in parent.plant_features)
		if(body_feature.health <= 0)
			return null
	var/list/reagent_holders = list()
	SEND_SIGNAL(parent, COMSIG_PLANT_REQUEST_REAGENTS, reagent_holders, src)
	if(!length(reagent_holders))
		return null
	for(var/new_type in reagent_mutations)
		//Odmiany dziedziczą listę po rodzicu; mutacja w siebie samą tylko zużyłaby odczynnik i zresetowała wzrost
		if(istype(src, new_type))
			continue
		var/list/needed = reagent_mutations[new_type]
		var/datum/reagents/source = find_mutation_reagents(reagent_holders, needed)
		if(!source)
			continue
		if(!force && !prob(REAGENT_MUTATION_CHANCE * delta_time))
			return null
		var/datum/component/plant/plant = parent
		var/datum/plant_feature/new_feature = plant.mutate_feature(src, new_type)
		if(!new_feature)
			continue
		for(var/datum/reagent/reagent as anything in needed)
			source.remove_reagent(reagent, needed[reagent])
		tray.visible_message(span_notice("[plant.plant_item] wypuszcza nowe pędy i zmienia wygląd!"))
		playsound(tray, 'sound/effects/bubbles.ogg', 40, TRUE)
		return new_feature
	return null

/// Zwraca pojemnik, w którym są naraz wszystkie potrzebne odczynniki, albo null
/datum/plant_feature/proc/find_mutation_reagents(list/reagent_holders, list/needed)
	for(var/datum/reagents/holder as anything in reagent_holders)
		if(!holder)
			continue
		var/has_all = TRUE
		for(var/datum/reagent/reagent as anything in needed)
			if(!holder.has_reagent(reagent, needed[reagent]))
				has_all = FALSE
				break
		if(has_all)
			return holder
	return null

/// AQUILA - podmienia część rośliny na nową tak jak piec radiacyjny. Zwraca nową część albo null, gdy nie pasuje do pozostałych części
/datum/component/plant/proc/mutate_feature(datum/plant_feature/feature, new_type)
	var/datum/plant_feature/new_feature = new new_type(src)
	for(var/datum/plant_feature/current_feature as anything in plant_features - feature)
		if(is_type_in_typecache(new_feature, current_feature.blacklist_features) || is_type_in_typecache(current_feature, new_feature.blacklist_features))
			qdel(new_feature)
			return null
		if(length(current_feature.whitelist_features) && !is_type_in_typecache(new_feature, current_feature.whitelist_features) || length(new_feature.whitelist_features) && !is_type_in_typecache(current_feature, new_feature.whitelist_features))
			qdel(new_feature)
			return null
	//Owoce, które już wiszą, spadają, tak jak w piecu
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_features
	fruit_feature?.force_drop_fruit()
	plant_features -= feature
	plant_features += new_feature
	compile_species_id()
	plant_item.name = get_species_name(plant_features)
	name_override = null
	for(var/datum/plant_feature/body/body_feature in plant_features)
		body_feature.growth_time_elapsed = 0
		body_feature.current_stage = 1
		body_feature.growth_step(1)
	qdel(feature)
	return new_feature

#undef REAGENT_MUTATION_CHANCE

// Mutacje od odczynnika dla roślin, które już mamy. Przez rejestr, a nie zmienną typu: zmienną dziedziczyłyby odmiany
// (jagoda śmierci, pomidor zabójca, melon miodowy) i od zwykłego odczynnika leczącego cofałyby się do odmiany odczynnikowej
/datum/plant_mutation_set/podstawowe
	reagent_mutations = list(
		/datum/plant_feature/fruit/tomato = list(/datum/plant_feature/fruit/tomato/blood = list(/datum/reagent/blood = 10)),
		/datum/plant_feature/fruit/watermelon = list(/datum/plant_feature/fruit/watermelon/holy = list(/datum/reagent/water/holywater = 10)),
		/datum/plant_feature/fruit/apple = list(/datum/plant_feature/fruit/apple/gold = list(/datum/reagent/gold = 5)),
		/datum/plant_feature/fruit/berry = list(/datum/plant_feature/fruit/berry/poison = list(/datum/reagent/toxin = 10)),
	)

/datum/dictionary_entry/reagent_mutations
	title = "Chemiczna perswazja"
	body = "(Niektóre rośliny mutują od konkretnego odczynnika w tacy, bez pieca radiacyjnego. Wlej odczynnik do tacy i poczekaj: gdy roślina zareaguje, zużyje go i zmieni odmianę.)\n\
	\n\
	Tu pojawi się historia.\n\
	\n\
	(Sprawdzone połączenia: pomidor i krew, arbuz i woda święcona, jabłko i złoto, jagody i toksyna. Reszty trzeba szukać samemu.)"
