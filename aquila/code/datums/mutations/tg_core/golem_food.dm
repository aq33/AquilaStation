// AQUILA - port z tgstation: jedzenie minerałów (TRAIT_ROCK_EATER / TRAIT_ROCK_METAMORPHIC)
// Źródła: code/datums/components/food/golem_food.dm, code/game/objects/items/stacks/golem_food/*,
// code/__DEFINES/DNA.dm (golem_stack_food_*), code/modules/reagents/chemistry/reagents/food_reagents.dm (nutriment/mineral)

#define GOLEM_FOOD_IRON "golem_food_iron"
#define GOLEM_FOOD_GLASS "golem_food_glass"
#define GOLEM_FOOD_URANIUM "golem_food_uranium"
#define GOLEM_FOOD_SILVER "golem_food_silver"
#define GOLEM_FOOD_PLASMA "golem_food_plasma"
#define GOLEM_FOOD_GOLD "golem_food_gold"
#define GOLEM_FOOD_DIAMOND "golem_food_diamond"
#define GOLEM_FOOD_TITANIUM "golem_food_titanium"
#define GOLEM_FOOD_PLASTEEL "golem_food_plasteel"
#define GOLEM_FOOD_BANANIUM "golem_food_bananium"
#define GOLEM_FOOD_BLUESPACE "golem_food_bluespace"
#define GOLEM_FOOD_GIBTONITE "golem_food_gibtonite"
#define GOLEM_FOOD_LIGHTBULB "golem_food_lightbulb"

/// Mnożnik pożywności przetopionych arkuszy względem surowej rudy
#define GOLEMFOOD_PREPARED_MEAL 1.3

/// Wszystkie efekty jedzenia minerałów
GLOBAL_LIST_INIT(golem_stack_food_types, list(
	GOLEM_FOOD_IRON = new /datum/golem_food_buff/iron(),
	GOLEM_FOOD_GLASS = new /datum/golem_food_buff/glass(),
	GOLEM_FOOD_URANIUM = new /datum/golem_food_buff/uranium(),
	GOLEM_FOOD_SILVER = new /datum/golem_food_buff/silver(),
	GOLEM_FOOD_PLASMA = new /datum/golem_food_buff/plasma(),
	GOLEM_FOOD_GOLD = new /datum/golem_food_buff/gold(),
	GOLEM_FOOD_DIAMOND = new /datum/golem_food_buff/diamond(),
	GOLEM_FOOD_TITANIUM = new /datum/golem_food_buff/titanium(),
	GOLEM_FOOD_PLASTEEL = new /datum/golem_food_buff/plasteel(),
	GOLEM_FOOD_BANANIUM = new /datum/golem_food_buff/bananium(),
	GOLEM_FOOD_BLUESPACE = new /datum/golem_food_buff/bluespace(),
	GOLEM_FOOD_GIBTONITE = new /datum/golem_food_buff/gibtonite(),
	GOLEM_FOOD_LIGHTBULB = new /datum/golem_food_buff/lightbulb(),
))

