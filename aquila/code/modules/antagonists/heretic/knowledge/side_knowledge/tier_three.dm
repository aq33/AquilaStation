/*!
 * Tier 3 knowledge: Summons
 */

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "Przywołaj Rust Walkera.<br>\
		Rust Walkery świetnie rozsiewają rdzę i są dość silne w walce."
	transmute_text = "Transmutuj kałużę wymiocin, 15 odcinków kabla i 10 arkuszy żelaza."
	gain_text = "Połączyłem swoją wiedzę o tworzeniu z żądzą zepsucia. Marszałek znał moje imię, a Rdzawe Wzgórza odpowiedziały echem."
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_walker
	cost = 2
	poll_ignore_define = POLL_IGNORE_RUST_SPIRIT
	drafting_tier = 3

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Przywołaj Maid in the Mirror.<br>\
		Pokojówki w Lustrze to przyzwoici wojownicy, którzy stają się bezcieleśni, wchodząc i wychodząc ze świata luster - \
		świetni zwiadowcy i zabójcy z zasadzki. Ich ataki nakładają też ładunek chłodu pustki."
	transmute_text = "Transmutuj pięć arkuszy szkła, dowolny strój wierzchni i parę płuc."
	gain_text = "W każdym odbiciu kryje się brama do niewyobrażalnego świata kolorów, których nigdy nie widziano, \
		i ludzi, których nigdy nie spotkano. Wspinaczka jest ze szkła, a ściany są z noży. Każdy krok to krew, jeśli nie masz przewodnika."

	required_atoms = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
	poll_ignore_define = POLL_IGNORE_MAID_IN_MIRROR
	drafting_tier = 3

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Przywołaj Ash Spirit.<br>\
		Duchy Popiołu mają krótkie przenikanie i potrafią z dystansu wywołać krwawienie u wrogów. \
		Mogą też na jakiś czas otoczyć się pierścieniem ognia.<br>\
		Mają mało zdrowia, ale z czasem same się leczą."
	transmute_text = "Transmutuj kupkę popiołu, książkę i ognisko."
	gain_text = "Połączyłem swoją zasadę głodu z żądzą zniszczenia. Marszałek znał moje imię, a Nocny Strażnik patrzył."
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/book = 1,
		/obj/structure/bonfire = 1,
		)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	cost = 2

	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT
	drafting_tier = 3

/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Ritual"
	desc = "Zaklnij zwłoki w Shattered Risen.<br>\
		Roztrzaskani Powstali to silne ghule ze 125 punktami zdrowia, które nie mogą trzymać przedmiotów - \
		zamiast dłoni mają dwie brutalne bronie. Naraz możesz mieć tylko jednego."
	transmute_text = "Transmutuj zwłoki z duszą, dowolny strój wierzchni i parę rękawiczek lateksowych."
	gain_text = "Widziałem, jak zimna, rozdzierająca siła przywraca te zwłoki do niemal-życia. \
		Gdy się rusza, chrzęści jak tłuczone szkło. Jego dłonie nie przypominają już ludzkich - \
		każda zaciśnięta pięść kryje brutalne gniazdo ostrych odłamków kości."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)
	limit = 1
	cost = 2
	research_tree_icon_path = 'aquila/icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"
	drafting_tier = 3

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("Z [body] nie da się zrobić ghula."))
			continue
		if(!body.mind)
			to_chat(user, span_hierophant_warning("[body] nie ma umysłu i nie może zostać ghulem."))
			continue
		if(!body.client && !body.mind.get_ghost(ghosts_with_clients = TRUE))
			to_chat(user, span_hierophant_warning("[body] nie ma duszy i nie może zostać ghulem."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "rytuał nieudany, brak ciała!")
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "rytuał nieudany, brak ciała!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "rytuał nieudany, brak ciała!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a shattered risen out of [key_name(victim)].", LOG_GAME)
	victim.log_message("became a shattered risen of [key_name(user)]'s.", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)

/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, /obj/item/mutant_hand/shattered_risen)

/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "bone-shards"
	desc = "To, co kiedyś wyglądało na zwykłą ludzką pięść, teraz kryje zmasakrowane gniazdo ostrych odłamków kości."
	color = "#001aff"
	hitsound = "shatter"
	force = 16
	armour_penetration = 15
	sharpness = SHARP_EDGED
	attack_verb = list("tnie", "rozrywa", "siecze", "kaleczy")

