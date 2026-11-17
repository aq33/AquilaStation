// AQUILA - łowiska: port lazy_fishing_spot, fishing_spot i /datum/fish_source z Shiptesta (code/datums/elements/
// lazy_fishing_spot.dm, components/fishing_spot.dm, modules/fishing/sources/*.dm, AGPLv3, starsza wersja wędkarstwa
// z tg). Pole wody ma tylko lekki element; komponent łowiska powstaje dopiero przy pierwszym zarzuceniu wędki.
// Tabela łowiska: typ zachowania ryby akwariowej (/datum/aquarium_behaviour/fish) albo przedmiotu -> waga,
// FISHING_DUD = pusty zarzut.
// Różnice względem Shiptesta: bez cech ryb, ulubionych przynęt i limitów sztuk; przynęta ogranicza puste zarzuty
// (robak bardziej niż zwykłe jedzenie), a bez przynęty pustych zarzutów jest trzy razy więcej (w Shiptest dziesięć);
// łowiska planet Aquili (plaża, sztormowe morze, dżungla, oaza, lawa) zamiast łowisk Shiptesta.

GLOBAL_LIST_INIT(preset_fish_sources, init_fishing_configurations())

/proc/init_fishing_configurations()
	. = list()
	.[FISHING_SPOT_PRESET_BEACH] = new /datum/fish_source/beach
	.[FISHING_SPOT_PRESET_STORMY] = new /datum/fish_source/stormy
	.[FISHING_SPOT_PRESET_JUNGLE] = new /datum/fish_source/jungle
	.[FISHING_SPOT_PRESET_OASIS] = new /datum/fish_source/oasis
	.[FISHING_SPOT_PRESET_LAVA] = new /datum/fish_source/lava

/// Pole, na którym da się łowić: komponent łowiska powstaje przy pierwszym zarzuceniu
/datum/element/lazy_fishing_spot
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/configuration

/datum/element/lazy_fishing_spot/Attach(datum/target, configuration)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!configuration)
		CRASH("Lazy fishing spot had no configuration passed in.")
	src.configuration = configuration
	RegisterSignal(target, COMSIG_PRE_FISHING, PROC_REF(create_fishing_spot))

/datum/element/lazy_fishing_spot/Detach(datum/target)
	UnregisterSignal(target, COMSIG_PRE_FISHING)
	return ..()

/datum/element/lazy_fishing_spot/proc/create_fishing_spot(datum/source)
	SIGNAL_HANDLER
	source.AddComponent(/datum/component/fishing_spot, configuration)
	Detach(source)

/// Łowisko: zarzucenie wędki zaczyna łowienie z tabeli źródła
/datum/component/fishing_spot
	var/datum/fish_source/fish_source

/datum/component/fishing_spot/Initialize(configuration)
	if(ispath(configuration, /datum/fish_source))
		fish_source = new configuration
	else if(istype(configuration, /datum/fish_source))
		fish_source = configuration
	else
		fish_source = GLOB.preset_fish_sources[configuration]
		if(!fish_source)
			stack_trace("Invalid fishing spot configuration \"[configuration]\" passed down to fishing spot component.")
			return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_FISHING_ROD_CAST, PROC_REF(handle_cast))

/datum/component/fishing_spot/proc/handle_cast(datum/source, obj/item/fishing_rod/rod, mob/user)
	SIGNAL_HANDLER
	try_start_fishing(rod, user)
	return FISHING_ROD_CAST_HANDLED

/datum/component/fishing_spot/proc/try_start_fishing(obj/item/fishing_rod/rod, mob/user)
	if(HAS_TRAIT(user, TRAIT_GONE_FISHING))
		user.balloon_alert(user, "już łowisz")
		return FALSE
	var/denial_reason = fish_source.can_fish(rod, user)
	if(denial_reason)
		to_chat(user, span_warning(denial_reason))
		return FALSE
	var/datum/fishing_challenge/challenge = new(parent, rod, user, fish_source)
	RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_COMPLETED, PROC_REF(fishing_completed))
	challenge.start()
	return TRUE

/datum/component/fishing_spot/proc/fishing_completed(datum/fishing_challenge/source, mob/user, success)
	SIGNAL_HANDLER
	if(success)
		INVOKE_ASYNC(fish_source, TYPE_PROC_REF(/datum/fish_source, dispense_reward), source.reward_path, user)

/// Skąd biorą się ryby: wspólne dla wszystkich pól jednego rodzaju wody
/datum/fish_source
	/// Typ ryby (zachowanie) albo przedmiotu -> waga
	var/list/fish_table = list()
	/// Komunikaty pustego zarzutu
	var/list/duds = list("nic nie bierze", "pusty haczyk")
	/// Bazowa trudność minigry
	var/fishing_difficulty = FISHING_DEFAULT_DIFFICULTY
	/// Tło minigry (stan z aquila/icons/planets/water/fishing_hud.dmi)
	var/background = "background_default"

/// Czy da się tu łowić tą wędką: powód odmowy albo null
/datum/fish_source/proc/can_fish(obj/item/fishing_rod/rod, mob/fisherman)
	return

