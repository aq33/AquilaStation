/*
	AQUILA - ksenoflora z zamkniętego PR tgstation/tgstation#82089 (Xenoflora, autorzy: Smartkar i SELFHELL), przeniesiona na naszą botanikę.
	Sprite'y plonów i torebek z tego PR-a (aquila/icons/obj/hydroponics/ported_ksenoflora_*.dmi), licencja CC-BY-SA 3.0.

	Ksenoflora rośnie tylko w kapsule ksenoflory (ksenoflora_pod.dm):
	- korzenie ksenoflory wchodzą tylko w podłoże kapsuły, więc w zwykłej tacce nasiona nie wschodzą,
	- potrzeba korzeni (/datum/plant_need/xenoflora_pod) przepuszcza wodę do rośliny tylko wtedy, gdy kapsuła działa i spełnia wymagania rośliny,
	- potrzeba owocu (/datum/plant_need/xenoflora/<roślina>) zużywa z kapsuły gaz i odczynnik i pilnuje temperatury.
	W oryginale rośliny były osobnym systemem (/datum/xenoflora_plant), tu są cechami owocu.
*/

/// Podłoże kapsuły ksenoflory, poza nią go nie ma
#define PLANT_SUBSTRATE_XENOFLORA (1<<4)

/*
	Podłoże kapsuły: przyjmuje każdą roślinę, a do tego korzenie ksenoflory
*/
/datum/plant_subtrate/xenoflora
	name = "podłoże kapsuły ksenoflory"
	tooltip = "Pasuje do każdej rośliny, a korzenie ksenoflory rosną tylko w nim."
	icon_state = "fairy"
	substrate_flags = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND | PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS | PLANT_SUBSTRATE_XENOFLORA

/*
	Korzenie ksenoflory
*/
/datum/plant_feature/roots/xenoflora
	species_name = "radices alienae"
	name = "korzenie ksenoflory"
	compatible_substrate = PLANT_SUBSTRATE_XENOFLORA
	plant_needs = list(/datum/plant_need/xenoflora_pod)

/datum/plant_feature/roots/xenoflora/New(datum/component/plant/_parent)
	. = ..()
	substrate_dialogue = "kapsuła ksenoflory"

/datum/plant_feature/roots/xenoflora/get_substrate_text()
	return "kapsuła ksenoflory"

/*
	Potrzeba korzeni: roślina pije tylko w działającej kapsule, która spełnia jej wymagania
*/
/datum/plant_need/xenoflora_pod
	need_description = "<b>Wymaga:</b> kapsuły ksenoflory, która jest włączona, ma zasilanie i spełnia wymagania rośliny."

/datum/plant_need/xenoflora_pod/get_short_description()
	return "działająca kapsuła ksenoflory"

/datum/plant_need/xenoflora_pod/check_need(_delta_time)
	. = ..()
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = parent?.parent?.plant_item?.loc
	if(!istype(pod) || !pod.is_working())
		return FALSE
	for(var/datum/plant_feature/feature as anything in parent.parent.plant_features)
		for(var/datum/plant_need/xenoflora/need in feature.plant_needs)
			if(length(need.get_unmet(pod, 1)))
				return FALSE
	return TRUE

/*
	Potrzeba owocu: gaz, odczynnik i temperatura w kapsule. Ilości na sekundę.
*/
/datum/plant_need/xenoflora
	need_description = "kapsuły ksenoflory"
	/// Wymagane gazy: id gazu = mol/s
	var/list/required_gases = list()
	/// Wymagane odczynniki w zbiorniku kapsuły: typ = j./s
	var/list/required_reagents = list()
	/// Bezpieczny zakres temperatury w kapsule (K)
	var/min_temperature = 0
	var/max_temperature = INFINITY

/datum/plant_need/xenoflora/New(datum/plant_feature/_parent, _overdrawn)
	. = ..()
	need_description = "<b>Wymaga:</b> [need_description]\n<span>  &#8627; [jointext(get_requirement_texts(), ", ")]</span>"

/// Opisy wszystkich wymagań, np. „Azot 0.1 mol/s”
/datum/plant_need/xenoflora/proc/get_requirement_texts()
	. = list()
	for(var/gas_id in required_gases)
		. += "[GLOB.gas_data.names[gas_id]] [required_gases[gas_id]] mol/s"
	for(var/datum/reagent/reagent as anything in required_reagents)
		. += "[initial(reagent.name)] [required_reagents[reagent]] j./s"
	. += get_temperature_text()