/datum/heretic_knowledge/summon/fire_shark
	name = "Scorching Shark"
	desc = "Przywołaj Fire Sharka.<br>\
		Ogniste Rekiny są szybkie i groźne w stadzie, ale wrażliwe na obrażenia inne niż od ognia.<br>\
		Przy ataku wstrzykują flogiston, a po śmierci uwalniają plazmę."
	transmute_text = "Transmutuj kupkę popiołu, wątrobę i arkusz plazmy."
	gain_text = "Kołyska mgławicy była zimna, ale nie martwa. Światło i ciepło przemykają nawet przez najgłębszą ciemność, a polują na nie ich własni drapieżcy."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/fire_shark
	cost = 2

	poll_ignore_define = POLL_IGNORE_FIRE_SHARK

	research_tree_icon_dir = EAST
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	desc = "Stwórz Maskę Szaleństwa.<br>\
		Maska napawa grozą pogan, którzy ją widzą - wysysa im wytrzymałość, wywołuje halucynacje i szaleństwo.<br>\
		Można ją też wcisnąć na twarz poganina, który nie zdoła jej zdjąć..."
	transmute_text = "Transmutuj dowolną maskę, cztery zapalone świece, pałkę ogłuszającą i wątrobę."
	gain_text = "Straż nosiła na służbie dziwne stroje. Dzięki nim mogła chodzić po mieście, pozornie niezauważona przez tłumy."
	required_atoms = list(
		/obj/item/organ/liver = 1,
		/obj/item/melee/baton = 1,  // Technically means a cattleprod is valid
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle

/datum/heretic_knowledge/mad_mask/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	if(istype(what, /obj/item/candle))
		var/obj/item/candle/candle = what
		candle.light()

/datum/heretic_knowledge/mansus_gate
	name = "Keys to the Backdoor"
	desc = "Otwórz tylne drzwi do Mansusa.<br>\
		Wejście do szafki przeniesie cię do Mansusa - bezpiecznej przystani, gdzie możesz transmutować albo przechowywać sprzęt."
	transmute_text = "Transmutuj szafkę i Codex Cicatrix albo Codex Morbus."
	notice = "Przez tylne drzwi przejdą tylko chętni albo zmarli.\
		<br>Próba złożenia ofiary tak blisko bogów może ich rozgniewać.\
		<br>Możesz stworzyć tylko jedne tylne drzwi."
	gain_text = "Każda domena jest tak bezpieczna, jak jej najsłabszy punkt. \
		Codex mówi o tylnych drzwiach do Mansusa - bramach na lichych łańcuchach, drzwiach z kruchymi zamkami, klapach na zardzewiałych zawiasach. \
		Właściwym kluczem z łatwością mogę je wykorzystać."
	required_atoms = list(
		/obj/structure/closet = 1,
		list(/obj/item/codex_cicatrix, /obj/item/codex_cicatrix/morbus) = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "anom"
	drafting_tier = 3
	is_shop_only = TRUE
	VAR_PRIVATE/used = FALSE
	/// AQUILA - połączone szafki (u nas nie ma closet_teleport_controller z tg)
	var/list/obj/structure/closet/linked_lockers = list()
	/// Zabezpieczenie przed odbijaniem się przedmiotu między szafkami
	var/teleporting = FALSE

/datum/heretic_knowledge/mansus_gate/can_be_invoked(datum/antagonist/heretic/invoker)
	return !used

/datum/heretic_knowledge/mansus_gate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/structure/closet/locker = locate() in selected_atoms
	if(isnull(locker))
		stack_trace("Locker not found in selected atoms for mansus gate recipe!")
		return FALSE

	used = TRUE
	INVOKE_ASYNC(src, PROC_REF(setup_link), locker)
	return TRUE

/datum/heretic_knowledge/mansus_gate/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/locker in selected_atoms)
		selected_atoms -= locker
	return ..()

/datum/heretic_knowledge/mansus_gate/proc/setup_link(obj/structure/closet/locker)
	var/datum/map_template/masus_backdoor/backdoor = new()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(backdoor.width, backdoor.height, turf_type_override = /turf/open/indestructible)
	if(!reservation)
		used = FALSE
		CRASH("[type] could not reserve space for the mansus backdoor!")
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	backdoor.load(bottom_left)
	var/obj/structure/closet/new_link = locate() in backdoor.created_atoms
	if(isnull(new_link))
		used = FALSE
		CRASH("[type] loaded the mansus backdoor without a closet in it!")
	new_link.resistance_flags |= INDESTRUCTIBLE
	new_link.anchored = TRUE
	new_link.anchorable = FALSE
	new_link.can_weld_shut = FALSE
	locker.resistance_flags |= INDESTRUCTIBLE
	link_lockers(locker, new_link)

/// AQUILA - łączy dwie szafki: co do jednej wejdzie, ląduje w drugiej
/datum/heretic_knowledge/mansus_gate/proc/link_lockers(obj/structure/closet/first, obj/structure/closet/second)
	linked_lockers = list(first, second)
	for(var/obj/structure/closet/locker as anything in linked_lockers)
		RegisterSignal(locker, COMSIG_ATOM_ENTERED, PROC_REF(on_locker_entered))
		RegisterSignal(locker, COMSIG_PARENT_QDELETING, PROC_REF(on_locker_deleted))

/datum/heretic_knowledge/mansus_gate/proc/on_locker_deleted(obj/structure/closet/source)
	SIGNAL_HANDLER
	for(var/obj/structure/closet/locker as anything in linked_lockers)
		UnregisterSignal(locker, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_QDELETING))
	linked_lockers = list()

