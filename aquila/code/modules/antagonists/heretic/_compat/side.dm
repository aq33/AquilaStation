// AQUILA - zgodność dla wiedzy pobocznej heretyka (agent "side"): brakujące u nas typy i procedury z tg.

/// tg: odświeża przycisk akcji po sygnale (np. ruchu), żeby pokazać, czy da się jej teraz użyć
/datum/action/proc/update_status_on_signal(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	UpdateButtonIcon(TRUE)

/// tg: imiona dla Maid in the Mirror (strings/names/mirror_maid.txt)
GLOBAL_LIST_INIT(mirror_maid_names, list(
	"Margaret", "Mary", "Joan", "Joyce", "Dorothy", "Kathleen", "Doris", "Irene", "Elizabeth", "Eileen",
	"Betty", "Jean", "Marjorie", "Gladys", "Doreen", "Vera", "Elsie", "Barbara", "Winifred", "Edna",
	"Audrey", "Edith", "Florence", "Phyllis", "Lilian", "Hilda", "Olive", "Annie", "Violet", "Alice",
	"Patricia", "Ivy", "Muriel", "Iris", "Evelyn", "Peggy", "Catherine", "Ethel", "Beryl", "Gwendoline",
	"Ellen", "Sylvia", "Sheila", "Rose", "Constance", "Frances", "Lily", "Freda", "Marion", "Nancy",
	"Grace", "Beatrice", "Sarah", "Agnes", "Ruth", "May", "Nora", "Brenda", "Jessie", "Pamela",
	"Anne", "Helen", "Marie", "Mabel", "Eva", "Maria", "Ruby", "Nellie", "Hazel", "Emily",
	"Josephine", "Daphne", "Jane", "Ada", "Pauline", "Ann", "Enid", "Gertrude", "Rita", "June",
	"Stella", "Norah", "Mavis", "Thelma", "Mildred", "Bridget", "Monica", "Daisy", "Eleanor", "Lillian",
	"Alma", "Lucy", "Dora", "Christine", "Maureen", "Janet", "Rosemary", "Hannah", "Sybil", "Amy",
))

/// tg: fioletowe iskry (kult/heretyk)
/obj/effect/temp_visual/eldritch_sparks
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"

// --- Eldritch Coin (tg: code/modules/mining/ores_coins.dm)

/obj/item/coin/eldritch
	name = "eldritch coin"
	desc = "Zaskakująco ciężka, zdobiona moneta. Za każdym razem, gdy na nią patrzysz, jej boki przedstawiają coś innego."
	icon = 'aquila/icons/obj/eldritch_coin.dmi'
	icon_state = "coin_heretic"
	cmineral = "heretic"
	sideslist = list("heretic", "blade")
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT * 0.5)
	grind_results = list(/datum/reagent/carbon = 5, /datum/reagent/toxin/plasma = 5, /datum/reagent/eldritch = 4)
	value = 0
	/// Nazwa strony "orzeł"
	var/heads_name = "heretic"
	/// Zasięg działania na śluzy
	var/airlock_range = 5

/obj/item/coin/eldritch/attack_self(mob/user)
	if(cooldown >= world.time)
		return FALSE
	if(string_attached)
		to_chat(user, span_warning("Moneta nie podrzuci się dobrze z czymś przywiązanym!"))
		return FALSE
	cooldown = world.time + 1.5 SECONDS
	flick("coin_[coinflip || heads_name]_flip", src)
	coinflip = pick(sideslist)
	icon_state = "coin_[coinflip]"
	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)
	var/oldloc = loc
	sleep(1.5 SECONDS)
	if(loc == oldloc && user && !user.incapacitated())
		user.visible_message(
			span_notice("[user] podrzuca [src]. Wypada: [coinflip]."),
			span_notice("Podrzucasz [src]. Wypada: [coinflip]."),
			span_italics("Słyszysz brzęk drobnych."),
		)
	if(coinflip == heads_name)
		heads_action(user)
	else
		tails_action(user)
	return TRUE

/// Orzeł: pobliskie śluzy się otwierają albo zamykają
/obj/item/coin/eldritch/proc/heads_action(mob/user)
	var/mob/living/living_user = user
	if(!IS_HERETIC(user))
		living_user.adjust_brute_loss(5)
		return
	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.density)
			INVOKE_ASYNC(target_airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
			continue
		INVOKE_ASYNC(target_airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, close), TRUE)

