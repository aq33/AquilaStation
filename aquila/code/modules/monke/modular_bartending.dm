// Modular bartending z Monkestation (monkestation/code/modules/modular_bartending).
// Różnice: szklanka dziedziczy z naszych /food/drinks, wypełnienie rysujemy sami (u nas update_icon ma stały plik wypełnień),
// alt-klik zamiast click_alt, plaster limonki z limonki (u Monke limonka dawała pomarańczę),
// dekoracje bez innego źródła (słomki, pianka, oliwki, wisienki na patyczku) w pudełku z autolatu,
// pominięte puce/crystal (bez źródła także u Monke) i mielenie piasku na krzem.

#define RIM_SMALL "s"
#define RIM_MEDIUM "m"
#define RIM_LARGE "l"

#define SMALL_VARIANTS 6
#define MEDIUM_VARIANTS 13
#define LARGE_VARIANTS 5

#define GARNISH_ABOVE_RIM 1
#define GARNISH_RIM 2
#define GARNISH_CENTER 3
#define GARNISH_RIGHT 4
#define GARNISH_LEFT 5
#define GARNISH_MAX 6

/// Rozmiar krawędzi => lista wariantów szklanki (nazwa stanu => ikona) do menu radialnego
GLOBAL_LIST_EMPTY(glass_variants)

/obj/item/reagent_containers/food/drinks/modglass
	name = "plastyczna szklanka"
	desc = "To nie jest zwykła szklanka! Alt-klik zmienia jej kształt, a na krawędzi da się położyć dekoracje."
	icon = 'aquila/icons/obj/monke/bartending/modglass.dmi'
	icon_state = "mglass-1-"
	amount_per_transfer_from_this = 10
	volume = 50
	materials = list(/datum/material/glass = 500, /datum/material/silver = 100)
	max_integrity = 30
	spillable = TRUE
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound = 'sound/items/handling/drinkglass_pickup.ogg'
	custom_price = 25
	/// Rozmiar krawędzi, wybiera warianty i stany dekoracji
	var/rim = RIM_MEDIUM
	/// Ile wariantów kształtu ma ta szklanka
	var/variants = MEDIUM_VARIANTS
	/// Progi wypełnienia (procent)
	var/list/modglass_fill_thresholds = list(50, 90)
	/// Warstwa => stan dekoracji
	var/list/garnishes = list()

/obj/item/reagent_containers/food/drinks/modglass/small
	name = "mała plastyczna szklanka"
	icon_state = "sglass-1-"
	materials = list(/datum/material/glass = 100, /datum/material/silver = 100)
	volume = 25
	rim = RIM_SMALL
	variants = SMALL_VARIANTS

/obj/item/reagent_containers/food/drinks/modglass/large
	name = "duża plastyczna szklanka"
	icon_state = "lglass-1-"
	rim = RIM_LARGE
	variants = LARGE_VARIANTS

/// Buduje (raz na rozmiar krawędzi) listę wariantów do menu radialnego
/obj/item/reagent_containers/food/drinks/modglass/proc/glass_variants_list()
	var/list/cached = GLOB.glass_variants[rim]
	if(cached)
		return cached
	cached = list()
	for(var/variant in 1 to variants)
		var/name_string = "[rim]glass-[variant]-"
		cached[name_string] = icon('aquila/icons/obj/monke/bartending/modglass.dmi', name_string)
	GLOB.glass_variants[rim] = cached
	return cached

