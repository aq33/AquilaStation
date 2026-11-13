// Sprzęt złomiarzy według Goonstation (kod napisany od nowa, sprite'y Goona w aquila/icons/goonstation/).
// Reklamator niszczy ściany, podłogi, drzwi, okna i maszyny w złom; urządzenie dwukonstrukcyjne pakuje maszyny
// w paczki, które S.R.O.K.A. skupuje najdrożej; teleporter ręczny wraca na statek.

/// Punkty, na które teleporter ręczny przenosi złomiarza (na statku)
GLOBAL_LIST_EMPTY(salvager_teleport_points)

/// Złomiarz ma szkolenie inżyniera: rozbiera o 25% szybciej (jak trait training_engineer w Goonie)
/proc/salvager_work_time(mob/user, time)
	if(get_salvager_datum(user))
		time = round(time * 0.75)
	return max(time, 2 SECONDS)

/// Gdzie złomiarze mogą rozbierać (stacja i komora testowa, jak isrestrictedz w Goonie)
/proc/salvager_can_work_at(atom/A)
	return aq_gang_station_turf(get_turf(A))

///////////////////
// Reklamator
///////////////////

/obj/item/salvage_reclaimer
	name = "reklamator"
	desc = "Zlepek sprzętu przemysłowego do rozbijania urządzeń i konstrukcji na złom. Wysuwana korba służy za hak do pasa i ręczną ładowarkę."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "salvager"
	item_state = "salvager"
	lefthand_file = 'aquila/icons/goonstation/salvager_lefthand.dmi'
	righthand_file = 'aquila/icons/goonstation/salvager_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	usesound = 'sound/items/welder.ogg'
	attack_verb = list("uderza", "wali", "grzmoci")
	custom_materials = list(/datum/material/iron = 25000)
	/// Ładunek ogniwa (sekundy pracy)
	var/charge = 100
	var/max_charge = 100
	/// Trwa rozbiórka
	var/working = FALSE

/obj/item/salvage_reclaimer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ogniwo: [round(charge)]/[max_charge]. Użyj w ręce, żeby kręcić korbą i doładować ogniwo.</span>"
	. += "<span class='notice'>Kliknij ścianę, podłogę, drzwi, kratę, okno albo maszynę poza trybem walki, żeby rozebrać ją na złom.</span>"

/obj/item/salvage_reclaimer/attack_self(mob/user)
	if(working)
		return
	if(charge >= max_charge)
		to_chat(user, "<span class='notice'>Ogniwo jest pełne.</span>")
		return
	to_chat(user, "<span class='notice'>Kręcisz korbą [src]...</span>")
	while(charge < max_charge && do_after(user, 2 SECONDS, target = src))
		charge = min(max_charge, charge + 5)
		playsound(src, 'sound/items/ratchet.ogg', 30, TRUE)

// Rozbiórka idzie przed attackby: poza trybem walki reklamator nie uderza w to, co rozbiera
/obj/item/salvage_reclaimer/pre_attack(atom/A, mob/living/user, params)
	if(!istype(user) || user.combat_mode)
		return ..()
	if(working)
		return FALSE
	if(!salvage_time(A, user))
		return ..()
	try_salvage(A, user)
	return FALSE

/obj/item/salvage_reclaimer/proc/try_salvage(atom/target, mob/living/user)
	var/time = salvage_time(target, user)
	if(!time)
		return
	if(!salvager_can_work_at(target))
		to_chat(user, "<span class='warning'>[src] z jakiegoś powodu tu nie działa.</span>")
		return
	time = salvager_work_time(user, time)
	if(charge < time / 10)
		to_chat(user, "<span class='warning'>Ogniwo [src] jest za słabe. Pokręć korbą.</span>")
		return
	working = TRUE
	icon_state = "salvager-on"
	item_state = "salvager-on"
	user.update_inv_hands()
	user.visible_message("<span class='warning'>[user] zaczyna rozbierać [target] reklamatorem!</span>", "<span class='notice'>Zaczynasz rozbierać [target].</span>")
	playsound(target, 'sound/items/welder.ogg', 40, TRUE)
	var/done = do_after(user, time, target = target)
	working = FALSE
	icon_state = "salvager"
	item_state = "salvager"
	user.update_inv_hands()
	if(!done || QDELETED(target) || !salvage_time(target, user))
		return
	charge = max(0, charge - time / 10)
	log_game("[key_name(user)] salvaged [target] ([target.type]) at [AREACOORD(target)]")
	salvage(target)

