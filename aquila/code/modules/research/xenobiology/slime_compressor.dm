// Kompresor szlamów (port SLIMECORE z Monkestation 2.0, Monkestation/Monkestation2.0#1442, tylko tryb crossbreedów).
// Wybierasz crossbreeda, a maszyna prosi o jednego dorosłego szlama bazowego (kolor ekstraktu)
// i dwóch dorosłych szlamów typu (kolor, którego ekstrakt nadaje ten efekt, np. orange = burning).
// Monke bierze jednego szlama typu. U nas dwóch, żeby koszt był bliski karmieniu 10 ekstraktami, które zostaje bez zmian.
// Szlamy wkłada się, przeciągając je na maszynę.

/// Ilu dorosłych szlamów typu wymaga crossbreed
#define COMPRESSOR_CROSS_SLIMES_REQUIRED 2
#define COMPRESSOR_BASE_COMPRESS_TIME (40 SECONDS)

/obj/machinery/slime_compressor
	name = "kompresor szlamów"
	desc = "Maszyna, która ściska żywe dorosłe szlamy w crossbreedy. Wybierz przepis i przeciągnij na nią szlamy."
	icon = 'aquila/icons/obj/xenobiology/slime_compressor.dmi'
	icon_state = "compressor"
	base_icon_state = "compressor"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/slime_compressor
	/// Czas kompresji, skraca go manipulator
	var/compress_time = COMPRESSOR_BASE_COMPRESS_TIME
	/// Szansa na drugiego crossbreeda, podnosi ją laser
	var/bonus_extract_chance = 0
	var/active = FALSE
	var/datum/looping_sound/microwave/soundloop
	/// Wybrany crossbreed
	var/obj/item/slimecross/current_recipe
	/// Kolor szlama bazowego dla wybranego przepisu
	var/base_colour
	/// Kolor szlamów typu dla wybranego przepisu
	var/cross_colour
	/// Ile szlamów każdego koloru jeszcze brakuje (kolor -> liczba)
	var/list/missing
	/// efekt -> obrazek do pierwszego menu
	var/static/list/effect_choices
	/// efekt -> list(kolor -> obrazek) do drugiego menu
	var/static/list/colour_choices
	/// efekt -> list(kolor -> typ crossbreeda)
	var/static/list/recipes
	/// efekt -> kolor szlama, którego ekstrakt go nadaje
	var/static/list/effect_to_colour

/obj/machinery/slime_compressor/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	if(!recipes)
		build_recipes()

/obj/machinery/slime_compressor/Destroy()
	QDEL_NULL(soundloop)
	eject_slimes()
	return ..()

/// Zbiera przepisy z istniejących crossbreedów i efektów ekstraktów
/obj/machinery/slime_compressor/proc/build_recipes()
	effect_choices = list()
	colour_choices = list()
	recipes = list()
	effect_to_colour = list()
	var/static/list/slime_colours = list("rainbow", "grey", "purple", "metal", "orange",
	"blue", "dark blue", "dark purple", "yellow", "silver", "pink", "red",
	"gold", "green", "adamantine", "oil", "light pink", "bluespace",
	"cerulean", "sepia", "black", "pyrite")
	for(var/colour in slime_colours)
		var/obj/item/slime_extract/core = text2path("/obj/item/slime_extract/[replacetext(colour, " ", "")]")
		if(!core || !initial(core.effectmod))
			continue
		effect_to_colour[initial(core.effectmod)] = colour
	for(var/obj/item/slimecross/cross as anything in subtypesof(/obj/item/slimecross))
		var/effect = initial(cross.effect)
		var/colour = initial(cross.colour)
		if(!effect_to_colour[effect] || !(colour in slime_colours))
			continue
		if(!recipes[effect])
			recipes[effect] = list()
			colour_choices[effect] = list()
			effect_choices[effect] = image(icon = initial(cross.icon), icon_state = effect)
		recipes[effect][colour] = cross
		colour_choices[effect][colour] = image(icon = 'icons/mob/slimes.dmi', icon_state = "[colour] slime extract")

/obj/machinery/slime_compressor/RefreshParts()
	var/speed = 1
	var/laser = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed = M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		laser = L.rating
	compress_time = COMPRESSOR_BASE_COMPRESS_TIME / speed
	bonus_extract_chance = (laser * 15) - 15

/obj/machinery/slime_compressor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: kompresja w <b>[DisplayTimeText(compress_time)]</b>, szansa na dodatkowy crossbreed <b>[bonus_extract_chance]%</b>.</span>"
	if(active)
		. += "<span class='notice'>Maszyna pracuje.</span>"
		return
	if(!current_recipe)
		. += "<span class='notice'>Kliknij, żeby wybrać crossbreeda. Alt-klik anuluje przepis i wyrzuca szlamy.</span>"
		return
	. += "<span class='notice'>Przepis: <b>[initial(current_recipe.effect)] [initial(current_recipe.colour)]</b>. Brakuje:</span>"
	for(var/colour in missing)
		if(missing[colour])
			. += "<span class='notice'>- dorosłe szlamy [colour]: [missing[colour]]</span>"

/obj/machinery/slime_compressor/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = active ? "[base_icon_state]_active" : base_icon_state
	return ..()

