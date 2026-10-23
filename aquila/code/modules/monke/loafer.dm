// Loafer i bochenek więzienny z Monkestation (monkestation/code/modules/loafing, autor Lmenvs, pomysł z Goona).
// Różnice:
// - prasowanie nie śpi w transfer() (u nas ruch rury to move loop SSmove_manager), tylko trzyma holder w loaferze na timerze;
// - bez warp_effect przy stanie krytycznym, bez force_feed_on_aggression;
// - odczynniki: bone_dust/urine/organ_tissue zastąpione naszymi (liquidgibs, blood), sól to sodiumchloride,
//   nanomaszyny borgizujące to /datum/reagent/nanomachines; nutraslop i gravitum dodane niżej;
// - bochenek z prętem odpala pręt przy uderzeniu po rzucie (nie mamy after_throw).

#define LOAF_ANOMALY_MOVECHANCE 45
#define LOAF_CRITICAL_LIFESPAN (99 SECONDS)
/// Gęstość, powyżej której bochenek przechodzi w stan krytyczny (bez emaga to maksimum)
#define LOAF_CRITICAL_DENSITY 100000

/obj/structure/disposalpipe/loafer
	name = "prasa bochenkowa"
	desc = "Urządzenie do karmienia więźniów, które prasuje materię w Ultra Pyszny(tm) baton odżywczy!"
	icon = 'aquila/icons/obj/monke/loaf.dmi'
	icon_state = "loafer"
	initialize_dirs = DISP_DIR_FLIP
	/// Czy właśnie prasuje
	var/is_loafing = FALSE
	/// Holdery, które już przeszły prasowanie i mają tylko przepłynąć dalej
	var/list/finished_holders
	var/static/list/loaf_blacklist

/obj/structure/disposalpipe/loafer/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	if(isnull(loaf_blacklist))
		loaf_blacklist = typecacheof(list(/obj/item/organ/brain, /obj/item/bodypart/head)) - typecacheof(list(/obj/item/bodypart/head/monkey))

/obj/structure/disposalpipe/loafer/Destroy()
	for(var/holder in finished_holders)
		forget_holder(holder)
	return ..()

/obj/structure/disposalpipe/loafer/examine(mob/user)
	. = ..()
	if((obj_flags & EMAGGED) && (isobserver(user) || Adjacent(user)))
		. += "<span class='warning'>Mały mechanizm z boku prasy wygląda na usmażony.</span>"

/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/holder)
	if(is_loafing)
		return src
	if(holder in finished_holders)
		forget_holder(holder)
		return ..()

	// Najpierw wybieramy, co da się sprasować; rzeczy z czarnej listy płyną dalej bez zmian
	var/list/to_loaf = list()
	for(var/atom/movable/debris as anything in holder.contents)
		var/mob/living/living_debris = isliving(debris) ? debris : null
		var/obj/obj_debris = isobj(debris) ? debris : null
		if((obj_debris && (obj_debris.resistance_flags & INDESTRUCTIBLE)) || is_type_in_typecache(debris, loaf_blacklist) || (living_debris && (living_debris.status_flags & GODMODE)))
			continue
		to_loaf += debris
	if(!length(to_loaf))
		return ..()

	var/obj/item/food/prison_loaf/loaf = new(src)
	for(var/atom/movable/debris as anything in to_loaf)
		if(QDELETED(debris))
			continue
		debris.reagents?.trans_to(loaf, 1000)
		if(istype(debris, /obj/item/food/prison_loaf))
			var/obj/item/food/prison_loaf/loaf_to_grind = debris
			loaf.loaf_density += loaf_to_grind.loaf_density * 1.05
		else if(isliving(debris))
			var/mob/living/victim = debris
			if(issilicon(victim))
				loaf.reagents.add_reagent(/datum/reagent/fuel, 10)
				loaf.reagents.add_reagent(/datum/reagent/iron, 10)
			else
				loaf.reagents.add_reagent(/datum/reagent/liquidgibs, 5)
				loaf.reagents.add_reagent(/datum/reagent/blood, 4)
			loaf.loaf_density += ishuman(victim) ? 25 : 10
			if(victim.stat != DEAD)
				victim.emote("scream")
			log_combat(victim, src, "was loafed by")
			if(victim.mind || victim.client)
				victim.ghostize(FALSE)
			victim.gib()
		else if(isitem(debris))
			var/obj/item/kitchen_sink = debris
			loaf.loaf_density += kitchen_sink.w_class * 3
		if(!QDELETED(debris))
			qdel(debris)

	if(!(obj_flags & EMAGGED))
		loaf.loaf_density = min(loaf.loaf_density, LOAF_CRITICAL_DENSITY)

	is_loafing = TRUE
	update_icon()
	playsound(src, 'aquila/sound/monke/loafer.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(finish_loaf), holder, loaf), 3 SECONDS)
	return src

/// Kończy prasowanie i oddaje bochenek do rury
/obj/structure/disposalpipe/loafer/proc/finish_loaf(obj/structure/disposalholder/holder, obj/item/food/prison_loaf/loaf)
	is_loafing = FALSE
	update_icon()
	if(QDELETED(loaf))
		return
	loaf.condense()
	if(QDELETED(holder) || holder.loc != src)
		loaf.forceMove(drop_location())
		return
	loaf.forceMove(holder)
	LAZYADD(finished_holders, holder)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(forget_holder))