/// Trudność minigry dla wylosowanej zdobyczy (0-100)
/datum/fish_source/proc/calculate_difficulty(result, obj/item/fishing_rod/rod, mob/fisherman)
	. = fishing_difficulty + rod.difficulty_modifier
	if(rod.bait)
		. += FISHING_BAIT_DIFFICULTY_MOD
	if(ispath(result, /datum/aquarium_behaviour/fish))
		var/datum/aquarium_behaviour/fish/fish = result
		. += initial(fish.fishing_difficulty_modifier)
	. = clamp(round(.), FISHING_MINIMUM_DIFFICULTY, 100)

/// Losuje zdobycz z tabeli zmienionej przez przynętę
/datum/fish_source/proc/roll_reward(obj/item/fishing_rod/rod, mob/fisherman)
	return pickweight(get_modified_fish_table(rod, fisherman))

/datum/fish_source/proc/get_modified_fish_table(obj/item/fishing_rod/rod, mob/fisherman)
	var/list/final_table = fish_table.Copy()
	if(final_table[FISHING_DUD])
		if(!rod.bait)
			final_table[FISHING_DUD] *= 3
		else if(istype(rod.bait, /obj/item/food/fishing_worm))
			final_table[FISHING_DUD] *= 0.3
		else
			final_table[FISHING_DUD] *= 0.5
	return final_table

/// Daje zdobycz łowiącemu (do ręki albo pod nogi)
/datum/fish_source/proc/dispense_reward(reward_path, mob/fisherman)
	if(reward_path == FISHING_DUD || !reward_path)
		fisherman.balloon_alert(fisherman, pick(duds))
		return
	var/atom/movable/reward
	if(ispath(reward_path, /datum/aquarium_behaviour/fish))
		reward = generate_fish(get_turf(fisherman), reward_path)
	else if(ispath(reward_path, /atom/movable))
		reward = new reward_path(get_turf(fisherman))
	if(!reward)
		return
	if(isitem(reward))
		fisherman.put_in_hands(reward)
	fisherman.balloon_alert(fisherman, "złowione: [reward.name]!")
	return reward

/// Ciepła płycizna przy plaży: ryby morskie
/datum/fish_source/beach
	fish_table = list(
		FISHING_DUD = 15,
		/datum/aquarium_behaviour/fish/clownfish = 15,
		/datum/aquarium_behaviour/fish/cardinal = 15,
		/datum/aquarium_behaviour/fish/greenchromis = 15,
		/datum/aquarium_behaviour/fish/needlefish = 10,
		/datum/aquarium_behaviour/fish/pufferfish = 10,
		/datum/aquarium_behaviour/fish/planet/plaice = 10,
		/datum/aquarium_behaviour/fish/planet/crab = 10,
		/datum/aquarium_behaviour/fish/firefish = 5,
		/datum/aquarium_behaviour/fish/planet/stingray = 5,
		/datum/aquarium_behaviour/fish/planet/squid = 5,
		/obj/item/clothing/shoes/sandal = 3,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/// Sztormowe morze planety wodnej: większe, trudniejsze ryby głębinowe
/datum/fish_source/stormy
	fish_table = list(
		FISHING_DUD = 20,
		/datum/aquarium_behaviour/fish/lanternfish = 15,
		/datum/aquarium_behaviour/fish/planet/monkfish = 15,
		/datum/aquarium_behaviour/fish/planet/squid = 15,
		/datum/aquarium_behaviour/fish/armorfish = 10,
		/datum/aquarium_behaviour/fish/gunner_jellyfish = 10,
		/datum/aquarium_behaviour/fish/dwarf_moonfish = 10,
		/datum/aquarium_behaviour/fish/planet/arctic_char = 10,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
	background = "background_ice"

/// Mętna woda dżungli: ryby słodkowodne
/datum/fish_source/jungle
	fish_table = list(
		FISHING_DUD = 15,
		/datum/aquarium_behaviour/fish/planet/perch = 20,
		/datum/aquarium_behaviour/fish/goldfish = 15,
		/datum/aquarium_behaviour/fish/angelfish = 15,
		/datum/aquarium_behaviour/fish/guppy = 15,
		/datum/aquarium_behaviour/fish/plasmatetra = 10,
		/datum/aquarium_behaviour/fish/catfish = 10,
		/datum/aquarium_behaviour/fish/planet/sockeye = 5,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5
	background = "background_dank"

/// Oaza na pustyni: mało ryb, łatwo
/datum/fish_source/oasis
	fish_table = list(
		FISHING_DUD = 25,
		/datum/aquarium_behaviour/fish/guppy = 20,
		/datum/aquarium_behaviour/fish/goldfish = 15,
		/datum/aquarium_behaviour/fish/planet/perch = 10,
	)

/// Lawa planet wulkanicznych: tylko wędką z żyłką odporną na żar
/datum/fish_source/lava
	fish_table = list(
		FISHING_DUD = 10,
		/datum/aquarium_behaviour/fish/planet/lavaloop = 15,
		/obj/item/stack/ore/slag = 20,
		/obj/item/stack/ore/glass/basalt = 10,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	background = "background_lavaland"

/datum/fish_source/lava/can_fish(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	if(!rod.heat_resistant)
		return "Zwykła żyłka spłonie w lawie. Potrzebna jest wędka z żyłką odporną na żar."

/// Lawa na planetach i Lavalandzie jest łowiskiem
/turf/open/lava/smooth/lava_land_surface/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, FISHING_SPOT_PRESET_LAVA)