/obj/machinery/slime_compressor/attackby(obj/item/W, mob/user, params)
	if(!active && default_deconstruction_screwdriver(user, "[base_icon_state]_open", base_icon_state, W))
		clear_recipe()
		return
	if(!active && default_unfasten_wrench(user, W))
		clear_recipe()
		return
	if(!active && default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/slime_compressor/interact(mob/user)
	. = ..()
	if(active || panel_open || (machine_stat & (NOPOWER|BROKEN)))
		return
	if(!anchored)
		balloon_alert(user, "nieprzykręcony!")
		return
	if(current_recipe)
		to_chat(user, "<span class='notice'>Przepis jest już wybrany. Alt-klik go anuluje.</span>")
		return
	var/effect = show_radial_menu(user, src, effect_choices, require_near = TRUE, tooltips = TRUE)
	if(!effect || !recipes[effect])
		return
	var/colour = show_radial_menu(user, src, colour_choices[effect], require_near = TRUE, tooltips = TRUE)
	if(!colour || !recipes[effect][colour] || current_recipe || active)
		return
	set_recipe(recipes[effect][colour], colour, effect_to_colour[effect])
	to_chat(user, "<span class='notice'>Wybierasz [effect] [colour]. Potrzeba dorosłego szlama [colour] i [COMPRESSOR_CROSS_SLIMES_REQUIRED] dorosłych szlamów [cross_colour].</span>")

/obj/machinery/slime_compressor/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || active || !current_recipe)
		return
	clear_recipe()
	to_chat(user, "<span class='notice'>Anulujesz przepis [src].</span>")

/obj/machinery/slime_compressor/proc/set_recipe(obj/item/slimecross/recipe, new_base_colour, new_cross_colour)
	current_recipe = recipe
	base_colour = new_base_colour
	cross_colour = new_cross_colour
	missing = list()
	missing[base_colour] = 1
	missing[cross_colour] += COMPRESSOR_CROSS_SLIMES_REQUIRED

/obj/machinery/slime_compressor/proc/clear_recipe()
	current_recipe = null
	base_colour = null
	cross_colour = null
	missing = null
	eject_slimes()

/obj/machinery/slime_compressor/proc/eject_slimes()
	var/turf/T = drop_location()
	for(var/mob/living/simple_animal/slime/slime in src)
		slime.forceMove(T)

/obj/machinery/slime_compressor/MouseDrop_T(atom/dropping, mob/user)
	if(!isslime(dropping) || !isliving(user) || !user.canUseTopic(src, BE_CLOSE) || !user.Adjacent(dropping))
		return
	try_insert(dropping, user)

/// Wkłada szlama, jeśli przepis go potrzebuje
/obj/machinery/slime_compressor/proc/try_insert(mob/living/simple_animal/slime/slime, mob/user)
	if(active || !current_recipe || panel_open || (machine_stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='warning'>[src] nie przyjmie teraz szlama.</span>")
		return FALSE
	if(slime.stat == DEAD)
		to_chat(user, "<span class='warning'>Kompresor przyjmuje tylko żywe szlamy.</span>")
		return FALSE
	if(slime.ckey)
		to_chat(user, "<span class='warning'>[slime] wyślizguje się, nie da się go wcisnąć do maszyny.</span>")
		return FALSE
	if(!slime.is_adult)
		to_chat(user, "<span class='warning'>[slime] jest za mały. Potrzebne są dorosłe szlamy.</span>")
		return FALSE
	if(!missing[slime.colour])
		to_chat(user, "<span class='warning'>Przepis nie potrzebuje już szlama [slime.colour].</span>")
		return FALSE
	if(slime.buckled)
		slime.Feedstop(silent = TRUE)
	slime.forceMove(src)
	slime.notransform = TRUE // w środku nie rośnie i się nie dzieli
	missing[slime.colour]--
	visible_message("<span class='notice'>[user] wkłada [slime] do [src].</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 50, TRUE)
	for(var/colour in missing)
		if(missing[colour])
			return TRUE
	start_compressing()
	return TRUE

/obj/machinery/slime_compressor/Exited(atom/movable/gone, direction)
	. = ..()
	if(!isslime(gone))
		return
	var/mob/living/simple_animal/slime/slime = gone
	slime.notransform = FALSE
	if(!active && missing)
		if(!isnull(missing[slime.colour]))
			missing[slime.colour]++

/obj/machinery/slime_compressor/proc/start_compressing()
	active = TRUE
	use_power = ACTIVE_POWER_USE
	soundloop.start()
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(finish_compressing)), compress_time)

/obj/machinery/slime_compressor/proc/finish_compressing()
	if(QDELETED(src) || !active)
		return
	soundloop.stop()
	use_power = IDLE_POWER_USE
	var/obj/item/slimecross/recipe = current_recipe
	current_recipe = null
	missing = null
	active = FALSE
	for(var/mob/living/simple_animal/slime/slime in src)
		qdel(slime)
	if(machine_stat & (NOPOWER|BROKEN) || !recipe)
		visible_message("<span class='warning'>[src] gaśnie, a ściśnięty szlam rozlewa się w bezużyteczną maź.</span>")
		update_appearance()
		return
	new recipe(drop_location())
	if(prob(bonus_extract_chance))
		new recipe(drop_location())
	visible_message("<span class='notice'>[src] wyrzuca gotowy crossbreed.</span>")
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	update_appearance()

/obj/item/circuitboard/machine/slime_compressor
	name = "kompresor szlamów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/slime_compressor
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)

/datum/design/board/slime_compressor
	name = "Projekt maszyny (kompresor szlamów)"
	desc = "Płytka drukowana kompresora szlamów."
	id = "slime_compressor"
	build_path = /obj/item/circuitboard/machine/slime_compressor
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

#undef COMPRESSOR_CROSS_SLIMES_REQUIRED
#undef COMPRESSOR_BASE_COMPRESS_TIME
