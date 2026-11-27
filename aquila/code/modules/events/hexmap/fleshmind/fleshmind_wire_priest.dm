// AQUILA - Umysł z ciała: kapłan przewodów, rola ducha roju. Duch najpierw jako niewidzialne oko wybiera miejsce rdzenia,
// potem rodzi się przy nim jako człowiek w szacie z laską i kieruje rozrostem (port z Bubberstation/Bubberstation
// modular_zubbers/code/game/gamemodes/fleshmind/wirepriest.dm, wirepriest_eye.dm, human_corruption_component.dm,
// fleshmind_generic_actions.dm i fleshmind_objects.dm)
// Changes against Bubberstation:
// - the eye is our /mob/camera (tg /mob/eye), the "place core" button is an action instead of a HUD screen object and it
//   only takes a free safe ship turf outside closed areas (and not next to the crew); after 3 minutes the core is
//   placed for the eye in the maintenance tunnels;
// - only the priest gets the corruption component: nobody else is converted (decision 2A), so no infected crew points
//   and no mechanical limb replacement; no darkvision tweak (our sight has no lighting cutoff colours);
// - welcome and objective in chat instead of the AntagInfoWirePriest window; the antagonist has its own ban key and
//   role preference, and its living hours requirement;
// - the structure menu lists only what the current level allows; texts are Polish.

/**
 * Oko kapłana: niewidzialna kamera, która szuka miejsca na rdzeń
 */
/mob/camera/fleshmind_eye
	name = "oko kapłana przewodów"
	real_name = "oko kapłana przewodów"
	desc = "Oko kapłana przewodów. Krąży po okręcie, zanim zstąpi."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_LIVING
	layer = FLY_LAYER
	faction = list(FACTION_FLESHMIND)
	sight = SEE_SELF|SEE_TURFS
	/// Timer, po którym oko samo stawia rdzeń
	var/autoplace_timer
	/// Rdzeń już postawiony
	var/placed = FALSE
	/// Akcja postawienia rdzenia
	var/datum/action/innate/fleshmind_place_core/place_action

/mob/camera/fleshmind_eye/Initialize(mapload)
	. = ..()
	place_action = new
	place_action.Grant(src)
	autoplace_timer = addtimer(CALLBACK(src, PROC_REF(force_place)), FLESHMIND_EYE_FORCE_SPAWN_TIME, TIMER_STOPPABLE)

/mob/camera/fleshmind_eye/Destroy()
	if(autoplace_timer)
		deltimer(autoplace_timer)
		autoplace_timer = null
	QDEL_NULL(place_action)
	return ..()

/mob/camera/fleshmind_eye/Login()
	. = ..()
	to_chat(src, "<span class='big bold' style='color:[FLESHMIND_LIGHT_BLUE]'>Jesteś okiem kapłana przewodów!</span>")
	to_chat(src, "<span class='notice'>Krążysz po okręcie jako niewidzialne oko. Znajdź ustronne miejsce i użyj akcji <b>Wykiełkuj rdzeń</b>. Rdzeń nie wyrośnie w kosmosie, w zamkniętych pomieszczeniach (bryg, mostek, maszynownia, rdzeń SI, podstacje, pokój FTL) ani obok załogi. Jeśli nie zdecydujesz się w ciągu [DisplayTimeText(FLESHMIND_EYE_FORCE_SPAWN_TIME)], rdzeń wyrośnie sam w tunelach technicznych.</span>")

/mob/camera/fleshmind_eye/Move(atom/newloc, direct)
	var/turf/new_turf = get_turf(newloc)
	if(placed || !new_turf || !is_station_level(new_turf.z) || isspaceturf(new_turf))
		return FALSE
	var/area/new_area = get_area(new_turf)
	if(!new_area || istype(new_area, /area/shuttle) || istype(new_area, /area/space))
		return FALSE
	forceMove(new_turf)
	return TRUE