/// Holder przepłynął dalej albo zniknął
/obj/structure/disposalpipe/loafer/proc/forget_holder(obj/structure/disposalholder/holder)
	SIGNAL_HANDLER
	UnregisterSignal(holder, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(finished_holders, holder)

/obj/structure/disposalpipe/loafer/update_icon_state()
	icon_state = "loafer[is_loafing ? "-on" : ""]"
	return ..()

/obj/structure/disposalpipe/loafer/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	visible_message("<span class='warning'>Z [src] lecą iskry!</span>")
	if(user)
		balloon_alert(user, "limity bezpieczeństwa wyłączone")
		log_game("[key_name(user)] emagged [src] at [AREACOORD(src)]")
	return TRUE

/obj/structure/disposalpipe/loafer/emagged
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS | EMAGGED

// Konstrukcja z RPD ma ikonę z naszego pliku
/obj/structure/disposalconstruct/update_icon()
	. = ..()
	if(ispath(pipe_type, /obj/structure/disposalpipe/loafer))
		icon = 'aquila/icons/obj/monke/loaf.dmi'
	else
		icon = initial(icon)

// Podgląd w oknie RPD (spritesheet rur bierze tylko pliki z code/)
/datum/asset/spritesheet/pipes/register()
	for(var/direction in GLOB.alldirs)
		Insert("[dir2text(direction)]-conloafer", 'aquila/icons/obj/monke/loaf.dmi', "conloafer", direction)
	return ..()

// =====================================================
// Bochenek
// =====================================================

/obj/item/food/prison_loaf
	name = "bochenek więzienny"
	desc = "Ledwo jadalna cegła składników odżywczych, tanie rozwiązanie problemu niedożywienia."
	icon = 'aquila/icons/obj/monke/loaf.dmi'
	icon_state = "loaf"
	food_reagents = list(/datum/reagent/consumable/nutraslop = 10)
	max_volume = 200
	preserved_food = TRUE
	tastes = list("rozpaczy" = 1, "kleiku" = 1)
	foodtypes = GROSS
	/// Gęstość bochenka, od niej zależy stopień
	var/loaf_density = 1
	/// Czy da się go dalej prasować
	var/can_condense = TRUE
	var/critical = FALSE
	var/death_time
	var/obj/effect/countdown/loaf/countdown
	/// Czy następny dotknięty mob dostanie wstrząs grawitacyjny
	var/boing = FALSE

/obj/item/food/prison_loaf/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	return ..()

/obj/item/food/prison_loaf/process(delta_time)
	anomaly_effect()
	if(death_time < world.time)
		if(loc)
			detonate()
		qdel(src)

/obj/item/food/prison_loaf/proc/anomaly_effect()
	if(prob(LOAF_ANOMALY_MOVECHANCE))
		step(src, pick(GLOB.alldirs))
		boing = TRUE
	for(var/obj/object in orange(4, src))
		if(!object.anchored)
			step_towards(object, src)
	for(var/mob/living/M in range(0, src))
		grav_shock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M, src)
	for(var/obj/object in range(0, src))
		if(object.anchored || object == src)
			continue
		var/mob/living/target = locate() in view(4, src)
		if(target && !target.stat)
			object.throw_at(target, 5, 10)

