/*
	AQUILA - rośliny-artefakty z Goonstation (podtypy /datum/plant/artifact i man-eater)
	Ciała roślin, torebki i część plonów ze sprite'ów Goona (ported_obce_body.dmi 32x48, ported_obce_seeds.dmi,
	ported_obce_harvest.dmi, CC-BY-NC-SA 3.0). Zachowania na cechach ciała (jak ciernie i szczawik)
	i owocu (jak pomidor zabójca), bez osobnych systemów.
*/

/// Ile razy w rundzie pełzacze mogą się rozsiać do sąsiednich pustych donic (łącznie, wszystkie rośliny)
#define CREEPER_MAX_SPREADS 20
/// O ile pełzacz rani rośliny w sąsiednich donicach przy każdej próbie rozrostu
#define CREEPER_NEIGHBOUR_DAMAGE 5
/// Ile jednostek odczynnika z owocu kapie naraz z ciekacza
#define DRIPPER_DRIP_AMOUNT 2

GLOBAL_VAR_INIT(aquila_creeper_spreads, 0)

/*
	Ciała roślin-artefaktów (sprite'y z Goona, etapy 1-3 i dojrzała roślina)
*/
/datum/plant_feature/body/alien_artifact
	species_name = "artefactum"
	name = "roślina-artefakt"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_body.dmi'
	icon_state = "crystal"
	growth_prefix = "crystal"
	growth_stages = 4
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_SMALL
	upper_fruit_size = PLANT_FRUIT_SIZE_MEDIUM
	growth_time = PLANT_BODY_GROWTH_FAST
	abstract_type = /datum/plant_feature/body/alien_artifact

/datum/plant_feature/body/alien_artifact/growth_step(step)
	. = ..()
	playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)

/datum/plant_feature/body/alien_artifact/peeker
	species_name = "speculator oculatus"
	name = "podglądacz"
	icon_state = "peeker"
	growth_prefix = "peeker"
	overlay_positions = list(list(9, 25), list(19, 26), list(13, 16), list(20, 15), list(8, 13))
	plant_traits = list(/datum/plant_trait/body/thorns/peeker)

/datum/plant_feature/body/alien_artifact/puker
	species_name = "vomitor purpureus"
	name = "rzygacz"
	icon_state = "puker"
	growth_prefix = "puker"
	overlay_positions = list(list(11, 20), list(23, 22), list(16, 13), list(24, 12))
	plant_traits = list(/datum/plant_trait/body/alien_periodic/puker)

/datum/plant_feature/body/alien_artifact/dripper
	species_name = "stillator viridis"
	name = "ciekacz"
	icon_state = "dripper"
	growth_prefix = "dripper"
	overlay_positions = list(list(9, 22), list(20, 23), list(13, 14), list(22, 12))
	plant_traits = list(/datum/plant_trait/body/alien_periodic/dripper)

/datum/plant_feature/body/alien_artifact/lotus
	species_name = "lotus lucidus"
	name = "lotos świetlny"
	icon_state = "lotus"
	growth_prefix = "lotus"
	growth_time = PLANT_BODY_GROWTH_MEDIUM
	overlay_positions = list(list(8, 13), list(19, 14), list(20, 7))
	plant_traits = list(/datum/plant_trait/body/alien_periodic/glow)

/datum/plant_feature/body/alien_artifact/creeper
	species_name = "serpens roseus"
	name = "pełzacz"
	icon_state = "creeper"
	growth_prefix = "creeper"
	overlay_positions = list(list(10, 12), list(22, 13), list(14, 8), list(24, 7))
	plant_traits = list(/datum/plant_trait/body/alien_periodic/creeper)

/datum/plant_feature/body/alien_artifact/crystal
	species_name = "crystallum vivum"
	name = "kryształ"
	icon_state = "crystal"
	growth_prefix = "crystal"
	growth_time = PLANT_BODY_GROWTH_MEDIUM
	overlay_positions = list(list(9, 15), list(17, 16), list(18, 8))