/// Coś weszło do jednej z szafek - przenosimy to do drugiej
/datum/heretic_knowledge/mansus_gate/proc/on_locker_entered(obj/structure/closet/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	if(teleporting || length(linked_lockers) < 2 || old_loc == source)
		return
	var/obj/structure/closet/destination = linked_lockers[linked_lockers[1] == source ? 2 : 1]
	if(QDELETED(destination))
		return
	if(closet_teleport_logic(source, arrived) & CLOSET_TELEPORT_BLOCKED)
		// Drzwi nie wpuszczają - wyrzucamy z powrotem
		addtimer(CALLBACK(arrived, TYPE_PROC_REF(/atom/movable, forceMove), source.drop_location()), 0)
		return
	teleporting = TRUE
	arrived.forceMove(destination)
	teleporting = FALSE

/datum/heretic_knowledge/mansus_gate/proc/closet_teleport_logic(obj/structure/closet/locker, atom/movable/sending_through)
	if(!is_station_level(locker.z))
		return CLOSET_TELEPORT_FORCED

	if(isliving(sending_through) && !consents_to_entry(sending_through))
		locker.balloon_alert(sending_through, "drzwi cię nie wpuszczają!")
		return CLOSET_TELEPORT_BLOCKED

	for(var/mob/living/entering in sending_through.GetAllContents())
		if(!consents_to_entry(entering))
			if(isliving(sending_through))
				locker.balloon_alert(sending_through, "drzwi cię nie wpuszczają!")
			return CLOSET_TELEPORT_BLOCKED

	return CLOSET_TELEPORT_FORCED

/datum/heretic_knowledge/mansus_gate/proc/consents_to_entry(mob/living/entering)
	if(IS_HERETIC_OR_MONSTER(entering))
		return TRUE
	if(entering.stat == DEAD)
		return TRUE
	if(!entering.incapacitated(ignore_restraints = TRUE, ignore_grab = TRUE))
		return TRUE
	return FALSE

/datum/map_template/masus_backdoor
	name = "The Mansus"
	mappath = 'aquila/_maps/templates/mansus_backdoor.dmm'
	width = 59
	height = 51
	returns_created_atoms = TRUE

/area/centcom/heretic_backdoor
	name = "Mansus"
	icon_state = "heretic"
	requires_power = TRUE
	always_unpowered = TRUE
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	teleport_restriction = TELEPORT_ALLOW_NONE
	area_flags = HIDDEN_AREA | BLOCK_SUICIDE | UNIQUE_AREA
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/centcom/heretic_backdoor/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(isliving(arrived))
		var/mob/living/arrived_mob = arrived
		arrived_mob.add_movespeed_modifier(MOVESPEED_ID_HERETIC_BACKDOOR, update = TRUE, priority = 100, multiplicative_slowdown = 0.5)
		arrived_mob.adjust_temp_blindness(1 SECONDS)
		arrived_mob.adjust_eye_blur(2 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(greet_message), arrived_mob), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		if(!IS_HERETIC_OR_MONSTER(arrived_mob))
			arrived_mob.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING)

/area/centcom/heretic_backdoor/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/gone_mob = gone
		gone_mob.remove_movespeed_modifier(MOVESPEED_ID_HERETIC_BACKDOOR)
		gone_mob.remove_status_effect(/datum/status_effect/necropolis_curse)
		gone_mob.adjust_temp_blindness(1 SECONDS)
		gone_mob.adjust_eye_blur(2 SECONDS)

/area/centcom/heretic_backdoor/proc/greet_message(mob/living/arrived_mob)
	if(QDELETED(arrived_mob) || get_area(arrived_mob) != src)
		return
	to_chat(arrived_mob, span_mansus("Z góry świeci puste słońce."))