/obj/item/reagent_containers/food/drinks/modglass/AltClick(mob/user)
	if(!variants || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		return ..()
	var/choice = show_radial_menu(user, src, glass_variants_list(), radius = 48, require_near = TRUE)
	if(!choice || choice == icon_state)
		return
	icon_state = choice
	update_icon()

/obj/item/reagent_containers/food/drinks/modglass/attackby(obj/item/garnish/garnish, mob/user, params)
	if(!istype(garnish) || !garnish.garnish_state)
		return ..()
	if(garnishes["[garnish.garnish_layer]"])
		to_chat(user, "<span class='notice'>Na tej części szklanki już coś jest!</span>")
		return
	garnishes["[garnish.garnish_layer]"] = garnish.garnish_state
	to_chat(user, "<span class='notice'>Dekorujesz [src]: [garnish].</span>")
	qdel(garnish)
	update_icon()

/obj/item/reagent_containers/food/drinks/modglass/examine(mob/user)
	. = ..()
	if(length(garnishes))
		. += "<span class='notice'>Ma dekoracje. Umycie szklanki je zdejmie.</span>"

// Mycie zdejmuje dekoracje
/obj/item/reagent_containers/food/drinks/modglass/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/obj/item/reagent_containers/food/drinks/modglass/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!length(garnishes))
		return
	garnishes = list()
	update_icon()

/obj/item/reagent_containers/food/drinks/modglass/update_icon(dont_fill = FALSE)
	cut_overlays()
	if(reagents?.total_volume)
		var/percent = round((reagents.total_volume / volume) * 100)
		var/fill_level = modglass_fill_thresholds[1]
		for(var/threshold in modglass_fill_thresholds)
			if(percent >= threshold)
				fill_level = threshold
		var/mutable_appearance/filling = mutable_appearance('aquila/icons/obj/monke/bartending/modglass_fillings.dmi', "[icon_state][fill_level]")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	// Krawędź dzielona na dwie połówki, żeby reszta dekoracji była „w środku” szklanki
	var/rimtype = garnishes["[GARNISH_RIM]"]
	if(rimtype)
		add_overlay(mutable_appearance('aquila/icons/obj/monke/bartending/modglass_garnishes.dmi', "[rimtype]-[rim]"))
	for(var/i in GARNISH_CENTER to GARNISH_MAX)
		var/garnish_type = garnishes["[i]"]
		if(garnish_type)
			add_overlay(mutable_appearance('aquila/icons/obj/monke/bartending/modglass_garnishes.dmi', "[garnish_type]-[rim]"))
	if(rimtype)
		add_overlay(mutable_appearance('aquila/icons/obj/monke/bartending/modglass_garnishes.dmi', "[rimtype]-[rim]-top"))
	var/above_rim = garnishes["[GARNISH_ABOVE_RIM]"]
	if(above_rim)
		add_overlay(mutable_appearance('aquila/icons/obj/monke/bartending/modglass_garnishes.dmi', "[above_rim]-[rim]"))
	return ..(TRUE)

// =====================================================
// Dekoracje
// =====================================================

/obj/item/garnish
	name = "dekoracja"
	desc = "Nie powinieneś tego widzieć."
	icon = 'aquila/icons/obj/monke/bartending/modglass_garnishes_items.dmi'
	icon_state = "rim"
	w_class = WEIGHT_CLASS_SMALL
	/// Stan nakładki na szklance (bez sufiksu rozmiaru)
	var/garnish_state = "rim"
	var/garnish_layer = GARNISH_RIM

/obj/item/garnish/Initialize(mapload)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

/obj/item/garnish/salt
	name = "solna krawędź"
	desc = "Zebrana ze łez najbardziej słonego asystenta."

/obj/item/garnish/ash
	name = "popielna krawędź"
	desc = "Ale po co?"
	icon_state = "drim"
	garnish_state = "drim"

/obj/item/garnish/wire
	name = "odizolowany drut"
	desc = "Wygląda na całkowicie normalną rzecz do położenia na drinku."
	icon_state = "wire"
	garnish_state = "wire"

/obj/item/garnish/gold
	name = "złota obwódka"
	desc = "Doda twoim drinkom pierwszoklasowego szyku!"
	icon_state = "gold"
	garnish_state = "gold"

/obj/item/garnish/silver
	name = "srebrna obwódka"
	desc = "Doda twoim drinkom drugoklasowego szyku!"
	icon_state = "silver"
	garnish_state = "silver"