/datum/plant_feature/body/alien_artifact/plasma
	species_name = "plasmaticus floridus"
	name = "roślina plazmowa"
	icon_state = "plasma"
	growth_prefix = "plasma"
	overlay_positions = list(list(11, 14), list(19, 15), list(20, 8))

/datum/plant_feature/body/alien_artifact/goldfish
	species_name = "carassius corallinus"
	name = "koralowiec złotej rybki"
	icon_state = "goldfish"
	growth_prefix = "goldfish"
	overlay_positions = list(list(9, 21), list(19, 22), list(13, 14), list(20, 12))

/datum/plant_feature/body/alien_artifact/cat
	species_name = "felis synthetica"
	name = "kocia roślina"
	icon_state = "cat"
	growth_prefix = "cat"
	overlay_positions = list(list(10, 7), list(17, 8), list(18, 4))

/datum/plant_feature/body/alien_artifact/maneater
	species_name = "anthropophagus viridis"
	name = "ludożerca"
	icon_state = "maneater"
	growth_prefix = "maneater"
	overlay_positions = list(list(10, 22), list(20, 23), list(14, 14), list(22, 12))
	plant_traits = list(/datum/plant_trait/body/maneater_bite)

/*
	Spojrzenie (podglądacz): dojrzała roślina obraca się w stronę przechodzących i się w nich wpatruje
*/
/datum/plant_trait/body/thorns/peeker
	name = "Spojrzenie"
	desc = "Dojrzała roślina obraca się w stronę przechodzących obok i wpatruje się w nich."
	random_trait = FALSE
	turf_range = 2
	///Czy roślina jest teraz odwrócona w lewo
	var/facing_left = FALSE
	COOLDOWN_DECLARE(stare_cooldown)

/datum/plant_trait/body/thorns/peeker/catch_entered(datum/source, atom/movable/entering)
	if(!plant_item?.loc?.GetComponent(/datum/component/planter))
		return
	var/mob/living/victim = entering
	if(!isliving(victim) || victim.stat == DEAD)
		return
	var/datum/plant_feature/body/body = parent
	if(!istype(body) || body.current_stage < body.growth_stages || body.health <= 0)
		return
	face(victim)
	if(!COOLDOWN_FINISHED(src, stare_cooldown))
		return
	COOLDOWN_START(src, stare_cooldown, 10 SECONDS)
	plant_item.visible_message(span_warning("[plant_item] wpatruje się w: [victim]."))

///Odwraca roślinę w poziomie, żeby patrzyła na cel
/datum/plant_trait/body/thorns/peeker/proc/face(atom/target)
	var/turf/our_turf = get_turf(plant_item)
	var/turf/target_turf = get_turf(target)
	if(!our_turf || !target_turf || target_turf.x == our_turf.x)
		return
	var/turn_left = target_turf.x < our_turf.x
	if(turn_left == facing_left)
		return
	facing_left = turn_left
	var/matrix/flipped = matrix(plant_item.transform)
	flipped.Scale(-1, 1)
	plant_item.transform = flipped

/*
	Cechy działające co jakiś czas, gdy roślina jest dojrzała i rośnie w donicy
*/
/datum/plant_trait/body/alien_periodic
	abstract_type = /datum/plant_trait/body/alien_periodic
	random_trait = FALSE
	///Co ile najwyżej zachodzi efekt
	var/effect_cooldown = 30 SECONDS
	///Szansa na efekt przy każdym sprawdzeniu po upływie przerwy
	var/effect_chance = 100
	COOLDOWN_DECLARE(effect_timer)
	///Komponent rośliny, na której działamy
	var/datum/component/plant/plant_comp

/datum/plant_trait/body/alien_periodic/Destroy(force, ...)
	STOP_PROCESSING(SSobj, src)
	plant_comp = null
	return ..()