/// Czas rozbiórki według Goona albo 0, gdy reklamator tego nie ruszy
/obj/item/salvage_reclaimer/proc/salvage_time(atom/target, mob/user)
	if(iswallturf(target))
		if(istype(target, /turf/closed/wall/r_wall))
			return 25 SECONDS
		return 20 SECONDS
	if(isfloorturf(target))
		var/turf/open/floor/F = target
		. = 30 SECONDS
		if(F.broken || F.burnt)
			. -= 5 SECONDS
		if(isplatingturf(F))
			. -= 5 SECONDS
		return
	if(!isobj(target))
		return 0
	var/obj/O = target
	if((O.resistance_flags & INDESTRUCTIBLE) || !O.anchored)
		return 0
	if(locate(/mob/living) in O)
		if(user)
			to_chat(user, "<span class='warning'>Nie rozbierzesz [O], kiedy ktoś jest w środku!</span>")
		return 0
	if(istype(O, /obj/machinery/door/airlock))
		return 30 SECONDS
	if(istype(O, /obj/structure/girder))
		return 10 SECONDS
	if(istype(O, /obj/structure/grille))
		return 6 SECONDS
	if(istype(O, /obj/structure/window))
		return 10 SECONDS
	if(istype(O, /obj/structure/lattice))
		return 5 SECONDS
	// Rury i maszyny atmosferyczne (także reaktor) zostają: rozbiórka zabiłaby załogę, a nie dała złomu
	if(istype(O, /obj/machinery/atmospherics) || istype(O, /obj/machinery/nuclearbomb) || istype(O, /obj/machinery/dominator))
		return 0
	if(istype(O, /obj/machinery) || istype(O, /obj/structure))
		return 5 SECONDS + salvage_complexity(O) * 3 SECONDS
	return 0

/// Złożoność rozbiórki: liczba części maszyny (Goon: liczba kroków dekonstrukcji)
/proc/salvage_complexity(obj/O)
	if(istype(O, /obj/machinery))
		var/obj/machinery/M = O
		return clamp(length(M.component_parts), 1, 6)
	return 1