/obj/item/garnish/lime
	name = "plaster limonki"
	desc = "Klasyczny dodatek do drinka."
	icon_state = "lime"
	garnish_state = "lime"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/lemon
	name = "plaster cytryny"
	desc = "Klasyczny dodatek do drinka."
	icon_state = "lemon"
	garnish_state = "lemon"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/orange
	name = "plaster pomarańczy"
	desc = "Klasyczny dodatek do drinka."
	icon_state = "orange"
	garnish_state = "orange"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/cherry
	name = "kiść wisienek"
	desc = "Klasyczny dodatek do drinka."
	icon_state = "cherry"
	garnish_state = "cherry"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/straw
	name = "słomka"
	desc = "Urocza słomka do drinka."
	icon_state = "straw"
	garnish_state = "straw"
	garnish_layer = GARNISH_RIGHT

/obj/item/garnish/olives
	name = "oliwki na patyczku"
	desc = "Pasowałyby do martini."
	icon_state = "olives"
	garnish_state = "olives"
	garnish_layer = GARNISH_LEFT
	force = 3
	throwforce = 3
	throw_speed = 1
	sharpness = IS_SHARP
	attack_verb = list("dźga", "kłuje")

/obj/item/garnish/umbrellared
	name = "czerwona parasolka do drinka"
	desc = "Urocza parasolka do drinka. Ta jest jasnoczerwona, <i>nie</i> różowa."
	icon_state = "umbrellared"
	garnish_state = "umbrellared"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/umbrellablue
	name = "niebieska parasolka do drinka"
	desc = "Urocza parasolka do drinka. Ta jest niebieska."
	icon_state = "umbrellablue"
	garnish_state = "umbrellablue"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/umbrellagreen
	name = "zielona parasolka do drinka"
	desc = "Urocza parasolka do drinka. Ta jest zielona."
	icon_state = "umbrellagreen"
	garnish_state = "umbrellagreen"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/red_straw
	name = "słomka w paski"
	desc = "Urocza słomka do drinka."
	icon_state = "straw-red"
	garnish_state = "straw-red"
	garnish_layer = GARNISH_LEFT

/obj/item/garnish/foam
	name = "pianka dekoracyjna"
	desc = "Jadalna sztuczna pianka, żeby drinki wyglądały ładniej."
	icon_state = "foam"
	garnish_state = "foam"
	garnish_layer = GARNISH_ABOVE_RIM

/obj/item/garnish/cherrytopper
	name = "wisienki na patyczku"
	desc = "Kilka nabitych wisienek na patyczku."
	icon_state = "cherrytopper"
	garnish_state = "cherrytopper"
	garnish_layer = GARNISH_ABOVE_RIM

/// Pudełko dekoracji, które nie mają innego źródła
/obj/item/storage/box/garnish
	name = "pudełko dekoracji barowych"
	desc = "Słomki, pianka i inne drobiazgi do ozdabiania drinków w plastycznych szklankach."
	illustration = "drinkglass"

/obj/item/storage/box/garnish/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/garnish/straw(src)
		new /obj/item/garnish/red_straw(src)
	new /obj/item/garnish/foam(src)
	new /obj/item/garnish/foam(src)
	new /obj/item/garnish/cherrytopper(src)
	new /obj/item/garnish/olives(src)

// =====================================================
// Skąd brać dekoracje
// =====================================================

/// Wycina dekorację z jednej sztuki stosu (narzędzie: przecinak)
/obj/item/stack/proc/cut_garnish(mob/user, garnish_type, message)
	playsound(src, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	to_chat(user, "<span class='notice'>[message]</span>")
	if(!do_after(user, 1 SECONDS, target = src))
		return
	var/give_to_user = user.is_holding(src)
	var/obj/item/result = new garnish_type(drop_location())
	use(1)
	if(QDELETED(src) && give_to_user)
		user.put_in_hands(result)

/obj/item/stack/cable_coil/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WIRECUTTER)
		cut_garnish(user, /obj/item/garnish/wire, "Zaczynasz zdzierać izolację z [src]...")
		return
	return ..()

/obj/item/stack/sheet/mineral/silver/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WIRECUTTER)
		cut_garnish(user, /obj/item/garnish/silver, "Zaczynasz wycinać kawałek [src]...")
		return
	return ..()