/datum/plant_trait/body/alien_periodic/setup_component_parent(datum/source)
	. = ..()
	plant_comp = source
	if(!istype(plant_comp))
		plant_comp = null
		return
	COOLDOWN_START(src, effect_timer, effect_cooldown)
	START_PROCESSING(SSobj, src)

/datum/plant_trait/body/alien_periodic/catch_component_qdel(datum/source)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	plant_comp = null

/datum/plant_trait/body/alien_periodic/process(delta_time)
	if(!can_act() || !COOLDOWN_FINISHED(src, effect_timer) || !prob(effect_chance))
		return
	COOLDOWN_START(src, effect_timer, effect_cooldown)
	periodic_effect()

///Roślina jest dojrzała, żywa i rośnie w donicy, która jej nie wstrzymuje
/datum/plant_trait/body/alien_periodic/proc/can_act()
	var/datum/plant_feature/body/body = parent
	if(!istype(body) || !plant_comp?.plant_item || body.health <= 0 || body.current_stage < body.growth_stages)
		return FALSE
	var/atom/planter = plant_comp.plant_item.loc
	if(!planter?.GetComponent(/datum/component/planter) || SEND_SIGNAL(planter, COMSIG_PLANTER_PAUSE_PLANT))
		return FALSE
	return TRUE

///Właściwy efekt cechy
/datum/plant_trait/body/alien_periodic/proc/periodic_effect()
	return

/*
	Wymioty (rzygacz)
*/
/datum/plant_trait/body/alien_periodic/puker
	name = "Wymioty"
	desc = "Dojrzała roślina co jakiś czas obficie wymiotuje na podłogę."
	effect_cooldown = 20 SECONDS
	effect_chance = 20

/datum/plant_trait/body/alien_periodic/puker/periodic_effect()
	var/turf/our_turf = get_turf(plant_comp.plant_item)
	if(!our_turf)
		return
	plant_comp.plant_item.visible_message(span_warning("[plant_comp.plant_item] obficie wymiotuje!"))
	playsound(our_turf, 'sound/effects/splat.ogg', 50, TRUE)
	if(!(locate(/obj/effect/decal/cleanable/vomit) in our_turf))
		new /obj/effect/decal/cleanable/vomit(our_turf)

/*
	Kapanie (ciekacz)
*/
/datum/plant_trait/body/alien_periodic/dripper
	name = "Kapanie"
	desc = "Z dojrzałych owoców rośliny co jakiś czas skapuje na podłogę trochę ich odczynników."

/datum/plant_trait/body/alien_periodic/dripper/periodic_effect()
	var/turf/our_turf = get_turf(plant_comp.plant_item)
	var/datum/plant_feature/fruit/fruit_feature = locate() in plant_comp.plant_features
	if(!our_turf || !fruit_feature)
		return
	for(var/obj/item/fruit as anything in fruit_feature.fruits)
		if(!fruit.reagents?.total_volume)
			continue
		var/datum/reagents/drop = new(DRIPPER_DRIP_AMOUNT)
		fruit.reagents.trans_to(drop, DRIPPER_DRIP_AMOUNT)
		our_turf.spill_reagents(drop)
		qdel(drop)
		playsound(our_turf, 'sound/effects/slosh.ogg', 20, TRUE)
		plant_comp.plant_item.visible_message(span_notice("Z [plant_comp.plant_item] skapuje kropla."))
		return

/*
	Poświata (lotos świetlny): dojrzała roślina świeci
*/
/datum/plant_trait/body/alien_periodic/glow
	name = "Poświata"
	desc = "Dojrzała roślina świeci chłodnym, niebieskim światłem."
	scales = "Zasięg światła rośnie z mocą cech."
	///Czy roślina teraz świeci
	var/lit = FALSE

/datum/plant_trait/body/alien_periodic/glow/Destroy(force, ...)
	set_lit(FALSE)
	return ..()

/datum/plant_trait/body/alien_periodic/glow/catch_component_qdel(datum/source)
	set_lit(FALSE)
	return ..()