/obj/item/salvage_reclaimer/proc/salvage(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(istype(target, /turf/closed/wall/r_wall))
		var/turf/closed/wall/W = target
		W.ChangeTurf(/turf/closed/wall)
		return
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		W.dismantle_wall(prob(33))
		return
	if(isfloorturf(target))
		if(prob(50))
			new /obj/item/stack/scrap/plating(T)
		T.ScrapeAway(isplatingturf(T) ? 1 : 2)
		return
	if(istype(target, /obj/machinery/door/airlock))
		for(var/i in 1 to 3)
			if(prob(50))
				new /obj/item/stack/scrap/plating(T)
	else if(istype(target, /obj/structure/girder) || istype(target, /obj/structure/lattice))
		new /obj/item/stack/scrap/plating(T)
	else if(istype(target, /obj/structure/grille))
		if(prob(20))
			new /obj/item/stack/scrap/plating(T)
	else if(istype(target, /obj/structure/window))
		for(var/i in 1 to 3)
			new /obj/item/shard(T)
	else
		var/obj/O = target
		var/scrap = 1 + salvage_complexity(O)
		for(var/i in 1 to scrap)
			new /obj/item/stack/scrap/plating(T)
		if(istype(O, /obj/machinery))
			new /obj/item/stack/scrap/electronics(T)
	qdel(target)

///////////////////
// Urządzenie dwukonstrukcyjne: pakuje maszyny w paczki i rozpakowuje je z powrotem
///////////////////

/obj/item/salvage_dualconstructor
	name = "urządzenie dwukonstrukcyjne"
	desc = "Poręczna część zestawu złomiarza: rozkłada maszyny na paczki gotowe do sprzedaży, a lutownicą składa je z powrotem. Farbę i oznaczenia ktoś zeskrobał."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "salvager-dual-decon"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	/// TRUE: rozkładanie maszyn, FALSE: składanie paczek
	var/deconstruct_mode = TRUE

/obj/item/salvage_dualconstructor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Tryb: [deconstruct_mode ? "rozkładanie maszyn w paczki" : "składanie paczek w maszyny"]. Użyj w ręce, żeby przełączyć.</span>"

/obj/item/salvage_dualconstructor/attack_self(mob/user)
	if(!do_after(user, 1.5 SECONDS, target = src))
		return
	deconstruct_mode = !deconstruct_mode
	icon_state = deconstruct_mode ? "salvager-dual-decon" : "salvager-dual-solder"
	playsound(src, 'sound/items/screwdriver2.ogg', 40, TRUE)
	to_chat(user, "<span class='notice'>Przełączasz [src] na [deconstruct_mode ? "rozkładanie" : "składanie"].</span>")

// Pakowanie idzie przed attackby: poza trybem walki urządzenie nie uderza w maszynę
/obj/item/salvage_dualconstructor/pre_attack(atom/A, mob/living/user, params)
	if(!deconstruct_mode || !istype(A, /obj/machinery) || !istype(user) || user.combat_mode)
		return ..()
	try_pack(A, user)
	return FALSE

/obj/item/salvage_dualconstructor/proc/try_pack(obj/machinery/M, mob/living/user)
	if(!salvage_packable(M))
		to_chat(user, "<span class='warning'>[M] nie da się spakować.</span>")
		return
	if(!salvager_can_work_at(M))
		to_chat(user, "<span class='warning'>[src] z jakiegoś powodu tu nie działa.</span>")
		return
	var/time = salvager_work_time(user, 5 SECONDS + salvage_complexity(M) * 3 SECONDS)
	user.visible_message("<span class='warning'>[user] zaczyna rozkładać [M]!</span>", "<span class='notice'>Zaczynasz rozkładać [M] na paczkę.</span>")
	if(!do_after(user, time, target = M) || QDELETED(M) || !salvage_packable(M))
		return
	var/obj/item/salvage_frame/frame = new(get_turf(M))
	frame.pack(M)
	log_game("[key_name(user)] packed [M] ([M.type]) into a salvage frame at [AREACOORD(M)]")
	qdel(M)

/// Maszyna, którą da się spakować w paczkę i potem złożyć (ma płytkę albo jest zwykłym urządzeniem)
/proc/salvage_packable(obj/machinery/M)
	if((M.resistance_flags & INDESTRUCTIBLE) || (M.flags_1 & NODECONSTRUCT_1) || !M.anchored)
		return FALSE
	if(istype(M, /obj/machinery/atmospherics) || istype(M, /obj/machinery/door) || istype(M, /obj/machinery/nuclearbomb) || istype(M, /obj/machinery/dominator))
		return FALSE
	if(locate(/mob/living) in M)
		return FALSE
	return TRUE

///////////////////
// Paczka maszyny
///////////////////

/obj/item/salvage_frame
	name = "paczka maszyny"
	desc = "Starannie rozłożona maszyna w ramie transportowej. Da się ją złożyć z powrotem lutownicą urządzenia dwukonstrukcyjnego albo śrubokrętem."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "dbox_big"
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 1
	/// Typ spakowanej maszyny
	var/obj/machinery/machine_type
	/// Maszyna miała ograniczony dostęp (Goon: +75 do ceny)
	var/had_access = FALSE
	/// Maszyna pochodzi z okrętu (Goon: towar spoza stacji jest wart mniej)
	var/from_station = TRUE

/obj/item/salvage_frame/proc/pack(obj/machinery/M)
	machine_type = M.type
	had_access = length(M.req_access) || length(M.req_one_access)
	from_station = aq_gang_station_turf(get_turf(M))
	name = "paczka maszyny ([M.name])"

/obj/item/salvage_frame/examine(mob/user)
	. = ..()
	if(machine_type)
		. += "<span class='notice'>W środku: [initial(machine_type.name)].</span>"

/obj/item/salvage_frame/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/salvage_dualconstructor))
		var/obj/item/salvage_dualconstructor/dual = I
		if(!dual.deconstruct_mode)
			unpack(user, 5 SECONDS)
			return TRUE
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		unpack(user, 20 SECONDS)
		return TRUE
	return ..()