/// Reszka: pobliskie śluzy się ryglują albo odryglowują
/obj/item/coin/eldritch/proc/tails_action(mob/user)
	var/mob/living/living_user = user
	if(!IS_HERETIC(user))
		living_user.adjust_fire_loss(5)
		return
	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.locked)
			target_airlock.unbolt()
			continue
		target_airlock.bolt()

// AQUILA - opis wiedzy obiecuje wrzucenie monety do śluzy (w tg niezrobione): moneta przepada,
// a elektronika śluzy się przepala - śluza zostaje zaryglowana w obecnym stanie, dopóki ktoś nie naprawi przewodu rygli.
/obj/item/coin/eldritch/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target, /obj/machinery/door/airlock) || !IS_HERETIC(user))
		return
	var/obj/machinery/door/airlock/airlock = target
	airlock.bolt()
	airlock.wires?.cut(WIRE_BOLTS)
	do_sparks(5, TRUE, airlock)
	new /obj/effect/temp_visual/eldritch_sparks(get_turf(airlock))
	airlock.visible_message(span_warning("[user] wciska [src] w szczelinę [airlock]. Elektronika śluzy skwierczy i dymi!"))
	playsound(airlock, 'sound/magic/magic_missile.ogg', 40, TRUE)
	qdel(src)

// --- Zabawkowy Codex Cicatrix (tg: code/game/objects/items/toys.dm)

/obj/item/toy/eldritch_book
	name = "Codex Cicatrix"
	desc = "Zabawkowa księga łudząco podobna do Codex Cicatrix. Obita sztuczną, poliestrową ludzką skórą, z wielkim ruchomym okiem na okładce. Runy to bełkot i nie da się nimi przywołać demonów... Chyba?"
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("składa w ofierze", "transmutuje", "chwyta", "przeklina")
	/// Czy księga jest otwarta
	var/book_open = FALSE
	/// Timer zamknięcia
	var/timer_id

/obj/item/toy/eldritch_book/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(book_open)
		close_animation()
	else
		open_animation()

/obj/item/toy/eldritch_book/proc/open_animation()
	icon_state = "book_open"
	flick("book_opening", src)
	book_open = TRUE
	timer_id = addtimer(CALLBACK(src, PROC_REF(close_animation)), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/obj/item/toy/eldritch_book/proc/close_animation()
	icon_state = "book"
	flick("book_closing", src)
	book_open = FALSE
	deltimer(timer_id)

// --- Miraculous Mirror (tg: code/game/objects/structures/mirror.dm)

/obj/item/wallframe/mirror
	name = "mirror"
	desc = "Niezawieszone lustro. Przyłóż je do ściany, by go używać."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT * 5, /datum/material/silver = MINERAL_MATERIAL_AMOUNT * 2)
	result_path = /obj/structure/mirror
	pixel_shift = 28

/obj/item/wallframe/mirror/heretic
	name = "miraculous mirror"
	desc = "Patrząc na swoje odbicie, czujesz, że mógłbyś być kimś lepszym."
	icon_state = "magic_mirror"
	materials = list()
	result_path = /obj/structure/mirror/magic/lesser/heretic

/obj/structure/mirror/magic/lesser/heretic
	name = "miraculous mirror"
	desc = "Patrząc na swoje odbicie, czujesz, że mógłbyś być kimś lepszym."

// Heretyk zmienia się dowolnie (zmiana gatunku rozbija lustro), reszta wpada w trans i lustro zmienia ją losowo
/obj/structure/mirror/magic/lesser/heretic/attack_hand(mob/user, list/modifiers)
	if(broken || !ishuman(user) || !Adjacent(user))
		return ..()
	var/mob/living/carbon/human/human_user = user
	if(!IS_HERETIC(human_user))
		to_chat(human_user, span_hypnophrase("Wpatrujesz się w [src] i nie potrafisz oderwać wzroku..."))
		human_user.Immobilize(5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(change_something), human_user, pick("hair", "race", "gender", "eyes")), 5 SECONDS)
		return TRUE
	var/old_species = human_user.dna?.species?.type
	. = ..()
	if(human_user.dna?.species?.type != old_species)
		obj_break()