/datum/plant_trait/body/alien_periodic/glow/process(delta_time)
	set_lit(can_act())

/datum/plant_trait/body/alien_periodic/glow/proc/set_lit(new_lit)
	if(new_lit == lit || !plant_comp?.plant_item)
		return
	lit = new_lit
	if(lit)
		plant_comp.plant_item.set_light(3 * max(parent?.trait_power, 1), 1.5, "#6fa8ff")
	else
		plant_comp.plant_item.set_light(0)

/*
	Rozrastanie (pełzacz): zasiewa się w sąsiednich pustych donicach i podgryza sąsiednie rośliny
*/
/datum/plant_trait/body/alien_periodic/creeper
	name = "Rozrastanie"
	desc = "Dojrzała roślina zasiewa się w sąsiednich pustych donicach i rani rośliny rosnące obok. \
	Każda roślina rozsiewa się najwyżej dwa razy."
	effect_cooldown = 45 SECONDS
	effect_chance = 50
	///Ile razy ta roślina może się jeszcze rozsiać
	var/spreads_left = 2

/datum/plant_trait/body/alien_periodic/creeper/periodic_effect()
	var/turf/our_turf = get_turf(plant_comp.plant_item)
	if(!our_turf)
		return
	var/atom/our_planter = plant_comp.plant_item.loc
	var/spread = FALSE
	for(var/atom/candidate as anything in range(1, our_turf))
		if(candidate == our_planter)
			continue
		var/datum/component/planter/planter = candidate.GetComponent(/datum/component/planter)
		if(!planter)
			continue
		if(length(planter.plants))
			hurt_neighbours(planter)
			continue
		if(spread || spreads_left <= 0 || GLOB.aquila_creeper_spreads >= CREEPER_MAX_SPREADS)
			continue
		spread = spread_to(candidate)

///Rani rośliny innego gatunku w sąsiedniej donicy
/datum/plant_trait/body/alien_periodic/creeper/proc/hurt_neighbours(datum/component/planter/planter)
	for(var/datum/component/plant/other as anything in planter.plants)
		if(other == plant_comp)
			continue
		var/datum/plant_feature/body/other_body = locate() in other.plant_features
		if(!other_body || (locate(/datum/plant_trait/body/alien_periodic/creeper) in other_body.plant_traits))
			continue
		other_body.adjust_health(-CREEPER_NEIGHBOUR_DAMAGE)

///Zasiewa kopię rośliny w pustej donicy, zwraca TRUE po udanym zasiewie
/datum/plant_trait/body/alien_periodic/creeper/proc/spread_to(atom/target)
	var/obj/item/plant_seeds/seeds = new(get_turf(target), plant_comp.plant_features, plant_comp.species_id)
	seeds.name_override = plant_comp.name_override
	var/datum/component/plant/new_plant = seeds.plant(target, null, TRUE, null, TRUE)
	if(!QDELETED(seeds))
		qdel(seeds)
	if(!istype(new_plant))
		return FALSE
	spreads_left--
	GLOB.aquila_creeper_spreads++
	target.visible_message(span_warning("[plant_comp.plant_item] wpełza do: [target]!"))
	return TRUE

/*
	Gryzienie (ludożerca): dojrzała roślina gryzie każdego, kto jej dotknie
*/
/datum/plant_trait/body/maneater_bite
	name = "Gryzienie"
	desc = "Dojrzała roślina gryzie każdego, kto jej dotknie albo spróbuje ją zebrać."
	scales = "Obrażenia rosną z mocą cech."
	random_trait = FALSE
	///Obrażenia jednego ugryzienia przy mocy cech 1
	var/bite_damage = 9
	///Roślina, której dotyk sprawdzamy
	var/obj/item/plant_item
	COOLDOWN_DECLARE(bite_cooldown)

/datum/plant_trait/body/maneater_bite/Destroy(force, ...)
	plant_item = null
	return ..()