/datum/plant_need/xenoflora/proc/get_temperature_text()
	return "temperatura od [round(min_temperature - T0C)] do [round(max_temperature - T0C)] °C"

/// Lista niespełnionych wymagań w podanej kapsule (pusta = wszystko gra); delta_time mówi, na ile sekund ma starczyć zapasu
/datum/plant_need/xenoflora/proc/get_unmet(obj/machinery/atmospherics/components/binary/xenoflora_pod/pod, delta_time = 1)
	. = list()
	if(!istype(pod) || !pod.is_working())
		. += "działająca kapsuła ksenoflory"
		return
	var/datum/gas_mixture/air = pod.get_plant_air()
	for(var/gas_id in required_gases)
		if(!air || air.get_moles(gas_id) < required_gases[gas_id] * delta_time)
			. += "[GLOB.gas_data.names[gas_id]] w kapsule"
	for(var/reagent in required_reagents)
		if(!pod.reagents.has_reagent(reagent, required_reagents[reagent] * delta_time))
			var/datum/reagent/reagent_type = reagent
			. += "[initial(reagent_type.name)] w zbiorniku kapsuły"
	var/temperature = pod.get_chamber_temperature()
	if(temperature < min_temperature || temperature > max_temperature)
		. += get_temperature_text()

/datum/plant_need/xenoflora/get_short_description()
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = parent?.parent?.plant_item?.loc
	var/list/unmet = get_unmet(pod, 1)
	return length(unmet) ? jointext(unmet, ", ") : jointext(get_requirement_texts(), ", ")

/datum/plant_need/xenoflora/check_need(_delta_time)
	. = ..()
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = parent?.parent?.plant_item?.loc
	if(length(get_unmet(pod, _delta_time)))
		return FALSE
	//Roślina zjada swoje: gaz z kapsuły (albo z pomieszczenia przy otwartej kopule) i odczynniki ze zbiornika
	var/datum/gas_mixture/air = pod.get_plant_air()
	for(var/gas_id in required_gases)
		air.adjust_moles(gas_id, -required_gases[gas_id] * _delta_time)
	if(!pod.dome_extended)
		var/turf/pod_turf = get_turf(pod)
		pod_turf?.air_update_turf()
	for(var/reagent in required_reagents)
		pod.reagents.remove_reagent(reagent, required_reagents[reagent] * _delta_time)
	return TRUE

/datum/plant_need/xenoflora/broombush
	required_gases = list(GAS_N2 = 0.1)
	min_temperature = T0C
	max_temperature = T0C + 60

/datum/plant_need/xenoflora/cubomelon
	required_reagents = list(/datum/reagent/bromine = 0.1)
	min_temperature = 213.15
	max_temperature = T0C

/datum/plant_need/xenoflora/hyperlattice
	required_gases = list(GAS_PLASMA = 0.2)
	min_temperature = T0C
	max_temperature = T0C + 60

/datum/plant_need/xenoflora/bluespace_limon
	required_gases = list(GAS_CO2 = 0.1)
	required_reagents = list(/datum/reagent/acetone = 0.1, /datum/reagent/oxygen = 0.05)
	min_temperature = T0C
	max_temperature = T0C + 40

/datum/plant_need/xenoflora/pyrite_peach
	required_gases = list(GAS_O2 = 0.3)
	required_reagents = list(/datum/reagent/napalm = 0.05)
	min_temperature = T0C + 70
	max_temperature = T0C + 150

/*
	Owoce ksenoflory
*/
/datum/plant_feature/fruit/xenoflora
	abstract_type = /datum/plant_feature/fruit/xenoflora
	family = "Xenoflora"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_seeds.dmi'
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests)

/datum/plant_feature/fruit/xenoflora/broombush
	species_name = "scopa aliena"
	name = "miotlarz"
	icon_state = "cabbage"
	icon_uneven = TRUE
	colour_override = "#8ee05a"
	seed_icon_state = "xenoseeds-broombush"
	fruit_product = /obj/item/food/grown/xenoflora/broombush
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/broombush)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/cellulose = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/datum/plant_feature/fruit/xenoflora/cubomelon
	species_name = "pepo cubicus"
	name = "sześciomelon"
	icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_fruit.dmi'
	icon_state = "cubomelon"
	seed_icon_state = "xenoseeds-cubomelon"
	fruit_product = /obj/item/food/grown/xenoflora/cubomelon
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/cubomelon)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/frostoil = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_LARGE
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fruit_size = PLANT_FRUIT_SIZE_LARGE

