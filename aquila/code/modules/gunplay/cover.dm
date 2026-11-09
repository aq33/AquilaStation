// AQUILA - osłony przed kulami (wzór: Shiptest /datum/component/cover, /vg/ osłony z wytrzymałością, CM zasada pierwszego kafla).
// - Barierki i przewrócone stoły osłaniają od swojej strony (krawędzi kafla), krzesła z każdej strony.
// - Zatrzymana kula trafia w osłonę, więc ta traci wytrzymałość i w końcu się rozpada (bullet_act obiektu).
// - Osłona tuż przy strzelcu nie blokuje (strzał znad własnej osłony), a leżący tuż za osłoną jest chroniony lepiej.
// - Stół przewraca się Ctrl+Shift+klikiem (Shiptest) w stronę od siebie; sprite'y przewróconych stołów z Paradise są
//   w naszych plikach stołów (tableflip, woodflip, pokerflip), łączenie sąsiednich przewróconych stołów jak w Paradise.
// Barykady liczą przepuszczanie po staremu (proj_pass_rate w CanAllowThrough), tu ich nie ruszamy.

/obj
	/// Szansa (%), że kula przejdzie przez tę osłonę; null = to nie osłona
	var/projectile_cover_pass = null

/obj/structure/railing
	projectile_cover_pass = 60

/obj/structure/railing/corner
	projectile_cover_pass = null

/obj/structure/chair
	projectile_cover_pass = 80

/obj/structure/chair/stool
	projectile_cover_pass = 90

/obj/item/projectile
	/// Osłona, która właśnie zatrzymała kulę (can_hit_target i select_target trafiają w nią)
	var/obj/aq_cover_hit
	/// Osłony już sprawdzone przez ten pocisk (jeden rzut na osłonę)
	var/list/aq_cover_checked

/obj/item/projectile/Destroy()
	aq_cover_hit = null
	aq_cover_checked = null
	return ..()

/// Czy ta osłona zatrzymuje ten pocisk (jeden rzut na osłonę i pocisk)
/obj/item/projectile/proc/roll_cover(obj/cover)
	if(LAZYACCESS(aq_cover_checked, cover))
		return FALSE
	LAZYSET(aq_cover_checked, cover, TRUE)
	if(!cover.anchored && !istype(cover, /obj/structure/chair))
		return FALSE
	if(cover == original) // kliknięta osłona i tak dostanie
		return FALSE
	if(firer && get_dist(firer, cover) <= 1) // strzał znad własnej osłony (CM: pierwszy kafel nie blokuje)
		return FALSE
	var/pass_rate = cover.projectile_cover_pass
	if(isliving(original) && get_dist(cover, original) <= 1)
		var/mob/living/target_mob = original
		if(!(target_mob.mobility_flags & MOBILITY_STAND))
			pass_rate -= 20 // leżący tuż za osłoną
	return !prob(pass_rate)

/// Pocisk przeszedł z kafla from_turf na to_turf: sprawdza barierki i przewrócone stoły na krawędzi oraz krzesła
/obj/item/projectile/proc/check_cover(turf/from_turf, turf/to_turf)
	var/move_dir = get_dir(from_turf, to_turf)
	if(!move_dir)
		return null
	for(var/obj/cover in from_turf)
		if(isnull(cover.projectile_cover_pass) || !(cover.flags_1 & ON_BORDER_1) || !(cover.dir & move_dir))
			continue
		if(roll_cover(cover))
			return cover
	var/back_dir = turn(move_dir, 180)
	for(var/obj/cover in to_turf)
		if(isnull(cover.projectile_cover_pass))
			continue
		if((cover.flags_1 & ON_BORDER_1) && !(cover.dir & back_dir))
			continue
		if(roll_cover(cover))
			return cover
	return null

/// Kula wpada w osłonę: trafienie w osłonę zamiast w to, co za nią
/obj/item/projectile/proc/hit_cover(obj/cover)
	aq_cover_hit = cover
	Impact(cover)
	aq_cover_hit = null

/obj/item/projectile/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(target && target == aq_cover_hit && !LAZYACCESS(impacted, target) && !deletion_queued)
		return TRUE
	return ..()

/obj/item/projectile/select_target(turf/T, atom/target, atom/bumped)
	if(aq_cover_hit && can_hit_target(aq_cover_hit, ignore_loc = TRUE))
		return aq_cover_hit
	return ..()

// Barierki: kula przelatuje nad nimi bez rzutu w CanPass (latające przechodzą), osłonę liczy silnik pocisku.

// --- Przewracanie stołów ---

/obj/structure/table
	/// Stół leży na boku i osłania od strony dir
	var/flipped = FALSE
	/// Przedrostek stanów przewróconego stołu w ikonie (Paradise: tableflip0, woodflip1+...); null = nie da się przewrócić
	var/flip_state_prefix = "table"

/obj/structure/table/glass
	flip_state_prefix = null

/obj/structure/table/wood
	flip_state_prefix = "wood"

/obj/structure/table/wood/poker
	flip_state_prefix = "poker"

/obj/structure/table/wood/fancy
	flip_state_prefix = null