/datum/plant_trait/body/maneater_bite/setup_component_parent(datum/source)
	. = ..()
	var/datum/component/plant/plant_comp = source
	if(!istype(plant_comp))
		return
	plant_item = plant_comp.plant_item
	RegisterSignal(plant_item, COMSIG_ATOM_ATTACK_HAND, PROC_REF(catch_touch))
	RegisterSignal(plant_item, COMSIG_ATOM_ATTACKBY, PROC_REF(catch_attackby))

/datum/plant_trait/body/maneater_bite/catch_component_qdel(datum/source)
	. = ..()
	if(plant_item)
		UnregisterSignal(plant_item, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACKBY))
	plant_item = null

/datum/plant_trait/body/maneater_bite/proc/catch_touch(datum/source, mob/living/user)
	SIGNAL_HANDLER

	bite(user)

/datum/plant_trait/body/maneater_bite/proc/catch_attackby(datum/source, obj/item/item, mob/living/user)
	SIGNAL_HANDLER

	bite(user)

///Gryzie dotykającego, zwraca TRUE po ugryzieniu
/datum/plant_trait/body/maneater_bite/proc/bite(mob/living/user)
	var/datum/plant_feature/body/body = parent
	if(!isliving(user) || !plant_item || !istype(body) || body.current_stage < body.growth_stages || body.health <= 0)
		return FALSE
	if(!COOLDOWN_FINISHED(src, bite_cooldown))
		return FALSE
	COOLDOWN_START(src, bite_cooldown, 2 SECONDS)
	var/static/list/angry_lines = list("Łapy przy sobie!", "A co ty wyprawiasz?!", "Ty draniu!", "Ugryź mnie, łachudro!")
	plant_item.visible_message(span_danger("[plant_item] bulgocze: „[pick(angry_lines)]”"))
	to_chat(user, span_userdanger("[plant_item] ze złością cię gryzie!"))
	playsound(plant_item, 'sound/weapons/bite.ogg', 50, TRUE)
	user.apply_damage(bite_damage * max(body.trait_power, 1), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	log_combat(user, plant_item, "was bitten by")
	return TRUE

/*
	Przebudzenia owoców w zwierzęta (jak przyjazny pomidor)
*/
/datum/plant_trait/fruit/killer/friendly/synthcat
	name = "Kocie przebudzenie"
	desc = "Owoc przejawia skłonności do półświadomości. Aktywowany zamienia się w syntetycznego kota. \
	Dziedziczy cechy tego owocu."
	random_trait = FALSE
	awaken_mob = /mob/living/basic/pet/cat/synthetic

/datum/plant_trait/fruit/killer/maneater
	name = "Żarłoczne przebudzenie"
	desc = "Owoc przejawia skłonności do półświadomości. Aktywowany zamienia się w żądną krwi ludzką muchołówkę! \
	Dziedziczy cechy tego owocu."
	random_trait = FALSE
	awaken_mob = /mob/living/basic/venus_human_trap

/mob/living/basic/pet/cat/synthetic
	name = "syntetyczny kot"
	desc = "Kot wyhodowany w tacy hydroponicznej. Pachnie liśćmi, ale mruczy jak każdy inny."
	color = "#8fe39a"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/food/meat/slab/synthmeat = 1)

/*
	Podglądacz (Peeker)
*/
/datum/plant_feature/fruit/peeker
	species_name = "speculator oculatus"
	name = "oko podglądacza"
	icon_state = "orb"
	colour_override = "#f2f2f2"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/peeker_eye
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/oculine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/peeker
	name = "nasiona: podglądacz (ziemia)"
	name_override = "podglądacz"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/alien_artifact/peeker, /datum/plant_feature/fruit/peeker)

/obj/item/food/grown/peeker_eye
	seed = /obj/item/plant_seeds/preset/alien/peeker
	name = "oko podglądacza"
	desc = "Oślizgła gałka oczna, która wyrosła na krzaku. Wciąż się na ciebie patrzy."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "peeker_eye"
	foodtypes = VEGETABLES | GROSS
	tastes = list("galareta" = 1)