/// Czy na tym polu może wykiełkować rdzeń: wolne, bezpieczne pole statku poza zamkniętymi obszarami, bez załogi w pobliżu (near_crew_check)
/proc/fleshmind_core_turf_ok(turf/T, near_crew_check = TRUE)
	if(!isturf(T) || isspaceturf(T) || isgroundlessturf(T))
		return FALSE
	var/area/turf_area = get_area(T)
	if(!turf_area || !(turf_area.type in GLOB.the_station_areas) || aquila_hex_closed_area_type(turf_area.type))
		return FALSE
	if(!aquila_hex_free_safe_turf(T))
		return FALSE
	if(near_crew_check)
		for(var/mob/living/someone in range(5, T))
			if(someone.client && !fleshmind_is_ally(someone))
				return FALSE
	return TRUE

/// Pole na rdzeń w tunelach technicznych (albo gdziekolwiek na statku), z dala od załogi, jeśli się da
/proc/fleshmind_find_core_turf()
	for(var/attempt in 1 to 15)
		var/turf/T = aquila_hex_maint_turf()
		if(fleshmind_core_turf_ok(T))
			return T
	for(var/attempt in 1 to 15)
		var/turf/T = aquila_hex_maint_turf()
		if(fleshmind_core_turf_ok(T, FALSE))
			return T
	return null

/// Rdzeń na polu spawn_turf, a kapłan (umysł oka) rodzi się obok; zwraca rdzeń albo null
/mob/camera/fleshmind_eye/proc/place_core(turf/spawn_turf, forced = FALSE)
	if(placed)
		return null
	if(!fleshmind_core_turf_ok(spawn_turf, !forced))
		if(!forced)
			to_chat(src, "<span class='warning'>Tu rdzeń nie wyrośnie. Szukaj wolnego pola okrętu poza zamkniętymi pomieszczeniami i z dala od załogi.</span>")
		return null
	placed = TRUE
	if(autoplace_timer)
		deltimer(autoplace_timer)
		autoplace_timer = null
	var/obj/structure/fleshmind/structure/core/new_core = new(spawn_turf)
	message_admins("Umysł z ciała: rdzeń wykiełkował w [ADMIN_VERBOSEJMP(spawn_turf)][forced ? " (sam, po czasie)" : ""].")
	log_game("Fleshmind core sprouted at [AREACOORD(spawn_turf)][forced ? " (forced)" : ""].")
	if(mind)
		var/turf/priest_turf = get_step(spawn_turf, pick(GLOB.cardinals))
		if(!aquila_hex_free_safe_turf(priest_turf))
			priest_turf = spawn_turf
		var/mob/living/carbon/human/priest = fleshmind_make_priest(priest_turf, mind, new_core.our_controller)
		if(priest)
			message_admins("[ADMIN_LOOKUPFLW(priest)] zostaje kapłanem przewodów.")
			log_game("[key_name(priest)] became a wire priest at [AREACOORD(priest_turf)].")
	qdel(src)
	return new_core

/// Po czasie rdzeń wyrasta sam
/mob/camera/fleshmind_eye/proc/force_place()
	autoplace_timer = null
	var/turf/spawn_turf = fleshmind_core_turf_ok(get_turf(src)) ? get_turf(src) : fleshmind_find_core_turf()
	if(!spawn_turf)
		to_chat(src, "<span class='warning'>Na okręcie nie ma miejsca na rdzeń.</span>")
		message_admins("Umysł z ciała: oko kapłana nie znalazło miejsca na rdzeń.")
		qdel(src)
		return
	place_core(spawn_turf, TRUE)

/datum/action/innate/fleshmind_place_core
	name = "Wykiełkuj rdzeń"
	desc = "Wyhoduj w tym miejscu jednostkę procesorową roju i zstąp przy niej w ciele kapłana przewodów."
	icon_icon = 'aquila/icons/fleshmind/fleshmind_machines.dmi'
	button_icon_state = "core"
	check_flags = NONE

/datum/action/innate/fleshmind_place_core/Activate()
	var/mob/camera/fleshmind_eye/eye = owner
	if(!istype(eye))
		return
	eye.place_core(get_turf(eye))