/obj/item/salvage_frame/proc/unpack(mob/user, time)
	if(!machine_type)
		return
	var/turf/T = get_turf(src)
	if(!isopenturf(T) || is_blocked_turf(T, TRUE))
		to_chat(user, "<span class='warning'>Tu nie ma miejsca na maszynę. Połóż paczkę na wolnej podłodze.</span>")
		return
	user.visible_message("<span class='notice'>[user] składa [src].</span>", "<span class='notice'>Składasz [src].</span>")
	if(!do_after(user, time, target = src) || !isturf(loc))
		return
	var/obj/machinery/M = new machine_type(T)
	M.setDir(user.dir)
	log_game("[key_name(user)] unpacked a salvage frame into [M] ([M.type]) at [AREACOORD(M)]")
	qdel(src)

///////////////////
// Teleporter ręczny
///////////////////

/obj/effect/landmark/salvager_teleport
	name = "punkt teleportu złomiarzy"
	icon_state = "x"

/obj/effect/landmark/salvager_teleport/Initialize(mapload)
	. = ..()
	GLOB.salvager_teleport_points += src

/obj/effect/landmark/salvager_teleport/Destroy()
	GLOB.salvager_teleport_points -= src
	return ..()

/obj/item/salvager_hand_tele
	name = "prowizoryczny teleporter"
	desc = "Wątpliwe przenośne urządzenie teleportujące, sprzężone z jednym konkretnym miejscem."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "hand_tele_s"
	item_state = "hand_tele_s"
	lefthand_file = 'aquila/icons/goonstation/salvager_lefthand.dmi'
	righthand_file = 'aquila/icons/goonstation/salvager_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 5
	/// Ile skoków zostało (telekryształ dodaje jeden, najwyżej 5)
	var/charges = 3

/obj/item/salvager_hand_tele/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/salvager_hand_tele/update_icon()
	. = ..()
	cut_overlays()
	if(charges)
		add_overlay("hand_tele_o")

/obj/item/salvager_hand_tele/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		. += "<span class='notice'>Wyświetlacz pokazuje [charges] ładunki. Z boku jest mały otwór na telekryształy.</span>"

/obj/item/salvager_hand_tele/attack_self(mob/living/user)
	. = ..()
	if(!get_salvager_datum(user))
		switch(rand(1, 10))
			if(1 to 5)
				to_chat(user, "<span class='warning'>Nic nie rozumiesz z tego urządzenia. Może nie jest dla ciebie.</span>")
			if(6 to 8)
				to_chat(user, "<span class='warning'>Ekran [src] mruga, a urządzenie razi cię prądem.</span>")
				user.electrocute_act(15, src, 1, 1)
				user.Stun(3 SECONDS)
			if(9 to 10)
				to_chat(user, "<span class='warning'>[src] robi się bardzo gorący... i wybucha?!</span>")
				do_sparks(3, TRUE, src)
				qdel(src)
		return
	if(!length(GLOB.salvager_teleport_points))
		to_chat(user, "<span class='warning'>Coś jest nie tak...</span>")
		return
	if(!charges)
		to_chat(user, "<span class='warning'>[src] nie ma ładunków. Włóż telekryształ.</span>")
		return
	playsound(user, 'sound/machines/click.ogg', 60, TRUE)
	if(!do_after(user, 6 SECONDS, target = user, extra_checks = CALLBACK(src, PROC_REF(spark_while_charging))))
		return
	var/turf/destination = get_turf(pick(GLOB.salvager_teleport_points))
	user.emote("scream")
	do_sparks(3, TRUE, user)
	if(!do_teleport(user, destination, channel = TELEPORT_CHANNEL_BLUESPACE))
		return
	do_sparks(3, TRUE, user)
	charges--
	update_icon()
	if(charges <= 0)
		if(prob(33))
			to_chat(user, "<span class='warning'>[src] się rozpada! Cóż, jest ich więcej, skąd przyszedł.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Światełka [src] gasną! Pewnie trzeba paliwa?</span>")