/// Typ przedmiotu -> efekt jedzenia
GLOBAL_LIST_INIT(golem_stack_food_directory, list(
	/obj/item/gibtonite = GLOB.golem_stack_food_types[GOLEM_FOOD_GIBTONITE],
	/obj/item/light = GLOB.golem_stack_food_types[GOLEM_FOOD_LIGHTBULB],
	/obj/item/stack/sheet/iron = GLOB.golem_stack_food_types[GOLEM_FOOD_IRON],
	/obj/item/stack/ore/iron = GLOB.golem_stack_food_types[GOLEM_FOOD_IRON],
	/obj/item/stack/sheet/glass = GLOB.golem_stack_food_types[GOLEM_FOOD_GLASS],
	/obj/item/stack/sheet/mineral/uranium = GLOB.golem_stack_food_types[GOLEM_FOOD_URANIUM],
	/obj/item/stack/ore/uranium = GLOB.golem_stack_food_types[GOLEM_FOOD_URANIUM],
	/obj/item/stack/sheet/mineral/silver = GLOB.golem_stack_food_types[GOLEM_FOOD_SILVER],
	/obj/item/stack/ore/silver = GLOB.golem_stack_food_types[GOLEM_FOOD_SILVER],
	/obj/item/stack/sheet/mineral/plasma = GLOB.golem_stack_food_types[GOLEM_FOOD_PLASMA],
	/obj/item/stack/ore/plasma = GLOB.golem_stack_food_types[GOLEM_FOOD_PLASMA],
	/obj/item/stack/sheet/mineral/gold = GLOB.golem_stack_food_types[GOLEM_FOOD_GOLD],
	/obj/item/stack/ore/gold = GLOB.golem_stack_food_types[GOLEM_FOOD_GOLD],
	/obj/item/stack/sheet/mineral/diamond = GLOB.golem_stack_food_types[GOLEM_FOOD_DIAMOND],
	/obj/item/stack/ore/diamond = GLOB.golem_stack_food_types[GOLEM_FOOD_DIAMOND],
	/obj/item/stack/sheet/mineral/titanium = GLOB.golem_stack_food_types[GOLEM_FOOD_TITANIUM],
	/obj/item/stack/ore/titanium = GLOB.golem_stack_food_types[GOLEM_FOOD_TITANIUM],
	/obj/item/stack/sheet/plasteel = GLOB.golem_stack_food_types[GOLEM_FOOD_PLASTEEL],
	/obj/item/stack/ore/bananium = GLOB.golem_stack_food_types[GOLEM_FOOD_BANANIUM],
	/obj/item/stack/sheet/mineral/bananium = GLOB.golem_stack_food_types[GOLEM_FOOD_BANANIUM],
	/obj/item/stack/ore/bluespace_crystal = GLOB.golem_stack_food_types[GOLEM_FOOD_BLUESPACE],
	/obj/item/stack/ore/bluespace_crystal/refined = GLOB.golem_stack_food_types[GOLEM_FOOD_BLUESPACE],
	/obj/item/stack/ore/bluespace_crystal/artificial = GLOB.golem_stack_food_types[GOLEM_FOOD_BLUESPACE],
))

/// Klucz z katalogu dla danego typu (dokładne dopasowanie albo najbliższy przodek)
/proc/tg_core_golem_food_key(path)
	if(!ispath(path))
		return null
	if(GLOB.golem_stack_food_directory[path])
		return path
	for(var/key in GLOB.golem_stack_food_directory)
		if(ispath(path, key))
			return key
	return null

// --- Podpięcie komponentu do przedmiotów (tg: stack.dm, light_items.dm, ores_coins.dm) ---

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src) || . == INITIALIZE_HINT_QDEL)
		return
	var/food_key = tg_core_golem_food_key(merge_type)
	if(!food_key)
		return
	var/processing_bonus = 1
	if(ispath(merge_type, /obj/item/stack/sheet))
		processing_bonus = GOLEMFOOD_PREPARED_MEAL
	AddComponent(/datum/component/golem_food, golem_food_key = food_key, food_multiplier = processing_bonus)

/obj/item/light/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/golem_food, golem_food_key = /obj/item/light, extra_validation = CALLBACK(src, PROC_REF(tg_core_is_intact)))

/obj/item/light/proc/tg_core_is_intact()
	return status == LIGHT_OK

/obj/item/gibtonite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/golem_food, consume_on_eat = FALSE, golem_food_key = /obj/item/gibtonite)

// --- Komponent ---

/// Component which allows something to be eaten by a golem
/datum/component/golem_food
	/// Whether to destroy our item when we eat it
	var/consume_on_eat
	/// Reference to the kind of food we provide
	var/datum/golem_food_buff/snack_type
	/// Our abstract fake food item
	var/obj/item/food/golem_food/golem_snack
	/// Any extra checks which need to be done when seeing if this is edible
	var/datum/callback/extra_validation
	/// What additional nutrition modifiers should be added to this food?
	var/food_multiplier = 1

/datum/component/golem_food/Initialize(consume_on_eat = TRUE, golem_food_key, datum/callback/extra_validation, food_multiplier = 1)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!golem_food_key || !GLOB.golem_stack_food_directory[golem_food_key])
		CRASH("Golem food type not specified, this is a required parameter.")
	src.consume_on_eat = consume_on_eat
	snack_type = GLOB.golem_stack_food_directory[golem_food_key]
	src.extra_validation = extra_validation
	if(food_multiplier)
		src.food_multiplier = food_multiplier