/obj/item/food/prison_loaf/proc/detonate()
	var/turf/T = get_turf(src)
	log_game("[src] critical loaf ended its lifespan, turning into a singularity at [AREACOORD(T)].")
	message_admins("[src] (krytyczny bochenek) zamienia się w osobliwość w [ADMIN_VERBOSEJMP(T)].")
	new /obj/anomaly/singularity(T)

/obj/item/food/prison_loaf/Bump(atom/A)
	if(critical)
		grav_shock(A)
		return
	return ..()

/obj/item/food/prison_loaf/Bumped(atom/movable/AM)
	if(critical)
		grav_shock(AM)
		return
	return ..()

/obj/item/food/prison_loaf/proc/grav_shock(mob/living/A)
	if(!boing || !isliving(A) || A.stat)
		return
	A.Paralyze(4 SECONDS)
	var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
	A.throw_at(target, 5, 1)
	boing = FALSE

/obj/item/food/prison_loaf/proc/go_critical()
	critical = TRUE
	can_condense = FALSE
	var/turf/T = get_turf(src)
	notify_ghosts("[src] został sprasowany do stanu krytycznego!", source = src, action = NOTIFY_ORBIT, header = "Krytyczny bochenek!")
	log_game("[src] has been condensed to criticality at [AREACOORD(T)].")
	message_admins("[src] osiągnął stan krytyczny w [ADMIN_VERBOSEJMP(T)].")
	death_time = world.time + LOAF_CRITICAL_LIFESPAN
	countdown = new(src)
	countdown.color = COLOR_ASSEMBLY_LBLUE
	countdown.start()
	START_PROCESSING(SSobj, src)

/// Ustala stopień bochenka według gęstości
/obj/item/food/prison_loaf/proc/condense()
	if(!can_condense)
		return
	var/prefix = ""
	var/extra_desc = ""
	var/icon_level = 0
	var/power = 0
	var/new_range = initial(throw_range)
	var/salt = 1
	var/list/extra = list()
	switch(loaf_density)
		if(0 to 10)
			salt = 1
		if(10 to 100)
			prefix = "gęsty "
			extra_desc = "Ten bochenek jest wyraźnie cięższy niż zwykle."
			power = 2
			salt = 3
		if(100 to 250)
			prefix = "zbity "
			extra_desc = "Ojej, ten ma niezłe uderzenie. Co oni do tego dodają?"
			power = 4
			new_range = 6
			salt = 5
		if(250 to 500)
			prefix = "superskompresowany "
			extra_desc = "Twardy jak diament, a mimo to jadalny. Chyba emituje ciepło rozpadu."
			icon_level = 1
			power = 5
			new_range = 6
			salt = 8
		if(500 to 2500)
			prefix = "molekularny "
			extra_desc = "Bochenek jest tak gęsty, że gołym okiem nie widać w nim cząstek jedzenia."
			icon_level = 2
			power = 10
			new_range = 5
			salt = 10
			extra[/datum/reagent/consumable/corn_syrup] = 5
		if(2500 to 10000)
			prefix = "atomowy "
			extra_desc = "Cząstki jedzenia? Teraz to już atomy smaku."
			icon_level = 3
			power = 20
			new_range = 4
			salt = 10
			extra[/datum/reagent/growthserum] = 5
		if(10000 to 25000)
			prefix = "subatomowy "
			extra_desc = "Atomy smaku zapadły się w lity kawałek neutronów. Jedzenie tego może być niebezpieczne."
			icon_level = 4
			power = 30
			new_range = 3
			salt = 10
			extra[/datum/reagent/consumable/vitfro] = 25
		if(25000 to 50000)
			prefix = "kwarkowy "
			extra_desc = "Ten bochenek rozpada się na subatomowe cząstki smaku. Zjedzenie go może przerobić twoje DNA na syntetyczną maź."
			icon_level = 5
			power = 50
			new_range = 2
			salt = 10
			extra[/datum/reagent/mulligan] = 25
		if(50000 to LOAF_CRITICAL_DENSITY)
			prefix = "dziwnokwarkowy "
			extra_desc = "Czy człowiek nie posunął się za daleko? Czy jedzenie powinno mieć taką moc?"
			icon_level = 6
			power = 75
			new_range = 1
			salt = 10
			extra[/datum/reagent/nanomachines] = 50
		else
			prefix = "kwantowy "
			extra_desc = "Samo istnienie tego arcydzieła odżywczego zakrzywia rzeczywistość!"
			icon_level = 7
			power = 100
			new_range = 0
			salt = 10
			extra[/datum/reagent/gravitum] = 100
	name = "[prefix][initial(name)]"
	desc = extra_desc ? "[initial(desc)]\n[extra_desc]" : initial(desc)
	icon_state = "[initial(icon_state)][icon_level]"
	force = power
	throwforce = power
	throw_range = new_range
	reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, salt)
	reagents.add_reagent(/datum/reagent/consumable/nutraslop, salt)
	for(var/reagent_type in extra)
		reagents.add_reagent(reagent_type, extra[reagent_type])
	if(icon_level == 7)
		go_critical()