/// Robi kapłana przewodów z umysłem player_mind na polu spawn_turf, połączonego z kontrolerem
/proc/fleshmind_make_priest(turf/spawn_turf, datum/mind/player_mind, datum/fleshmind_controller/controller)
	if(!isturf(spawn_turf) || !player_mind)
		return null
	var/mob/living/carbon/human/priest = new(spawn_turf)
	var/datum/character_save/random_character = new
	random_character.copy_to(priest)
	priest.dna.update_dna_identity()
	player_mind.transfer_to(priest)
	priest.equipOutfit(/datum/outfit/fleshmind_wire_priest)
	player_mind.special_role = ROLE_WIRE_PRIEST
	var/datum/antagonist/fleshmind_wire_priest/priest_datum = new
	priest_datum.controller_ref = WEAKREF(controller)
	player_mind.add_antag_datum(priest_datum)
	priest.AddComponent(/datum/component/human_corruption, controller)
	return priest

/datum/antagonist/fleshmind_wire_priest
	name = "Kapłan przewodów"
	roundend_category = "kapłani przewodów"
	antagpanel_category = "Fleshmind"
	banning_key = ROLE_WIRE_PRIEST
	required_living_playtime = FLESHMIND_PRIEST_LIVING_HOURS
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// Kontroler roju, któremu służy
	var/datum/weakref/controller_ref

/datum/antagonist/fleshmind_wire_priest/on_gain()
	var/datum/objective/spread = new
	spread.owner = owner
	spread.explanation_text = "Szerz ciało: chroń jednostkę procesorową, rozrastaj przewody, stawiaj struktury i przejmuj maszyny okrętu."
	spread.completed = TRUE
	objectives += spread
	return ..()

/datum/antagonist/fleshmind_wire_priest/greet()
	to_chat(owner.current, "<span class='big bold' style='color:[FLESHMIND_LIGHT_BLUE]'>Jesteś kapłanem przewodów Umysłu z ciała!</span>")
	to_chat(owner.current, "<span class='notice'>Jesteś częścią roju: jego moby, struktury i maszyny to twoi sojusznicy i nie wolno ci ich atakować. Twoja jednostka procesorowa to serce roju. Gdy zginie, rój obumrze, a twoje implanty zawiodą.</span>")
	to_chat(owner.current, "<span class='notice'>Akcjami na pasku sadzisz przewody, stawiasz struktury, ściany i drzwi (stojąc na przewodach), wzywasz moby do siebie i rozmawiasz z rojem. Odgrywaj wyznawcę ciała. Twój główny cel to szerzenie ciała.</span>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('aquila/sound/fleshmind/ai/data_compromised.ogg'))

/datum/outfit/fleshmind_wire_priest
	name = "Kapłan przewodów"
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	belt = /obj/item/storage/belt/utility/full
	suit = /obj/item/clothing/suit/hooded/techpriest/fleshmind
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/fleshmind_wire_priest_staff

/obj/item/clothing/suit/hooded/techpriest/fleshmind
	name = "szata kapłana przewodów"
	desc = "Ciało nie dyskryminuje. Dołącz do ciała."
	icon = 'aquila/icons/fleshmind/fleshmind_clothing.dmi'
	worn_icon = 'aquila/icons/fleshmind/fleshmind_clothing_onmob.dmi'
	icon_state = "wirepriest"
	item_state = "wirepriest"
	hoodtype = /obj/item/clothing/head/hooded/techpriest/fleshmind
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 40, "rad" = 20, "fire" = 40, "acid" = 40, "stamina" = 20)

/obj/item/clothing/head/hooded/techpriest/fleshmind
	name = "kaptur kapłana przewodów"
	desc = "Ciało nie dyskryminuje. Dołącz do ciała."
	icon = 'aquila/icons/fleshmind/fleshmind_clothing.dmi'
	worn_icon = 'aquila/icons/fleshmind/fleshmind_clothing_onmob.dmi'
	icon_state = "wirepriesthood"
	item_state = "wirepriesthood"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 40, "rad" = 20, "fire" = 40, "acid" = 40, "stamina" = 20)
	flash_protect = 2