/obj/item/stack/sheet/mineral/gold/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WIRECUTTER)
		cut_garnish(user, /obj/item/garnish/gold, "Zaczynasz wycinać kawałek [src]...")
		return
	return ..()

/obj/item/food/grown/cherries/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/cherry, 3, 1 SECONDS, FALSE, "Pokrój")

/obj/item/food/grown/citrus/lime/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/lime, 3, 1 SECONDS, FALSE, "Pokrój")

/obj/item/food/grown/citrus/orange/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/orange, 3, 1 SECONDS, FALSE, "Pokrój")

/obj/item/food/grown/citrus/lemon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/lemon, 3, 1 SECONDS, FALSE, "Pokrój")

/datum/chemical_reaction/saltsolidification
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 10)
	required_temp = 600
	mix_message = "Sól krystalizuje się w twardą krawędź."

/datum/chemical_reaction/saltsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/garnish/salt(location)

/datum/chemical_reaction/ashsolidification
	required_reagents = list(/datum/reagent/ash = 10)
	required_temp = 600
	mix_message = "Popiół zapieka się w twardą krawędź."

/datum/chemical_reaction/ashsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/turf/location = get_turf(holder.my_atom)
	// W pożarze każdy spalony przedmiot zostawia popiół, tysiące krawędzi na kafelkach zatykały ruch i ciśnienie
	var/rims = 0
	for(var/obj/item/garnish/ash/rim in location)
		rims++
	for(var/i in 1 to min(created_volume, MAX_ASH_RIMS_PER_TURF - rims))
		new /obj/item/garnish/ash(location)

/datum/crafting_recipe/umbrellared
	name = "Czerwona parasolka do drinka"
	result = /obj/item/garnish/umbrellared
	time = 1 SECONDS
	tools = list(/obj/item/toy/crayon/spraycan)
	reqs = list(/obj/item/paper = 1, /obj/item/stack/rods = 1)
	category = CAT_DRINK

/datum/crafting_recipe/umbrellablue
	name = "Niebieska parasolka do drinka"
	result = /obj/item/garnish/umbrellablue
	time = 1 SECONDS
	tools = list(/obj/item/toy/crayon/spraycan)
	reqs = list(/obj/item/paper = 1, /obj/item/stack/rods = 1)
	category = CAT_DRINK

/datum/crafting_recipe/umbrellagreen
	name = "Zielona parasolka do drinka"
	result = /obj/item/garnish/umbrellagreen
	time = 1 SECONDS
	tools = list(/obj/item/toy/crayon/spraycan)
	reqs = list(/obj/item/paper = 1, /obj/item/stack/rods = 1)
	category = CAT_DRINK

/datum/design/modglass
	name = "Plastyczna szklanka"
	id = "mod_glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/silver = 100)
	build_path = /obj/item/reagent_containers/food/drinks/modglass
	category = list("initial", "Dinnerware")

/datum/design/modglass_small
	name = "Mała plastyczna szklanka"
	id = "mod_glass_small"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100, /datum/material/silver = 100)
	build_path = /obj/item/reagent_containers/food/drinks/modglass/small
	category = list("initial", "Dinnerware")

/datum/design/modglass_large
	name = "Duża plastyczna szklanka"
	id = "mod_glass_large"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/silver = 100)
	build_path = /obj/item/reagent_containers/food/drinks/modglass/large
	category = list("initial", "Dinnerware")

/datum/design/garnish_box
	name = "Pudełko dekoracji barowych"
	id = "garnish_box"
	build_type = AUTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/storage/box/garnish
	category = list("initial", "Dinnerware")

#undef RIM_SMALL
#undef RIM_MEDIUM
#undef RIM_LARGE
#undef SMALL_VARIANTS
#undef MEDIUM_VARIANTS
#undef LARGE_VARIANTS
#undef GARNISH_ABOVE_RIM
#undef GARNISH_RIM
#undef GARNISH_CENTER
#undef GARNISH_RIGHT
#undef GARNISH_LEFT
#undef GARNISH_MAX