/datum/component/golem_food/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/golem_food/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_EXAMINE))
	return ..()

/datum/component/golem_food/Destroy(force, silent)
	QDEL_NULL(golem_snack)
	snack_type = null
	QDEL_NULL(extra_validation)
	return ..()

/// Attempt to feed this item to a rock eater
/datum/component/golem_food/proc/on_attack(atom/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!iscarbon(target) || user.combat_mode || !HAS_TRAIT(target, TRAIT_ROCK_EATER))
		return
	if(extra_validation && !extra_validation.Invoke())
		source.balloon_alert(user, "niejadalne!")
		return COMPONENT_ITEM_NO_ATTACK
	if(!snack_type.can_consume(target))
		source.balloon_alert(user, "nie da się tego zjeść!")
		return COMPONENT_ITEM_NO_ATTACK
	if(isnull(golem_snack))
		create_golem_snack(source)
	var/datum/component/edible/edible = golem_snack.GetComponent(/datum/component/edible)
	if(edible)
		INVOKE_ASYNC(edible, TYPE_PROC_REF(/datum/component/edible, TryToEat), target, user)
	return COMPONENT_ITEM_NO_ATTACK

/// Creates our golem snack atom instance
/datum/component/golem_food/proc/create_golem_snack(atom/source)
	golem_snack = new(null, source.name, consume_on_eat, snack_type, parent, food_multiplier)
	RegisterSignal(golem_snack, COMSIG_PARENT_QDELETING, PROC_REF(on_food_destroyed))

/// Reference handling for abstract food object
/datum/component/golem_food/proc/on_food_destroyed()
	SIGNAL_HANDLER
	golem_snack = null

/// Add extra examine text to people who have golem brains
/datum/component/golem_food/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(user, TRAIT_ROCK_METAMORPHIC))
		return
	examine_text += "<span class='notice'>[snack_type.added_info]</span>"

// --- Abstrakcyjne jedzenie ---

/// Abstract food item used to feed golems
/obj/item/food/golem_food
	name = "tymczasowa przekąska z materiału golema"
	desc = "Nie powinieneś tego widzieć. To abstrakcyjny przedmiot, który pozwala ci jeść kamienie."
	bite_consumption = 2
	max_volume = 500
	food_reagents = list(/datum/reagent/consumable/nutriment/mineral = 500)
	foodtypes = NONE // tg STONE - u nas brak, a GROSS wywołuje obrzydzenie
	eatverbs = list("chrupie", "przeżuwa", "kruszy zębami", "gryzie")
	/// If we use up a stack of food on use or not
	var/consume_food = TRUE
	/// A reference to whatever it is we represent
	var/atom/owner
	/// Golem food buff to apply on consumption
	var/datum/golem_food_buff/food_buff

/obj/item/food/golem_food/Initialize(mapload, snack_name, consume_food = TRUE, datum/golem_food_buff/food_buff, atom/owner, nutrition_mod = 1)
	if(snack_name)
		name = snack_name
	src.consume_food = consume_food
	src.food_buff = food_buff
	src.owner = owner
	if(food_buff)
		bite_consumption = max(food_buff.nutrition * nutrition_mod, 0.1)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_destroyed))

/obj/item/food/golem_food/Destroy()
	owner = null
	food_buff = null
	return ..()

/// Clean ourselves up if our parent dies
/obj/item/food/golem_food/proc/on_parent_destroyed(datum/destroyed_thing)
	SIGNAL_HANDLER
	owner = null
	qdel(src)

/obj/item/food/golem_food/make_edible()
	AddComponent(/datum/component/edible,\
		initial_reagents = food_reagents,\
		food_flags = food_flags,\
		foodtypes = foodtypes,\
		volume = max_volume,\
		eat_time = eat_time,\
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption,\
		after_eat = CALLBACK(src, PROC_REF(took_bite)))

// Abstrakcyjna przekąska nie gnije, nie piecze się i nie zostawia śmieci
/obj/item/food/golem_food/make_processable()
	return
/obj/item/food/golem_food/make_grillable()
	return