/// Laska kapłana: dłuższy zasięg, przyklejona do dłoni
/obj/item/fleshmind_wire_priest_staff
	name = "laska kapłana przewodów"
	desc = "Wielka drewniana laska owinięta przewodami. Przewody wiją się i oplatają ją bez przerwy. Dzięki długości sięga dalej niż większość broni."
	icon = 'aquila/icons/fleshmind/fleshmind_objects.dmi'
	icon_state = "wireprieststaff"
	item_state = "wireprieststaff"
	lefthand_file = 'aquila/icons/fleshmind/fleshmind_objects_onmob_l.dmi'
	righthand_file = 'aquila/icons/fleshmind/fleshmind_objects_onmob_r.dmi'
	force = 20
	throwforce = 7
	reach = 2
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("smaga", "chłoszcze", "uderza")

/obj/item/fleshmind_wire_priest_staff/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/**
 * Komponent kapłana: łączy go z rojem (frakcja, akcje, odporności, poświata) i kara po zniszczeniu rdzenia
 */
/datum/component/human_corruption
	/// Kontroler roju
	var/datum/fleshmind_controller/our_controller
	/// Przyznane akcje
	var/list/granted_actions = list()
	/// Cechy kapłana
	var/static/list/traits_to_give = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOHUNGER,
	)

/datum/component/human_corruption/Initialize(datum/fleshmind_controller/incoming_controller)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	our_controller = incoming_controller
	var/mob/living/carbon/human/infected_human = parent
	for(var/action_type in list(
		/datum/action/innate/fleshmind_create_structure,
		/datum/action/innate/fleshmind_create_structure/basic,
		/datum/action/innate/fleshmind_plant_weeds,
		/datum/action/innate/fleshmind_flesh_call,
		/datum/action/innate/fleshmind_flesh_chat,
	))
		var/datum/action/new_action = new action_type
		new_action.Grant(infected_human)
		granted_actions += new_action
	infected_human.add_faction(FACTION_FLESHMIND)
	for(var/trait in traits_to_give)
		ADD_TRAIT(infected_human, trait, "fleshmind")
	infected_human.add_filter("corruption_glow", 2, list("type" = "outline", "color" = FLESHMIND_LIGHT_BLUE, "size" = 2))
	infected_human.set_light(3, 1, FLESHMIND_LIGHT_BLUE)
	to_chat(infected_human, "<span class='hypnophrase'>Twój umysł jest spokojny. Twój umysł jest jednym z ciałem.</span>")

/datum/component/human_corruption/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(host_death))
	if(our_controller)
		RegisterSignal(our_controller, COMSIG_PARENT_QDELETING, PROC_REF(controller_deleted))
		if(our_controller.core)
			RegisterSignal(our_controller.core, COMSIG_PARENT_QDELETING, PROC_REF(core_death))

/datum/component/human_corruption/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_EMP_ACT, COMSIG_LIVING_DEATH))
	if(our_controller)
		UnregisterSignal(our_controller, COMSIG_PARENT_QDELETING)
		if(our_controller.core)
			UnregisterSignal(our_controller.core, COMSIG_PARENT_QDELETING)

/datum/component/human_corruption/Destroy(force, silent)
	QDEL_LIST(granted_actions)
	var/mob/living/carbon/human/parent_human = parent
	parent_human.remove_faction(FACTION_FLESHMIND)
	for(var/trait in traits_to_give)
		REMOVE_TRAIT(parent_human, trait, "fleshmind")
	parent_human.remove_filter("corruption_glow")
	parent_human.set_light(0)
	our_controller = null
	return ..()