/datum/plant_feature/fruit/xenoflora/hyperlattice
	species_name = "crystallum temporis"
	name = "hiperkrata czasowa"
	icon_state = "orb"
	colour_override = "#f2c6ff"
	seed_icon_state = "xenoseeds-hyperlattice"
	fruit_product = /obj/item/food/grown/xenoflora/hyperlattice
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/hyperlattice)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_SMALL

/datum/plant_feature/fruit/xenoflora/bluespace_limon
	species_name = "citrus caeruleus"
	name = "bluespace'owa limona"
	icon_state = "citrus"
	icon_uneven = TRUE
	colour_override = "#d8ecff"
	seed_icon_state = "xenoseeds-limon"
	fruit_product = /obj/item/food/grown/xenoflora/bluespace_limon
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/bluespace_limon)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/liquid_contents)
	fast_reagents = list(/datum/reagent/consumable/limonjuice = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/datum/plant_feature/fruit/xenoflora/pyrite_peach
	species_name = "persica pyritis"
	name = "pirytowa brzoskwinia"
	icon_state = "orange"
	colour_override = "#ffe27a"
	seed_icon_state = "xenoseeds-peach"
	fruit_product = /obj/item/food/grown/xenoflora/pyrite_peach
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/pyrite_peach)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/peachjuice = PLANT_REAGENT_SMALL, /datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL, /datum/reagent/clf3 = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/*
	Nasiona (bez automatu: w oryginale tylko w paczce z zaopatrzenia). Rodzic /obj/item/plant_seeds/preset/alien jest w obce.dm
*/
/obj/item/plant_seeds/preset/alien/xenoflora
	name = "nasiona ksenoflory"
	icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_seeds.dmi'
	abstract_type = /obj/item/plant_seeds/preset/alien/xenoflora

/obj/item/plant_seeds/preset/alien/xenoflora/broombush
	name = "nasiona: miotlarz (kapsuła ksenoflory)"
	name_override = "miotlarz"
	icon_state = "xenoseeds-broombush"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/broombush)

/obj/item/plant_seeds/preset/alien/xenoflora/cubomelon
	name = "nasiona: sześciomelon (kapsuła ksenoflory)"
	name_override = "sześciomelon"
	icon_state = "xenoseeds-cubomelon"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/cubomelon)

/obj/item/plant_seeds/preset/alien/xenoflora/hyperlattice
	name = "nasiona: hiperkrata czasowa (kapsuła ksenoflory)"
	name_override = "hiperkrata czasowa"
	icon_state = "xenoseeds-hyperlattice"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber/cactus, /datum/plant_feature/fruit/xenoflora/hyperlattice)

/obj/item/plant_seeds/preset/alien/xenoflora/bluespace_limon
	name = "nasiona: bluespace'owa limona (kapsuła ksenoflory)"
	name_override = "bluespace'owa limona"
	icon_state = "xenoseeds-limon"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/mini/lime, /datum/plant_feature/fruit/xenoflora/bluespace_limon)

/obj/item/plant_seeds/preset/alien/xenoflora/pyrite_peach
	name = "nasiona: pirytowa brzoskwinia (kapsuła ksenoflory)"
	name_override = "pirytowa brzoskwinia"
	icon_state = "xenoseeds-peach"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/xenoflora/pyrite_peach)

/*
	Plony
*/
/obj/item/food/grown/xenoflora
	abstract_type = /obj/item/food/grown/xenoflora
	icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_harvest.dmi'

/obj/item/food/grown/xenoflora/broombush
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/broombush
	name = "liść miotlarza"
	desc = "Jaskrawozielony, żebrowany liść miotlarza. Jest skrajnie gorzki, więc karmi się nim głównie szlamy."
	icon_state = "broombush"
	tastes = list("skrajna gorycz" = 3, "zgniłe skarpety" = 1)
	foodtypes = GROSS | VEGETABLES
	grind_results = list(/datum/reagent/cellulose = 0)

/obj/item/food/grown/xenoflora/cubomelon
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/cubomelon
	name = "sześciomelon"
	desc = "Wielki niebieski sześciomelon z zielonkawym odcieniem, znak, że wyhodowano go sztucznie. Ma w sobie dużo olejku mrożącego, więc nie jest dla ludzi."
	icon_state = "cubomelon"
	w_class = WEIGHT_CLASS_NORMAL
	bite_consumption_mod = 2
	tastes = list("sześciomelon" = 3, "chłód" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/frostoil

/obj/item/food/grown/xenoflora/cubomelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cubomelon_slice, 5, 20)