/*
	Rzygacz (Puker)
*/
/datum/plant_feature/fruit/puker
	species_name = "vomitor purpureus"
	name = "wymiotna maź"
	icon_state = "pod"
	colour_override = "#d98c2e"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/puker_goop
	fast_reagents = list(/datum/reagent/toxin/spewium = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/puker
	name = "nasiona: rzygacz (glina)"
	name_override = "rzygacz"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/alien_artifact/puker, /datum/plant_feature/fruit/puker)

/obj/item/food/grown/puker_goop
	seed = /obj/item/plant_seeds/preset/alien/puker
	name = "wymiotna maź"
	desc = "Pomarańczowa, pulsująca maź, którą wypluł rzygacz."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "pukegoop"
	foodtypes = GROSS | TOXIC
	tastes = list("wymiociny" = 1)

/*
	Ciekacz (Dripper)
*/
/datum/plant_feature/fruit/dripper
	species_name = "stillator viridis"
	name = "fioletowa maź"
	icon_state = "grapes"
	colour_override = "#9865c5"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/purple_goop
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin/plasma = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/alien/dripper
	name = "nasiona: ciekacz (glina)"
	name_override = "ciekacz"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/alien_artifact/dripper, /datum/plant_feature/fruit/dripper)

/obj/item/food/grown/purple_goop
	seed = /obj/item/plant_seeds/preset/alien/dripper
	name = "fioletowa maź"
	desc = "Yyy... no dobrze."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "purplegoop"
	foodtypes = GROSS
	tastes = list("maź" = 1)

/*
	Lotos świetlny (Light Lotus)
*/
/datum/plant_feature/fruit/glowfruit
	species_name = "lotus lucidus"
	name = "świecący owoc"
	icon_state = "orb"
	colour_override = "#3a6cff"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/glowfruit
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/biolight/blue)
	fast_reagents = list(/datum/reagent/luminol = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/alien/lotus
	name = "nasiona: lotos świetlny (piasek)"
	name_override = "lotos świetlny"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/alien_artifact/lotus, /datum/plant_feature/fruit/glowfruit)

/obj/item/food/grown/glowfruit
	seed = /obj/item/plant_seeds/preset/alien/lotus
	name = "świecący owoc"
	desc = "Owoc lotosu świetlnego. Świeci własnym, chłodnym światłem."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "glowfruit"
	foodtypes = FRUIT
	tastes = list("chłodna słodycz" = 1)

/*
	Pełzacz (Creeper)
*/
/datum/plant_feature/fruit/creeper
	species_name = "serpens roseus"
	name = "pędy pełzacza"
	icon_state = "tea_2"
	colour_override = "#cc66ff"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/creeper
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/alien/creeper
	name = "nasiona: pełzacz (ziemia)"
	name_override = "pełzacz"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/alien_artifact/creeper, /datum/plant_feature/fruit/creeper)

/obj/item/food/grown/creeper
	seed = /obj/item/plant_seeds/preset/alien/creeper
	name = "pędy pełzacza"
	desc = "Splątane, różowe pędy. Nawet ścięte próbują się czegoś uchwycić."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "creeper"
	gender = PLURAL
	foodtypes = VEGETABLES
	tastes = list("gorzkie pędy" = 1)

/*
	Kryształ (Crystal) - plonem odłamki szkła plazmowego
*/
/datum/plant_feature/fruit/crystal
	species_name = "crystallum vivum"
	name = "kryształ"
	icon_state = "star"
	colour_override = "#d9b3ff"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/shard/plasma
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/alien/crystal
	name = "nasiona: kryształ (gruz)"
	name_override = "kryształ"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/alien_artifact/crystal, /datum/plant_feature/fruit/crystal)