/obj/item/salvager_hand_tele/proc/spark_while_charging()
	if(prob(5))
		do_sparks(1, TRUE, src)
	return TRUE

/obj/item/salvager_hand_tele/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/telecrystal))
		if(charges >= 5)
			to_chat(user, "<span class='warning'>Nie da się wcisnąć więcej kryształów. W środku jest ich dość.</span>")
			return TRUE
		var/obj/item/stack/telecrystal/crystal = I
		if(crystal.use(1))
			charges++
			update_icon()
			to_chat(user, "<span class='notice'>Ostrożnie wkładasz telekryształ do otworu z boku [src].</span>")
		return TRUE
	return ..()

///////////////////
// Gogle S.A.V.: pokazują wartość rzeczy w pobliżu
///////////////////

/obj/item/clothing/glasses/salvager
	name = "gogle S.A.V."
	desc = "Salvager Appraisal Visualizer: najnowsze osiągnięcie w oglądaniu wartości rzeczy. Nad przedmiotami w pobliżu wyświetla cenę w terminalu S.R.O.K.A."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "salvager_goggles"
	item_state = "meson"
	worn_icon_state = "meson"
	/// Kto nosi gogle i widzi ceny
	var/mob/living/carbon/human/viewer
	/// Wyświetlane obrazki z cenami
	var/list/value_images = list()

/obj/item/clothing/glasses/salvager/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_EYES && ishuman(user))
		viewer = user
		START_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/salvager/dropped(mob/user)
	. = ..()
	stop_viewing()

/obj/item/clothing/glasses/salvager/Destroy()
	stop_viewing()
	return ..()

/obj/item/clothing/glasses/salvager/proc/stop_viewing()
	STOP_PROCESSING(SSobj, src)
	clear_images()
	viewer = null

/obj/item/clothing/glasses/salvager/proc/clear_images()
	if(viewer?.client)
		viewer.client.images -= value_images
	value_images.Cut()

/obj/item/clothing/glasses/salvager/process(delta_time)
	if(!viewer || viewer.glasses != src || !viewer.client)
		stop_viewing()
		return
	clear_images()
	for(var/obj/item/I in view(4, viewer))
		if(I.loc == viewer)
			continue
		var/value = salvager_appraise(I)
		if(!value)
			continue
		var/image/price = image(loc = I, layer = ABOVE_ALL_MOB_LAYER)
		price.plane = GAME_PLANE
		price.maptext = MAPTEXT("<span style='color:#ffd84a'>[value]</span>")
		price.maptext_width = 64
		price.maptext_y = 20
		price.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA
		value_images += price
	viewer.client.images |= value_images

///////////////////
// Pozostały sprzęt złomiarzy
///////////////////

/obj/item/storage/backpack/salvager
	name = "wytrzymały plecak"
	desc = "Przerobiony wojskowy plecak z gęstej tkaniny. Zmieści masę narzędzi, złomu, a nawet paczki maszyn."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "tactical_backpack"
	item_state = "engiepack"
	worn_icon_state = "engiepack"

/obj/item/storage/backpack/salvager/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.max_combined_w_class = 40
	STR.exception_hold = typecacheof(list(/obj/item/salvage_frame, /obj/item/salvage_reclaimer))

/obj/item/storage/box/salvager_frame_compartment
	name = "przegroda na paczki"
	desc = "Specjalna przegroda do bezpiecznego przewożenia rozłożonych maszyn."
	illustration = null