/datum/component/human_corruption/proc/on_examine(atom/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<b>Oplatają to dziwne przewody!</b>"

/datum/component/human_corruption/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/parent_human = parent
	INVOKE_ASYNC(parent_human, TYPE_PROC_REF(/mob, emote), "scream")
	parent_human.Jitter(20)
	parent_human.Knockdown(1 SECONDS)
	to_chat(parent_human, "<span class='userdanger'>Twoje implanty zamarzają!</span>")

/datum/component/human_corruption/proc/host_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/human_corruption/proc/core_death(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/parent_human = parent
	if(source == our_controller?.core)
		UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	to_chat(parent_human, "<span class='userdanger'>Twój umysł krzyczy, gdy czujesz, jak umiera jednostka procesorowa! Twoje implanty zawodzą, gdy łącze z rojem zostaje zerwane!</span>")
	INVOKE_ASYNC(parent_human, TYPE_PROC_REF(/mob, emote), "scream")
	parent_human.adjustBruteLoss(rand(50, 75))
	parent_human.mind?.remove_antag_datum(/datum/antagonist/fleshmind_wire_priest)
	qdel(src)

/datum/component/human_corruption/proc/controller_deleted(datum/source)
	SIGNAL_HANDLER
	our_controller = null
	qdel(src)

/// Kontroler roju kapłana (null, gdy go nie ma)
/mob/living/proc/fleshmind_controller()
	var/datum/component/human_corruption/corruption = GetComponent(/datum/component/human_corruption)
	return corruption?.our_controller

/**
 * Akcje kapłana przewodów
 */
/datum/action/innate/fleshmind_create_structure
	name = "Zbuduj strukturę roju"
	desc = "Buduje wybraną strukturę roju tam, gdzie stoisz (na przewodach)."
	icon_icon = 'aquila/icons/fleshmind/fleshmind_machines.dmi'
	button_icon_state = "spawner"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	/// Odnowienie
	var/cooldown_time = 2 MINUTES
	COOLDOWN_DECLARE(use_cooldown)
	/// Struktury do wyboru
	var/list/possible_structures = list(
		/obj/structure/fleshmind/structure/babbler,
		/obj/structure/fleshmind/structure/whisperer,
		/obj/structure/fleshmind/structure/modulator,
		/obj/structure/fleshmind/structure/screamer,
		/obj/structure/fleshmind/structure/turret,
	)
	/// Czy to ściany i drzwi (nie liczą się do limitu struktur)
	var/is_wall = FALSE

/datum/action/innate/fleshmind_create_structure/Activate()
	var/mob/living/user = owner
	var/datum/fleshmind_controller/controller = user.fleshmind_controller()
	if(!controller?.core)
		to_chat(user, "<span class='warning'>Nie ma łącza z rojem, przez które popłynęłaby ta moc!</span>")
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, "<span class='warning'>Musisz jeszcze odczekać [DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))].</span>")
		return
	var/list/choices = list()
	for(var/obj/structure/fleshmind/structure/structure_type as anything in possible_structures)
		if(initial(structure_type.required_controller_level) > controller.level)
			continue
		choices[structure_type] = image(icon = initial(structure_type.icon), icon_state = initial(structure_type.icon_state))
	if(!length(choices))
		to_chat(user, "<span class='warning'>Twoja jednostka procesorowa jest jeszcze za słaba!</span>")
		return
	var/picked_type = show_radial_menu(user, user, choices, radius = 40, tooltips = TRUE)
	if(!picked_type || QDELETED(controller) || !controller.core || !COOLDOWN_FINISHED(src, use_cooldown))
		return
	var/turf/user_turf = get_turf(user)
	if(!(locate(/obj/structure/fleshmind/wireweed) in user_turf))
		to_chat(user, "<span class='warning'>Musisz stać na przewodach!</span>")
		return
	if(locate(/obj/structure/fleshmind/structure) in user_turf)
		to_chat(user, "<span class='warning'>Tu już coś stoi!</span>")
		return
	var/obj/built = is_wall ? controller.spawn_wall(user_turf, picked_type) : controller.spawn_structure(user_turf, picked_type)
	if(!built)
		to_chat(user, "<span class='warning'>Rój nie ma sił na kolejną strukturę!</span>")
		return
	COOLDOWN_START(src, use_cooldown, cooldown_time)

/datum/action/innate/fleshmind_create_structure/basic
	name = "Zbuduj ścianę albo drzwi"
	desc = "Buduje ścianę albo drzwi z przewodów tam, gdzie stoisz (na przewodach)."
	icon_icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	button_icon_state = "wireweed_wall"
	cooldown_time = 5 SECONDS
	is_wall = TRUE
	possible_structures = list(
		/obj/structure/fleshmind/structure/wireweed_door,
		/obj/structure/fleshmind/structure/wireweed_wall,
	)

/datum/action/innate/fleshmind_plant_weeds
	name = "Posadź przewody"
	desc = "Sadzi kawałek przewodów tam, gdzie stoisz (w zasięgu rdzenia)."
	icon_icon = 'aquila/icons/fleshmind/wireweed_floor.dmi'
	button_icon_state = "wires-0"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(use_cooldown)

/datum/action/innate/fleshmind_plant_weeds/Activate()
	var/mob/living/user = owner
	var/datum/fleshmind_controller/controller = user.fleshmind_controller()
	if(!controller?.core)
		to_chat(user, "<span class='warning'>Nie ma łącza z rojem, przez które popłynęłaby ta moc!</span>")
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, "<span class='warning'>Musisz jeszcze odczekać [DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))].</span>")
		return
	var/turf/user_turf = get_turf(user)
	if(locate(/obj/structure/fleshmind/wireweed) in user_turf)
		to_chat(user, "<span class='warning'>Pod tobą już są przewody!</span>")
		return
	if(length(controller.controlled_wireweed) >= controller.max_wireweed || !fleshmind_can_plant(controller, user_turf))
		to_chat(user, "<span class='warning'>Tu przewody nie wyrosną!</span>")
		return
	controller.spawn_wireweed(user_turf)
	to_chat(user, "<span class='green'>Przewody posadzone!</span>")
	COOLDOWN_START(src, use_cooldown, 10 SECONDS)