/obj/structure/mirror/magic/lesser/heretic/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/shard(loc) // ramy nigdy nie oddaje
	qdel(src)

/obj/structure/mirror/magic/lesser/heretic/welder_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("Nie masz pojęcia, od czego w ogóle zacząć naprawę [src]."))
	return TRUE

/// Losowo zmienia coś w wyglądzie zahipnotyzowanego (DNA bez zmian, genetyka to odkręci)
/obj/structure/mirror/magic/lesser/heretic/proc/change_something(mob/living/carbon/human/user, picked)
	if(QDELETED(src) || QDELETED(user))
		return
	if(!user.Adjacent(src))
		to_chat(user, span_warning("Odciągnięty od [src], otrząsasz się z transu."))
		return
	if(broken)
		to_chat(user, span_warning("Gdy [src] pęka, otrząsasz się z transu."))
		return

	switch(picked)
		if("hair")
			to_chat(user, span_hypnophrase("Włosy - tak, włosy są złe - [pick("można je poprawić", "trzeba je zmienić", "muszą być inne")]..."))
			user.hair_style = random_hair_style(user.gender)
			user.facial_hair_style = random_facial_hair_style(user.gender)
			user.update_hair()
		if("race")
			to_chat(user, span_hypnophrase("Ciało - nie, ciało jest całe złe - [pick("muszę narodzić się na nowo", "muszę być kimś innym", "chcę być czymś innym")]..."))
			var/list/options = list()
			for(var/species_id in choosable_races)
				var/datum/species/species_type = GLOB.species_list[species_id]
				if(species_type && species_type != user.dna.species.type)
					options += species_type
			if(length(options))
				user.set_species(pick(options), icon_update = FALSE)
				user.update_body()
				user.update_hair()
				user.update_body_parts(TRUE)
				obj_break()
		if("gender")
			to_chat(user, span_hypnophrase("Moja postać - tak, postać jest zła - muszę ją zmienić..."))
			user.gender = (user.gender == MALE) ? FEMALE : MALE
			user.dna?.update_ui_block(DNA_GENDER_BLOCK)
			user.update_body()
		if("eyes")
			to_chat(user, span_hypnophrase("Moje oczy - nie widzę wyraźnie - [pick("po prostu są nie takie", "trzeba je wymienić", "oba są złe")]..."))
			user.eye_color = random_eye_color()
			user.dna?.update_ui_block(DNA_EYE_COLOR_BLOCK)
			user.update_body()

// --- Nastroje od obrazów (tg: code/datums/mood_events/eldritch_painting_events.dm)

/// Za zdjęcie obrazu
/datum/mood_event/eldritch_painting
	description = "<span class='warning'>Odkąd zdjąłem ten obraz, słyszę dziwny śmiech...</span>\n"
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "<span class='warning'>On tu jest!</span>\n"
	mood_change = -3
	timeout = 11 SECONDS

/datum/mood_event/eldritch_painting/weeping_heretic
	description = "<span class='nicegreen'>Jego cierpienie mnie inspiruje!</span>\n"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping_withdrawal
	description = "<span class='nicegreen'>Mój umysł jest czysty. Jego tu nie ma.</span>\n"
	mood_change = 1
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_heretic
	description = "<span class='warning'>Pustka krzyczy.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/desire_examine
	description = "<span class='nicegreen'>Głód został na razie zaspokojony...</span>\n"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/heretic_vines
	description = "<span class='nicegreen'>Och, co za śliczny kwiat!</span>\n"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_examine
	description = "<span class='warning'>Ten obraz naprawdę mnie przeraził.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_heretic_examine
	description = "<span class='nicegreen'>Wspinaj się. Rozkładaj. Rdzewiej.</span>\n"
	mood_change = 6
	timeout = 3 MINUTES

// --- Keys to the Backdoor (tier 3)

#define MOVESPEED_ID_HERETIC_BACKDOOR "heretic_backdoor_slowdown"

/// tg: teleport o przesunięcie względem siebie (zapętlona łąka w Mansusie)
/obj/effect/step_trigger/teleporter/offset
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0