/obj/item/storage/box/salvager_frame_compartment/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.max_w_class = WEIGHT_CLASS_HUGE
	STR.max_combined_w_class = 8 * WEIGHT_CLASS_HUGE
	STR.can_hold = typecacheof(list(/obj/item/salvage_frame))

/obj/item/weldingtool/experimental/salvager_arc
	name = "spawarka łukowa"
	desc = "Narzędzie, które po włączeniu tworzy skupiony łuk elektryczny: spawa metal albo go tnie. Samo się doładowuje."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "arcwelder-off"
	item_state = "arcwelder-off"
	lefthand_file = 'aquila/icons/goonstation/salvager_lefthand.dmi'
	righthand_file = 'aquila/icons/goonstation/salvager_righthand.dmi'
	toolspeed = 1

/obj/item/weldingtool/experimental/salvager_arc/switched_on(mob/user)
	. = ..()
	if(welding)
		icon_state = "arcwelder-on"
		item_state = "arcwelder-on"
		force = 25
		user?.update_inv_hands()

/obj/item/weldingtool/experimental/salvager_arc/switched_off(mob/user)
	. = ..()
	icon_state = "arcwelder-off"
	item_state = "arcwelder-off"
	force = 3
	user?.update_inv_hands()

/obj/item/powersink/salvager
	name = "magazyn energii złomiarzy"
	desc = "Pochłaniacz energii z ogniwami o dużej pojemności. Kradnie prąd z sieci; S.R.O.K.A. kupuje go tym drożej, im więcej zebrał."
	drain_rate = 100000
	max_power = 2e7
	color = "#ffd8a0"

/obj/item/powersink/salvager/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		. += "<span class='notice'>Wyświetlacz pokazuje [round(power_drained / max_power * 100)]% pojemności.</span>"

/obj/item/melee/sledgehammer/salvager
	name = "zbity młot wyważający"
	desc = "Ciężki metalowy młot do gniecenia stacji kosmicznych. I w zasadzie wszystkiego innego. Drzwi pękają pod nim czterokrotnie szybciej."
	color = "#c08a5a"

/obj/item/melee/sledgehammer/salvager/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 10, force_wielded = 25)

/obj/item/melee/sledgehammer/salvager/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !ISWIELDED(src) || !istype(target, /obj/machinery/door))
		return
	var/obj/machinery/door/D = target
	D.take_damage(force * 3, BRUTE, "melee", TRUE, get_dir(user, D))

/obj/item/gun/ballistic/shotgun/salvager
	name = "odzyskana strzelba"
	desc = "Strzelba z przeładowaniem pompowym, poskładana ze złomu. Magazynek na cztery naboje, sprzedawana bez amunicji."

/obj/item/gun/ballistic/shotgun/salvager/Initialize(mapload)
	. = ..()
	if(magazine)
		magazine.max_ammo = 4
		QDEL_LIST(magazine.stored_ammo)
	QDEL_NULL(chambered)
	update_icon()

/obj/item/storage/box/salvager_distract
	name = "sakwa na granaty"
	desc = "Granaty dymne i błyskowe do odwrócenia uwagi."

/obj/item/storage/box/salvager_distract/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/smokebomb(src)
	for(var/i in 1 to 2)
		new /obj/item/grenade/flashbang(src)

/// Butelka pięciu tabletek z danym narkotykiem (crank i meth ze sklepu S.R.O.K.A.)
/obj/item/storage/pill_bottle/salvager
	name = "butelka tabletek"
	var/datum/reagent/pill_reagent = /datum/reagent/drug/crank

/obj/item/storage/pill_bottle/salvager/PopulateContents()
	for(var/i in 1 to 5)
		var/obj/item/reagent_containers/pill/P = new(src)
		P.name = "tabletka ([initial(pill_reagent.name)])"
		P.reagents.add_reagent(pill_reagent, 10)

/obj/item/storage/pill_bottle/salvager/meth
	pill_reagent = /datum/reagent/drug/methamphetamine