/obj/item/food/golem_food/make_bakeable()
	return
/obj/item/food/golem_food/make_leave_trash()
	return
/obj/item/food/golem_food/make_decompose(mapload)
	return

/// Called when someone bites this food, subtract one charge from our material stack
/obj/item/food/golem_food/proc/took_bite(mob/eater, mob/feeder, bitecount)
	if(!owner)
		qdel(src)
		return
	// Przekąska ma „nieskończony” zapas - uzupełniamy to, co zjedzono
	reagents?.add_reagent(/datum/reagent/consumable/nutriment/mineral, bite_consumption)
	food_buff?.on_consumption(eater, owner)
	if(!consume_food)
		qdel(src)
		return
	if(isstack(owner))
		var/obj/item/stack/stack_owner = owner
		stack_owner.use(1)
	else
		qdel(owner)

// --- Odczynnik ---

/datum/reagent/consumable/nutriment/mineral
	name = "Papka mineralna"
	description = "Minerały utłuczone na pastę. Pożywne tylko wtedy, gdy sam jesteś z kamienia."
	taste_description = "minerały"
	color = COLOR_WEBSAFE_DARK_GRAY
	chem_flags = NONE
	brute_heal = 0
	burn_heal = 0

/// tg get_nutriment_factor: kamienie nie sycą nikogo poza jedzącymi skały
/datum/reagent/consumable/nutriment/mineral/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_ROCK_EATER))
		return ..()
	var/old_factor = nutriment_factor
	nutriment_factor = 0
	. = ..()
	nutriment_factor = old_factor

// --- Efekty jedzenia (tg golem_food_buff.dm) ---

/// An effect you gain from eating minerals
/datum/golem_food_buff
	/// If we can apply this while you already have a different status effect
	var/exclusive = TRUE
	/// Nutrition to grant per stack consumed
	var/nutrition = 2
	/// Typepath of status effect to apply
	var/status_effect
	/// Extra information to display when a valid food is examined
	var/added_info = ""

/// Returns true if the passed mob can currently gain this buff
/datum/golem_food_buff/proc/can_consume(mob/living/consumer)
	if(!exclusive)
		return TRUE
	var/datum/status_effect/golem/existing = consumer.has_status_effect(/datum/status_effect/golem)
	return !existing || !existing.exclusive || istype(existing, status_effect)