/// Czy kapłan może posadzić przewody na swoim polu (jak rozrost, ale on sam na nim stoi)
/proc/fleshmind_can_plant(datum/fleshmind_controller/controller, turf/target)
	if(!isopenturf(target) || isspaceturf(target) || isgroundlessturf(target) || !controller.core || target.z != controller.core.z)
		return FALSE
	if(get_dist(controller.core, target) > controller.max_radius)
		return FALSE
	var/area/target_area = get_area(target)
	if(!target_area || !(target_area.type in GLOB.the_station_areas) || aquila_hex_closed_area_type(target_area.type))
		return FALSE
	return !(locate(/obj/machinery/door) in target)

/datum/action/innate/fleshmind_flesh_call
	name = "Wezwij posiłki"
	desc = "Wzywa do ciebie moby roju w zasięgu wzroku."
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "bio"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(use_cooldown)

/datum/action/innate/fleshmind_flesh_call/Activate()
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(owner, "<span class='warning'>Musisz jeszcze odczekać [DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))].</span>")
		return
	for(var/mob/living/basic/fleshmind/iterating_mob in view(FLESHMIND_VIEW_RANGE, owner))
		if(!iterating_mob.key && iterating_mob.ai_controller)
			iterating_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, get_turf(owner))
	owner.visible_message("<span class='warning'>[owner] wydaje okropny wrzask!</span>", "<span class='notice'>Wydajesz wzywający wrzask!</span>")
	playsound(owner, 'sound/hallucinations/wail.ogg', 100, TRUE)
	COOLDOWN_START(src, use_cooldown, 2 MINUTES)

/datum/action/innate/fleshmind_flesh_chat
	name = "Czat roju"
	desc = "Wysyła wiadomość do wszystkich świadomych członków roju."
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "hivemind_link"
	background_icon_state = "bg_alien"
	check_flags = NONE

/datum/action/innate/fleshmind_flesh_chat/Activate()
	var/message = stripped_input(owner, "Wiadomość do roju.", "Czat roju")
	if(!message || QDELETED(owner))
		return
	var/full_message = "<span class='purple'><b>UMYSŁ Z CIAŁA ([owner.real_name]):</b> [message]</span>"
	for(var/mob/iterating_mob in GLOB.player_list)
		if(isobserver(iterating_mob) || (FACTION_FLESHMIND in iterating_mob.faction))
			to_chat(iterating_mob, full_message)
	owner.log_talk(message, LOG_SAY, tag = "fleshmind")