/obj/structure/table/reinforced
	flip_state_prefix = null

/obj/structure/table/brass
	flip_state_prefix = null

/obj/structure/table/bronze
	flip_state_prefix = null

/obj/structure/table/optable
	flip_state_prefix = null

/obj/structure/table/abductor
	flip_state_prefix = null

/obj/structure/table/examine(mob/user)
	. = ..()
	if(flipped)
		. += "<span class='notice'>Leży na boku. <b>Ctrl+Shift+klik</b> stawia go z powrotem.</span>"
	else if(flip_state_prefix)
		. += "<span class='notice'><b>Ctrl+Shift+klik</b> przewraca go na bok jako osłonę (w stronę od ciebie).</span>"

/obj/structure/table/CtrlShiftClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE) || !flip_state_prefix)
		return ..()
	if(flipped)
		unflip_table(user)
	else
		flip_table(user)

/obj/structure/table/proc/flip_table(mob/living/user)
	var/flip_dir = get_cardinal_dir(user, src)
	if(!flip_dir)
		return
	user.visible_message("<span class='warning'>[user] zaczyna przewracać [src]!</span>", "<span class='notice'>Zaczynasz przewracać [src].</span>")
	if(!do_after(user, 1 SECONDS, target = src) || flipped)
		return
	set_flipped(TRUE, flip_dir)
	user.visible_message("<span class='danger'>[user] przewraca [src]!</span>", "<span class='notice'>Przewracasz [src].</span>")
	playsound(src, 'sound/items/trayhit2.ogg', 70, TRUE)

/obj/structure/table/proc/unflip_table(mob/living/user)
	user.visible_message("<span class='notice'>[user] zaczyna stawiać [src].</span>", "<span class='notice'>Zaczynasz stawiać [src].</span>")
	if(!do_after(user, 1.5 SECONDS, target = src) || !flipped)
		return
	for(var/obj/structure/table/other in loc)
		if(other != src && !other.flipped)
			to_chat(user, "<span class='warning'>Tu już stoi stół.</span>")
			return
	set_flipped(FALSE)
	user.visible_message("<span class='notice'>[user] stawia [src].</span>", "<span class='notice'>Stawiasz [src].</span>")
	playsound(src, 'sound/items/trayhit1.ogg', 50, TRUE)

/obj/structure/table/proc/set_flipped(new_state, new_dir)
	flipped = new_state
	if(flipped)
		setDir(new_dir)
		flags_1 |= ON_BORDER_1
		projectile_cover_pass = 25
		climbable = TRUE
		layer = (new_dir == NORTH) ? BELOW_MOB_LAYER : ABOVE_MOB_LAYER
	else
		setDir(SOUTH)
		flags_1 &= ~ON_BORDER_1
		projectile_cover_pass = null
		layer = initial(layer)
	update_flipped_neighbours()

/obj/structure/table/proc/update_flipped_neighbours()
	bitmask_smooth_icon()
	for(var/direction in GLOB.alldirs)
		for(var/obj/structure/table/other in get_step(src, direction))
			if(other.bitmask_smooth)
				other.bitmask_smooth_icon()

/obj/structure/table/bitmask_smooth_icon()
	if(!flipped)
		return ..()
	// Paradise: tableflip0 (sam), tableflip1+ / tableflip1- (sąsiad z jednej strony), tableflip2 (z obu)
	var/neighbours = 0
	var/side = ""
	for(var/direction in list(turn(dir, 90), turn(dir, -90)))
		for(var/obj/structure/table/other in get_step(src, direction))
			if(other.flipped && other.dir == dir && other.flip_state_prefix == flip_state_prefix)
				neighbours++
				if(neighbours == 1)
					side = (direction == turn(dir, 90)) ? "-" : "+"
				break
	icon_state = "[flip_state_prefix]flip[neighbours][neighbours == 1 ? side : ""]"

// Przewrócony stół blokuje przejście tylko przez swoją krawędź (jak barierka)
/obj/structure/table/CanAllowThrough(atom/movable/mover, turf/target)
	if(!flipped)
		return ..()
	. = ..()
	if(istype(mover, /obj/item/projectile))
		return TRUE // kulę zatrzymuje albo nie silnik pocisku (check_cover)
	if(!(get_dir(loc, target) & dir))
		return TRUE
	if(mover.throwing || (mover.movement_type & (FLYING | FLOATING)))
		return TRUE

/obj/structure/table/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_flipped_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/proc/on_flipped_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(!flipped || !(direction & dir) || leaving == src)
		return
	if(isprojectile(leaving) || leaving.throwing || (leaving.movement_type & (FLYING | FLOATING)))
		return
	if(leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

// Na przewróconym stole nic się nie położy
/obj/structure/table/attackby(obj/item/I, mob/living/user, params)
	if(flipped && !(I.tool_behaviour in list(TOOL_WRENCH, TOOL_SCREWDRIVER, TOOL_WELDER)) && !user.combat_mode)
		to_chat(user, "<span class='warning'>[src] leży na boku.</span>")
		return TRUE
	return ..()