/obj/effect/step_trigger/teleporter/offset/on_entered(datum/source, atom/movable/entered, atom/old_loc)
	if(!old_loc?.Adjacent(loc)) // prevents looping, if we were teleported into this then the old loc is usually not adjacent
		return
	return ..()

/obj/effect/step_trigger/teleporter/offset/Trigger(atom/movable/poor_soul)
	var/turf/destination = locate(x + teleport_x_offset, y + teleport_y_offset, z)
	if(!destination)
		return
	poor_soul.forceMove(destination)
	var/mob/living/living_soul = poor_soul
	if(istype(living_soul) && living_soul.client)
		living_soul.client.move_delay = 0

// --- Mutant hands (tg: code/datums/components/mutant_hands.dm)

/**
 * ## Mutant hands component
 *
 * This component applies to humans, and forces them to hold
 * a certain typepath item in every hand no matter what*.
 */
/datum/component/mutant_hands
	// First come, first serve
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The item typepath that we insert into the parent's hands
	var/obj/item/mutant_hand_path = /obj/item/mutant_hand

/datum/component/mutant_hands/Initialize(obj/item/mutant_hand_path = /obj/item/mutant_hand)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	src.mutant_hand_path = mutant_hand_path

/datum/component/mutant_hands/RegisterWithParent()
	// Give them a hand before registering ANYTHING just so it's clean
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

	RegisterSignal(parent, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(mob_equipped_item))
	RegisterSignal(parent, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(mob_dropped_item))

/datum/component/mutant_hands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_UNEQUIPPED_ITEM,
	))

	// Remove all their hands after unregistering everything so they don't return
	INVOKE_ASYNC(src, PROC_REF(remove_mutant_hands))

/// Daje rodzicowi zmutowane dłonie we wszystkie wolne ręce (przedmioty bez NODROP lądują na ziemi)
/datum/component/mutant_hands/proc/apply_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot as anything in human_parent.held_items)
		// This slot is already a mutant hand
		if(istype(hand_slot, mutant_hand_path))
			continue
		if(!isnull(hand_slot))
			if(HAS_TRAIT(hand_slot, TRAIT_NODROP) || (hand_slot.item_flags & ABSTRACT))
				continue
			// Drop any existing non-nodrop items to the ground
			human_parent.dropItemToGround(hand_slot)

		// Put in hands has a sleep somewhere in there
		human_parent.put_in_hands(new mutant_hand_path(), del_on_fail = TRUE)

/// Zabiera wszystkie zmutowane dłonie
/datum/component/mutant_hands/proc/remove_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot in human_parent.held_items)
		if(istype(hand_slot, mutant_hand_path))
			qdel(hand_slot)

/datum/component/mutant_hands/proc/mob_equipped_item(mob/living/carbon/human/source, obj/item/thing, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS)) // Who cares
		return
	if(istype(thing, mutant_hand_path)) // This is definitely meant to be here
		return
	if(HAS_TRAIT(thing, TRAIT_NODROP) || (thing.item_flags & ABSTRACT)) // This is meant to be here
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/datum/component/mutant_hands/proc/mob_dropped_item(mob/living/carbon/human/source, obj/item/thing)
	SIGNAL_HANDLER

	if(QDELETED(src) || QDELETED(parent))
		return

	if(source.is_holding(null)) // Finding a null implies an empty hand
		INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/// Ogólna zmutowana dłoń dla komponentu wyżej
/obj/item/mutant_hand
	name = "mutant hand"
	desc = "Czy ktoś poda mi rękę?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Ikona bazowa (dopisujemy _left/_right)
	var/hand_icon_state = "bloodhand"

/obj/item/mutant_hand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mutant_hand/equipped(mob/user, slot)
	. = ..()
	if(!hand_icon_state)
		return
	// We swap it intentionally here, so right icon is shown on the left (Because hands)
	if(user.get_held_index_of_item(src) % 2)
		icon_state = "[hand_icon_state]_right"
	else
		icon_state = "[hand_icon_state]_left"

// --- Space Phase (tier 4): ładowanie przez zmiażdżenie kryształu bluespace przy runie

/obj/item/stack/ore/bluespace_crystal/attack_self(mob/user)
	SEND_SIGNAL(user, COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL, src)
	return ..()
