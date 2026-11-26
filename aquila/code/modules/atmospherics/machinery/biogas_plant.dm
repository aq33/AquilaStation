// AQUILA - Biogazownia (plan maszynowni E20) i metan z kanalizacji statku (D14).
// Urządzenie na rurze: w zbiorniku fermentują organiczne odczynniki (mocz, krew, nawozy, odżywki, resztki jedzenia),
// a z rury idzie biogaz: metan z domieszką dwutlenku węgla (ten można przepuścić przez regenerator tlenu).
// Kanalizacja: to, co spłyną sedesy i odpływy w podłodze, trafia do wspólnych ścieków statku (GLOB.ship_sewage),
// z których biogazownia dobiera wsad sama. Odpływy i sedesy nie dają metanu bez biogazowni.
// Ścieki są wspólne dla całego świata (nie liczymy osobno na każdy statek), żeby nie trzeba było mapować rur ściekowych.
// Sprite to przebarwiona komora reakcyjna z plumbingu z naszego repo.

/// Pojemność zbiornika biogazowni
#define BIOGAS_TANK_VOLUME 300
/// Ile jednostek wsadu na cykl atmosfery przerabia biogazownia na każdy stopień pojemników materii
#define BIOGAS_UNITS_PER_RATING 1
/// Ile moli metanu daje jednostka organicznego wsadu
#define BIOGAS_METHANE_PER_UNIT 0.4
/// Ile moli CO2 daje jednostka organicznego wsadu
#define BIOGAS_CO2_PER_UNIT 0.2
/// Temperatura biogazu (fermentacja mezofilna)
#define BIOGAS_TEMPERATURE (T0C + 35)
/// Powyżej tego ciśnienia w rurze biogazownia czeka
#define BIOGAS_MAX_OUTPUT_PRESSURE (ONE_ATMOSPHERE * 45)
/// Najwięcej jednostek ścieków, które zbiera kanalizacja statku
#define SHIP_SEWAGE_MAX 5000
/// Ile jednostek ścieków to jedna kupa spłukana w sedesie
#define SEWAGE_UNITS_PER_FECES 10

/// Jednostki organicznych ścieków spłukanych w sedesach i odpływach, czekające na biogazownię
GLOBAL_VAR_INIT(ship_sewage, 0)

/// Odczynniki, które fermentują w biogazowni i liczą się jako organiczne ścieki z odpływów
GLOBAL_LIST_INIT(biogas_organic_reagents, typecacheof(list(
	/datum/reagent/ammonia/urine,
	/datum/reagent/blood,
	/datum/reagent/liquidgibs,
	/datum/reagent/consumable/nutriment,
	/datum/reagent/consumable/sugar,
	/datum/reagent/consumable/milk,
	/datum/reagent/consumable/eggyolk,
	/datum/reagent/cellulose,
	/datum/reagent/plantnutriment,
)))

/// Dopisuje organiczne ścieki do kanalizacji statku
/proc/add_ship_sewage(amount)
	if(amount <= 0)
		return
	GLOB.ship_sewage = min(SHIP_SEWAGE_MAX, GLOB.ship_sewage + amount)

/// Ile jednostek organicznych odczynników jest w pojemniku
/proc/get_organic_reagent_volume(datum/reagents/holder)
	. = 0
	for(var/datum/reagent/reagent as anything in holder?.reagent_list)
		if(is_type_in_typecache(reagent, GLOB.biogas_organic_reagents))
			. += reagent.volume

/obj/machinery/atmospherics/components/unary/biogas_plant
	name = "biogazownia"
	desc = "Szczelny zbiornik fermentacyjny. Z moczu, krwi, nawozów i resztek jedzenia robi biogaz: metan z domieszką dwutlenku węgla. Sama dobiera też ścieki z sedesów i odpływów statku."
	icon = 'aquila/icons/obj/atmospherics/biogas_plant.dmi'
	icon_state = "biogas"
	density = TRUE
	layer = OBJ_LAYER
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/biogas_plant
	idle_power_usage = 100
	active_power_usage = 500
	/// Ile jednostek wsadu przerabia na cykl (z pojemników materii)
	var/units_per_tick = BIOGAS_UNITS_PER_RATING * 2

/obj/machinery/atmospherics/components/unary/biogas_plant/Initialize(mapload)
	. = ..()
	create_reagents(BIOGAS_TANK_VOLUME, TRANSPARENT | REFILLABLE)
	AddComponent(/datum/component/plumbing/simple_demand)
	update_icon()

/obj/machinery/atmospherics/components/unary/biogas_plant/on_construction()
	return ..(null, PIPING_LAYER_DEFAULT)

/obj/machinery/atmospherics/components/unary/biogas_plant/RefreshParts()
	var/bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		bin_rating += bin.rating
	units_per_tick = BIOGAS_UNITS_PER_RATING * max(1, bin_rating)

/obj/machinery/atmospherics/components/unary/biogas_plant/examine(mob/user)
	. = ..()
	. += span_notice("Jest [on ? "włączona" : "wyłączona"]. Kliknij, żeby ją [on ? "wyłączyć" : "włączyć"].")
	. += span_notice("Wlej do niej organiczne odczynniki albo wrzuć jedzenie. Przerabia [units_per_tick] j. wsadu na cykl, biogaz wychodzi rurą.")
	. += span_notice("W kanalizacji statku czeka [round(GLOB.ship_sewage)] j. ścieków.")

