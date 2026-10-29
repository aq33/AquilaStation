// AQUILA - draft (za vg) zastępował całą świecę /obj/item/candle. U nas zwykła świeca jest w core
// (code/game/objects/items/candle.dm) i używa jej wiele miejsc, więc tu zostaje tylko krwawa świeca kultu
// jako podtyp naszej świecy, z wyglądem, cząsteczkami płomienia i migotaniem z draftu.

/obj/item/candle/blood
	name = "krwawa świeca"
	desc = "Świeca z wosku krwawych ciem. Pali się znacznie dłużej niż zwykłe świece. Służy do nastrojowego oświetlenia i okultystycznych rytuałów."
	icon = 'aquila/icons/bloodcult/candle.dmi'
	icon_state = "bloodcandle"
	item_state = "candle1"
	wax = 3600 // 60 minutes
	var/flickering = 0

/obj/item/candle/blood/get_cult_power()
	return 1

/obj/item/candle/blood/update_icon()
	overlays.len = 0
	if (wax == initial(wax))
		icon_state = "bloodcandle"
	else
		var/i
		if(wax > 2400)
			i = 1
		else if(wax > 1200)
			i = 2
		else i = 3
		icon_state = "bloodcandle[i]"
	if (lit)
		var/image/I = image(icon, src, "[icon_state]_lit")
		I.blend_mode = BLEND_ADD
		if (isturf(loc))
			I.plane = ABOVE_LIGHTING_PLANE
		else
			I.plane = ABOVE_HUD_PLANE // inventory
		overlays += I

/obj/item/candle/blood/dropped()
	..()
	update_icon()

/obj/item/candle/blood/light(show_message)
	var/was_lit = lit
	. = ..()
	if(!was_lit && lit)
		add_particles(PS_CANDLE)
		add_particles(PS_CANDLE2)

/obj/item/candle/blood/put_out_candle()
	. = ..()
	if(.)
		remove_particles(PS_CANDLE)
		remove_particles(PS_CANDLE2)

/obj/item/candle/blood/process(delta_time)
	if(!lit)
		return PROCESS_KILL
	if(!infinite)
		wax -= delta_time
	if(wax <= 0)
		new /obj/item/trash/blood_candle(loc)
		qdel(src)
		return
	update_icon()
	open_flame()

/obj/item/candle/blood/proc/flicker(amount = rand(5, 15))
	set waitfor = FALSE
	if(flickering)
		return
	flickering = 1
	if(lit)
		for(var/i = 0; i < amount; i++)
			if(prob(95))
				if(prob(30))
					extinguish()
				else
					var/candleflick = pick(0.5, 0.7, 0.9, 1, 1.3, 1.5, 2)
					set_light(candleflick * 0.7)
			else
				set_light(5 * 0.7)
				visible_message(span_warning("Płomień [src] zaczyna nienaturalnie huczeć!") )
			update_icon()
			sleep(rand(5, 8))
			set_light(1)
			lit = 1
			update_icon()
	flickering = 0

/obj/item/candle/blood/attack_ghost(mob/user)
	add_hiddenprint(user)
	flicker(1)

/obj/item/trash/blood_candle
	name = "krwawa świeca"
	desc = "Ogarek świecy z wosku krwawych ciem."
	icon = 'aquila/icons/bloodcult/candle.dmi'
	icon_state = "bloodcandle4"