/obj/effect/countdown/loaf
	name = "odliczanie bochenka"

/obj/effect/countdown/loaf/get_value()
	var/obj/item/food/prison_loaf/loaf = attached_to
	if(!istype(loaf))
		return
	return round(max(0, (loaf.death_time - world.time) / 10))

/obj/item/food/prison_loaf/rod
	name = "bochenek z prętem"
	desc = "Jeśli coś kochasz, puść to wolno. Jeśli wróci, jest twoje."
	icon_state = "rod_loaf"
	can_condense = FALSE

/obj/item/food/prison_loaf/rod/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/turf/start_turf = get_turf(throwingdatum?.thrower || src)
	var/turf/end_turf = get_edge_target_turf(get_random_station_turf(), pick(GLOB.cardinals))
	var/obj/effect/immovablerod/loaf/rod = new(start_turf, end_turf)
	notify_ghosts("Ktoś rzucił [rod]!", source = rod, action = NOTIFY_ORBIT, header = "Coś ciekawego!")
	qdel(src)

/obj/effect/immovablerod/loaf
	name = "nieruchomy bochenek"
	desc = "O nie, smak leci prosto na nas!"
	icon = 'aquila/icons/obj/monke/loaf.dmi'
	icon_state = "rod_loaf"

/obj/machinery/power/supermatter_crystal/loaf
	name = "superbochenek"
	desc = "Bochenek więzienny sprasowany i skrystalizowany do tego stopnia, że da się go używać jako źródła zasilania."
	icon = 'aquila/icons/obj/monke/loaf.dmi'
	icon_state = "sm"

/datum/export/prison_loaf
	cost = 10
	unit_name = "bochenek"
	message = "bochenków więziennych"
	export_types = list(/obj/item/food/prison_loaf)

/datum/export/prison_loaf/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/obj/item/food/prison_loaf/loaf = O
	cost = max(10, loaf.loaf_density / 5)
	return ..()

// =====================================================
// Odczynniki
// =====================================================

/datum/reagent/consumable/nutraslop
	name = "Nutraslop"
	description = "Mieszanka różnych odpadków spożywczych i resztek."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#3E4A00"
	taste_description = "porażki"
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/gravitum
	name = "Gravitum"
	description = "Rzadki rodzaj zerowego płynu, który na chwilę odbiera ciężar wszystkiemu, czego dotknie."
	color = "#050096"
	taste_description = "powietrza"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/gravitum/on_mob_metabolize(mob/living/L)
	. = ..()
	L.AddElement(/datum/element/forced_gravity, 0)

/datum/reagent/gravitum/on_mob_end_metabolize(mob/living/L)
	L.RemoveElement(/datum/element/forced_gravity, 0)
	return ..()

#undef LOAF_ANOMALY_MOVECHANCE
#undef LOAF_CRITICAL_LIFESPAN
#undef LOAF_CRITICAL_DENSITY