/*
	Roślina plazmowa (Plasma) - zarodnik pękający chmurą plazmy
*/
/datum/plant_feature/fruit/plasma_spore
	species_name = "plasmaticus floridus"
	name = "zarodnik plazmy"
	icon_state = "orb"
	colour_override = "#9865c5"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/plasma_spore
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/gaseous)
	fast_reagents = list(/datum/reagent/toxin/plasma = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/alien/plasma
	name = "nasiona: roślina plazmowa (gruz)"
	name_override = "roślina plazmowa"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/alien_artifact/plasma, /datum/plant_feature/fruit/plasma_spore)

/obj/item/food/grown/plasma_spore
	seed = /obj/item/plant_seeds/preset/alien/plasma
	name = "zarodnik plazmy"
	desc = "Ledwie świadoma kolonia organizmów. Bardzo lotna."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "plasmaspore"
	foodtypes = TOXIC
	tastes = list("plazma" = 1)

/*
	Złota rybka (Goldfish) - plonem żywa złota rybka do akwarium
*/
/datum/plant_feature/fruit/goldfish
	species_name = "carassius corallinus"
	name = "złota rybka"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_fruit.dmi'
	icon_state = "goldfish"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/fish/goldfish_plant
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/goldfish
	name = "nasiona: złota rybka (piasek)"
	name_override = "złota rybka"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/alien_artifact/goldfish, /datum/plant_feature/fruit/goldfish)

/obj/item/fish/goldfish_plant
	name = "złota rybka"
	desc = "Złota rybka, która wyrosła na koralowcu w tacy hydroponicznej. Da się ją wpuścić do akwarium."
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "goldfish"

/obj/item/fish/goldfish_plant/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/deferred_aquarium_content, /datum/aquarium_behaviour/fish/goldfish)

/*
	Syntetyczny kot (Synthetic Cat) - strąk, z którego wychodzi kot
*/
/datum/plant_feature/fruit/synthcat
	species_name = "felis synthetica"
	name = "kotostrąk"
	icon_state = "pod"
	colour_override = "#3fae5a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-artifact"
	fruit_product = /obj/item/food/grown/synthcat_pod
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/liquid_contents/sensitive, /datum/plant_trait/fruit/killer/friendly/synthcat)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/synthcat
	name = "nasiona: syntetyczny kot (ziemia)"
	name_override = "syntetyczny kot"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-artifact"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/alien_artifact/cat, /datum/plant_feature/fruit/synthcat)

/obj/item/food/grown/synthcat_pod
	seed = /obj/item/plant_seeds/preset/alien/synthcat
	name = "kotostrąk"
	desc = "Zielony strąk, który cicho mruczy. Rzucony albo ściśnięty wypuszcza syntetycznego kota."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "synthcat_pod"
	foodtypes = VEGETABLES
	tastes = list("sierść" = 1)

/*
	Ludożerca (Man-Eating Plant) - gryzie, a jego pąki budzą się jako ludzkie muchołówki
*/
/datum/plant_feature/fruit/maneater
	species_name = "anthropophagus viridis"
	name = "paszcza ludożercy"
	icon_state = "pod"
	colour_override = "#6f8f55"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-maneater"
	fruit_product = /obj/item/food/grown/maneater_pod
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/liquid_contents/sensitive, /datum/plant_trait/fruit/killer/maneater)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/alien/maneater
	name = "nasiona: ludożerca (ziemia)"
	name_override = "ludożerca"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-maneater"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/alien_artifact/maneater, /datum/plant_feature/fruit/maneater)

/obj/item/food/grown/maneater_pod
	seed = /obj/item/plant_seeds/preset/alien/maneater
	name = "paszcza ludożercy"
	desc = "Pąk z rzędem drobnych zębów. Rzucony albo ściśnięty wypuszcza ludożerczą roślinę."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "maneater_pod"
	foodtypes = VEGETABLES | GROSS
	tastes = list("krew" = 1)

#undef CREEPER_MAX_SPREADS
#undef CREEPER_NEIGHBOUR_DAMAGE
#undef DRIPPER_DRIP_AMOUNT