/// Called when someone actually eats this
/datum/golem_food_buff/proc/on_consumption(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if(!HAS_TRAIT(consumer, TRAIT_ROCK_METAMORPHIC))
		return
	apply_effects(consumer, consumed, multiplier)

/// Apply our desired effects to the eater
/datum/golem_food_buff/proc/apply_effects(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if(status_effect)
		consumer.apply_status_effect(status_effect, multiplier)

/// Can eat at any time, but isn't very nutritious
/datum/golem_food_buff/glass
	exclusive = FALSE
	nutrition = 0.5
	added_info = "Ten minerał można jeść zawsze, ale to głównie puste kalorie."

/// More filling, and heals you
/datum/golem_food_buff/iron
	nutrition = 3
	added_info = "Ten minerał syci, a nawet trochę leczy."
	/// Amount by which you heal from eating some iron
	var/healed_amount = 3
	/// Order in which to heal damage types
	var/list/damage_heal_order = list(BRUTE, BURN)

/datum/golem_food_buff/iron/apply_effects(mob/living/carbon/consumer, atom/movable/consumed, multiplier = 1)
	if(consumer.health == consumer.maxHealth)
		return
	consumer.heal_ordered_damage(healed_amount * multiplier, damage_heal_order)
	new /obj/effect/temp_visual/heal(get_turf(consumer), COLOR_HEALING_CYAN)

/datum/golem_food_buff/uranium
	status_effect = /datum/status_effect/golem/uranium
	nutrition = 5
	added_info = "Zjedzony, ten minerał zastąpi ci jedzenie i wstrzyma trawienie na pięć minut."

/datum/golem_food_buff/silver
	status_effect = /datum/status_effect/golem/silver
	nutrition = 4
	added_info = "Zjedzony, ten minerał odpycha nadprzyrodzone moce i chroni przed magią."

/datum/golem_food_buff/plasma
	status_effect = /datum/status_effect/golem/plasma
	nutrition = 6
	added_info = "Zjedzony, ten minerał pozwoli ci wchłaniać ciepło i zamieniać je w energię."

/datum/golem_food_buff/plasteel
	status_effect = /datum/status_effect/golem/plasteel
	nutrition = 7
	added_info = "Zjedzony, ten minerał uodporni cię na zagrożenia kosmosu."

/datum/golem_food_buff/gold
	status_effect = /datum/status_effect/golem/gold
	nutrition = 5
	added_info = "Zjedzony, ten minerał pokryje cię lśniącą warstwą odbijającą pociski energetyczne."

/datum/golem_food_buff/diamond
	status_effect = /datum/status_effect/golem/diamond
	nutrition = 9
	added_info = "Zjedzony, ten minerał zagina wokół ciebie światło - jesteś szybszy i trudniej cię dostrzec."

/datum/golem_food_buff/titanium
	status_effect = /datum/status_effect/golem/titanium
	nutrition = 5
	added_info = "Zjedzony, ten minerał uczyni cię twardszym, a twoje ciosy mocniejszymi."

/datum/golem_food_buff/bananium
	status_effect = /datum/status_effect/golem/bananium
	nutrition = 10
	added_info = "Zjedzony, ten minerał uczyni cię zabawniejszym."

/datum/golem_food_buff/lightbulb
	nutrition = 0
	exclusive = FALSE
	status_effect = /datum/status_effect/golem/lightbulb
	added_info = "Niepożywne, ale po zjedzeniu zdrowo świecisz."

/datum/golem_food_buff/gibtonite
	exclusive = FALSE
	nutrition = 5
	added_info = "Po zjedzeniu możesz wystrzelić ten minerał jak rakietę. Trochę ciężko go utrzymać w środku."

/datum/golem_food_buff/gibtonite/apply_effects(mob/living/carbon/human/consumer, atom/movable/consumed, multiplier = 1)
	// Gibtonit trzymany w ręce trzeba najpierw porządnie wyjąć z ekwipunku
	if(isitem(consumed) && consumed.loc == consumer)
		consumer.temporarilyRemoveItemFromInventory(consumed, TRUE)
	var/obj/item/gibtonite_hand/new_hand = new(null, consumed)
	if(QDELETED(new_hand))
		return
	if(consumer.put_in_hands(new_hand))
		return
	consumer.drop_all_held_items()
	if(consumer.put_in_hands(new_hand))
		return
	consumed.forceMove(get_turf(consumer))
	new_hand.held_gibtonite = null
	qdel(new_hand)
	consumer.visible_message("<span class='warning'>[consumer] nie może utrzymać w sobie [consumed] i wykasłuje to na ziemię!</span>")

/datum/golem_food_buff/bluespace
	exclusive = FALSE
	nutrition = 10
	added_info = "Po zjedzeniu możesz użyć zgromadzonej energii, by się teleportować."

/datum/golem_food_buff/bluespace/apply_effects(mob/living/carbon/human/consumer, atom/movable/consumed, multiplier = 1)
	if(multiplier <= 0.2)
		return
	var/obj/item/bluespace_finger/new_hand = new
	if(isstack(consumed))
		var/obj/item/stack/stack = consumed
		if(stack.amount == 1)
			consumer.dropItemToGround(stack)
	if(consumer.put_in_hands(new_hand, del_on_fail = TRUE))
		return
	consumer.balloon_alert(consumer, "brak wolnych rąk!")

#undef GOLEM_FOOD_IRON
#undef GOLEM_FOOD_GLASS
#undef GOLEM_FOOD_URANIUM
#undef GOLEM_FOOD_SILVER
#undef GOLEM_FOOD_PLASMA
#undef GOLEM_FOOD_GOLD
#undef GOLEM_FOOD_DIAMOND
#undef GOLEM_FOOD_TITANIUM
#undef GOLEM_FOOD_PLASTEEL
#undef GOLEM_FOOD_BANANIUM
#undef GOLEM_FOOD_BLUESPACE
#undef GOLEM_FOOD_GIBTONITE
#undef GOLEM_FOOD_LIGHTBULB
#undef GOLEMFOOD_PREPARED_MEAL
