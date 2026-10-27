// AQUILA - Dym i zapachy: źródła. Monke wpisywał je w kod core, u nas są nadpisaniami z ..()

// Smoking

/obj/item/clothing/mask/cigarette
	/// What type of pollution does this produce on smoking, changed to weed pollution sometimes
	var/pollution_type = /datum/pollutant/smoke

/obj/item/clothing/mask/cigarette/light(flavor_text = null)
	// Setting the puffed pollutant to cannabis if we're smoking the space drugs reagent (obtained from cannabis)
	if(!lit && reagents?.has_reagent(/datum/reagent/drug/space_drugs))
		pollution_type = /datum/pollutant/smoke/cannabis
	return ..()

/obj/item/clothing/mask/cigarette/process(delta_time)
	. = ..()
	if(QDELETED(src) || !lit)
		return
	var/turf/location = get_turf(src)
	location?.pollute_turf(pollution_type, 5, POLLUTION_PASSIVE_EMITTER_CAP)

// Pipes have their own process() that skips the cigarette one
/obj/item/clothing/mask/cigarette/pipe/process(delta_time)
	. = ..()
	if(QDELETED(src) || !lit)
		return
	var/turf/location = get_turf(src)
	location?.pollute_turf(pollution_type, 5, POLLUTION_PASSIVE_EMITTER_CAP)

/obj/item/clothing/mask/vape/process(delta_time)
	. = ..()
	if(QDELETED(src) || !reagents?.total_volume || !ismob(loc))
		return
	var/turf/my_turf = get_turf(src)
	my_turf?.pollute_turf(/datum/pollutant/smoke/vape, 5, POLLUTION_PASSIVE_EMITTER_CAP)

/obj/item/match/matchignite()
	var/was_lit = lit || burnt
	. = ..()
	if(was_lit || !lit)
		return
	var/turf/my_turf = get_turf(src)
	my_turf?.pollute_turf(/datum/pollutant/sulphur, 5)

// Fire

/obj/effect/hotspot/perform_exposure()
	. = ..()
	if(!.)
		return
	var/turf/open/location = loc
	location.pollute_turf_list(list(/datum/pollutant/smoke = 15, /datum/pollutant/carbon_air_pollution = 5), POLLUTION_ACTIVE_EMITTER_CAP)

// Grilling

/datum/component/grillable
	/// What type of pollutant we spread around as we are grilled, can be none
	var/pollutant_type

/datum/component/grillable/Initialize(cook_result, required_cook_time, positive_result, use_large_steam_sprite)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || !positive_result)
		return
	// Monke passed this in every make_grillable(), we pick it from the food type instead
	if(istype(parent, /obj/item/food/meat/rawbacon))
		pollutant_type = /datum/pollutant/food/fried_bacon
	else if(istype(parent, /obj/item/food/fishmeat))
		pollutant_type = /datum/pollutant/food/fried_fish
	else if(istype(parent, /obj/item/food/meat) || istype(parent, /obj/item/food/raw_patty) || istype(parent, /obj/item/food/raw_sausage) || istype(parent, /obj/item/food/raw_meatball))
		pollutant_type = /datum/pollutant/food/fried_meat

/datum/component/grillable/OnGrill(datum/source, atom/used_grill, delta_time = 1)
	. = ..()
	if(!pollutant_type || QDELETED(parent))
		return
	var/turf/parent_turf = get_turf(parent)
	parent_turf?.pollute_turf(pollutant_type, 10, POLLUTION_PASSIVE_EMITTER_CAP)

// Chemistry

/datum/chemical_reaction
	///If defined, it'll emitt that pollutant on reaction
	var/pollutant_type
	///How much amount per volume of the pollutant shall we emitt if `pollutant_type` is defined
	var/pollutant_amount = 1

/datum/chemical_reaction/New()
	. = ..()
	// Monke set this on its /datum/chemical_reaction/medicine parent, our medicines are tagged instead
	if(!pollutant_type && (reaction_tags & REACTION_TAG_HEALING))
		pollutant_type = /datum/pollutant/chemical_vapors
		pollutant_amount = 0.2

/datum/chemical_reaction/food/coffee
	pollutant_type = /datum/pollutant/food/coffee

/datum/chemical_reaction/food/tea
	pollutant_type = /datum/pollutant/food/tea

/datum/chemical_reaction/food/hot_ramen
	pollutant_type = /datum/pollutant/food/spicy_noodles

/datum/chemical_reaction/food/hell_ramen
	pollutant_type = /datum/pollutant/food/spicy_noodles

/datum/reagents/instant_react(datum/chemical_reaction/selected_reaction)
	if(!selected_reaction.pollutant_type || !my_atom)
		return ..()
	var/turf/my_turf = get_turf(my_atom)
	var/multiplier = INFINITY
	for(var/requirement in selected_reaction.required_reagents)
		multiplier = min(multiplier, get_reagent_amount(requirement) / selected_reaction.required_reagents[requirement])
	. = ..()
	if(. && my_turf && multiplier != INFINITY)
		my_turf.pollute_turf(selected_reaction.pollutant_type, selected_reaction.pollutant_amount * multiplier)

/datum/reagents/end_reaction(datum/equilibrium/equilibrium)
	var/datum/chemical_reaction/reaction = equilibrium?.reaction
	if(!reaction?.pollutant_type || !my_atom)
		return ..()
	var/turf/my_turf = get_turf(my_atom)
	var/reacted_vol = equilibrium.reacted_vol
	. = ..()
	if(reacted_vol > 0)
		my_turf?.pollute_turf(reaction.pollutant_type, reaction.pollutant_amount * reacted_vol)

// Drinks and candles

/obj/item/reagent_containers/food/drinks/coffee/Initialize(mapload)
	. = ..()
	// AQUILA - only fresh drinks, mapped ones would pile up smell all through the lobby
	if(!mapload)
		AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/coffee, 5, 3 MINUTES)

/obj/item/reagent_containers/food/drinks/mug/tea/Initialize(mapload)
	. = ..()
	if(!mapload)
		AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/tea, 5, 3 MINUTES)

/obj/item/reagent_containers/food/drinks/mug/cocoa/Initialize(mapload)
	. = ..()
	if(!mapload)
		AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/chocolate, 5, 3 MINUTES)

/obj/item/candle
	/// Pollutant type for scented candles
	var/scented_type

/obj/item/candle/process(delta_time)
	. = ..()
	if(QDELETED(src) || !lit || !scented_type)
		return
	var/turf/my_turf = get_turf(src)
	my_turf?.pollute_turf(scented_type, 5, POLLUTION_PASSIVE_EMITTER_CAP)

// Constant emitters on dirt. No rot smell on gibs and corpses, miasma (SSmiasma) already covers those.

/obj/effect/decal/cleanable/greenglow/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/chemical_vapors, 10)

/obj/effect/decal/cleanable/vomit/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/obj/effect/decal/cleanable/insectguts/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 10)