/obj/machinery/atmospherics/components/unary/biogas_plant/update_icon_nopipes()
	if(panel_open)
		icon_state = "biogas-o"
	else if(on && is_operational)
		icon_state = "biogas_on"
	else
		icon_state = "biogas"

/obj/machinery/atmospherics/components/unary/biogas_plant/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/components/unary/biogas_plant/interact(mob/user)
	if(panel_open)
		to_chat(user, span_warning("Najpierw zamknij panel."))
		return
	on = !on
	use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, on ? "włączona" : "wyłączona")
	update_icon()

/obj/machinery/atmospherics/components/unary/biogas_plant/attackby(obj/item/I, mob/user, params)
	if(!on && default_deconstruction_screwdriver(user, "biogas-o", "biogas", I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/food))
		add_food(I, user)
		return
	return ..()

/// Wrzuca jedzenie do zbiornika: jego odczynniki trafiają do wsadu
/obj/machinery/atmospherics/components/unary/biogas_plant/proc/add_food(obj/item/food/food, mob/user)
	if(reagents.holder_full())
		to_chat(user, span_warning("Zbiornik [src] jest pełny."))
		return FALSE
	if(user && !user.transferItemToLoc(food, src))
		return FALSE
	food.reagents?.trans_to(src, food.reagents.total_volume, no_react = TRUE)
	if(user)
		to_chat(user, span_notice("Wrzucasz [food] do [src]."))
	qdel(food)
	return TRUE

/obj/machinery/atmospherics/components/unary/biogas_plant/process_atmos()
	if(!on || !is_operational)
		return
	ferment(airs[1])

/// Przerabia wsad ze zbiornika i ze ścieków statku na biogaz w podanej mieszaninie. Zwraca liczbę przerobionych jednostek
/obj/machinery/atmospherics/components/unary/biogas_plant/proc/ferment(datum/gas_mixture/output)
	if(output.return_pressure() >= BIOGAS_MAX_OUTPUT_PRESSURE)
		return 0
	var/digested = 0
	for(var/datum/reagent/reagent as anything in reagents.reagent_list.Copy())
		if(digested >= units_per_tick)
			break
		if(!is_type_in_typecache(reagent, GLOB.biogas_organic_reagents))
			continue
		var/amount = min(reagent.volume, units_per_tick - digested)
		reagents.remove_reagent(reagent.type, amount)
		digested += amount
	var/from_sewage = min(GLOB.ship_sewage, units_per_tick - digested)
	if(from_sewage > 0)
		GLOB.ship_sewage -= from_sewage
		digested += from_sewage
	if(digested <= 0)
		return 0
	var/datum/gas_mixture/biogas = new
	biogas.set_temperature(BIOGAS_TEMPERATURE)
	biogas.set_moles(GAS_METHANE, digested * BIOGAS_METHANE_PER_UNIT)
	biogas.set_moles(GAS_CO2, digested * BIOGAS_CO2_PER_UNIT)
	output.merge(biogas)
	update_parents()
	return digested

/obj/item/circuitboard/machine/biogas_plant
	name = "biogazownia (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/biogas_plant
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2)

/datum/design/board/biogas_plant
	name = "Projekt maszyny (biogazownia)"
	desc = "Płytka drukowana: biogazownia."
	id = "biogas_plant"
	build_path = /obj/item/circuitboard/machine/biogas_plant
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "biogas_plant"

// Kanalizacja: spłukana zawartość muszli idzie do ścieków statku (zatkana toaleta zostawia ją w muszli)
/obj/structure/toilet/flush(mob/user, silent = FALSE)
	var/waste = clogged ? 0 : bowl_urine + bowl_feces * SEWAGE_UNITS_PER_FECES
	. = ..()
	if(. && waste > 0 && !clogged && !bowl_urine && !bowl_feces)
		add_ship_sewage(waste)

// Kanalizacja: organiczna część cieczy spływającej odpływem idzie do ścieków statku
/obj/structure/drain/process(delta_time)
	var/datum/liquid_group/group = my_turf?.liquids?.liquid_group
	if(QDELETED(group) || group.frozen || !group.total_reagent_volume)
		return ..()
	var/volume_before = group.total_reagent_volume
	var/organic_share = get_organic_reagent_volume(group.reagents) / volume_before
	. = ..()
	if(organic_share > 0)
		var/drained = QDELETED(group) ? volume_before : volume_before - group.total_reagent_volume
		add_ship_sewage(drained * organic_share)

#undef BIOGAS_TANK_VOLUME
#undef BIOGAS_UNITS_PER_RATING
#undef BIOGAS_METHANE_PER_UNIT
#undef BIOGAS_CO2_PER_UNIT
#undef BIOGAS_TEMPERATURE
#undef BIOGAS_MAX_OUTPUT_PRESSURE
#undef SHIP_SEWAGE_MAX
#undef SEWAGE_UNITS_PER_FECES