/obj/item/food/grown/xenoflora/cubomelon/make_dryable()
	return //No drying

/obj/item/food/cubomelon_slice
	name = "plaster sześciomelona"
	desc = "Plaster niebieskiego, soczystego sześciomelona. Jest zimny w dotyku."
	icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_harvest.dmi'
	icon_state = "cubomelonslice"
	food_reagents = list(/datum/reagent/consumable/frostoil = 1, /datum/reagent/consumable/nutriment/vitamin = 0.2, /datum/reagent/consumable/nutriment = 1)
	tastes = list("sześciomelon" = 1, "chłód" = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	juice_typepath = /datum/reagent/consumable/frostoil
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/grown/xenoflora/hyperlattice
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/hyperlattice
	name = "kryształ hiperkraty"
	desc = "Krystaliczna krata uformowana z... czasu. Każdy, kto przeszedł szkolenie z materiałów niebezpiecznych, wie, co się dzieje przy próbie teleportacji czegoś takiego."
	icon_state = "hyperlattice"
	tastes = list("kruszony kryształ" = 3, "superpozycja przeszłości i przyszłości" = 1)
	foodtypes = GROSS | VEGETABLES
	grind_results = list(/datum/reagent/drug/space_drugs = 0)

/obj/item/food/grown/xenoflora/bluespace_limon
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/bluespace_limon
	name = "bluespace'owa limona"
	desc = "Tak to się kończy, kiedy po przedawkowaniu cytrynowo-limonkowego wpadnie się do pyłu bluespace."
	icon_state = "bluespace_limon"
	tastes = list("cytryna? limonka?" = 1, "teleportacja" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/limonjuice

/obj/item/food/grown/xenoflora/pyrite_peach
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/pyrite_peach
	name = "pirytowa brzoskwinia"
	desc = "Pirytowe brzoskwinie słyną z wybuchowego smaku, dlatego z niewiadomych powodów kochają je dyskoteki. Bez rękawic lepiej ich nie dotykać."
	icon_state = "pyrite_peaches"
	tastes = list("płomienie" = 1, "brzoskwinie" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/peachjuice

/obj/item/food/grown/xenoflora/pyrite_peach/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user) || carbon_user.gloves || !reagents?.total_volume)
		return
	to_chat(carbon_user, span_warning("[capitalize(name)] parzy cię w dłonie!"))
	reagents.reaction(carbon_user, TOUCH, 0.2)

/*
	Odczynniki
*/
/datum/reagent/cellulose
	name = "Włókna celulozowe"
	description = "Krystaliczny polimer polidekstrozy. Rośliny przysięgają na to świństwo."
	reagent_state = SOLID
	color = "#E6E6DA"
	taste_description = "drewno"
	taste_mult = 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/limonjuice
	name = "Sok z limony"
	description = "Ten sok jest BARDZO kwaśny."
	color = "#EBEBEB"
	taste_description = "kwaśność i teleportacja"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	glass_icon_state = "glass_white"
	glass_name = "szklanka soku z limony"
	glass_desc = "Szklanka bardzo kwaśnego soku z limony. Uważaj, gdzie się oblewasz."

/// Oblanie sokiem z limony przerzuca kawałek w stronę, w którą patrzy cel, chętnie w kosmos
/datum/reagent/consumable/limonjuice/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	if(!(method & (TOUCH|VAPOR)) || !isturf(M.loc))
		return
	var/distance = min(round(reac_volume / 5, 1) + 1, 5)
	var/x_offset = 0
	var/y_offset = 0
	switch(M.dir)
		if(NORTH)
			y_offset = distance
		if(SOUTH)
			y_offset = -distance
		if(EAST)
			x_offset = -distance
		if(WEST)
			x_offset = distance
	var/turf/tele_center = locate(clamp(M.x + x_offset, 1, world.maxx), clamp(M.y + y_offset, 1, world.maxy), M.z)
	if(!tele_center)
		return
	for(var/turf/open/space/space_turf in circlerangeturfs(tele_center, distance - 1))
		do_teleport(M, space_turf, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
		return
	do_teleport(M, tele_center, distance, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/consumable/limonjuice/on_mob_life(mob/living/carbon/M)
	if(current_cycle > 10 && prob(7.5))
		to_chat(M, span_warning("Czujesz się niestabilnie..."))
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 3 SECONDS)
	return ..()
