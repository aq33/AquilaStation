/obj/effect/decal/nuclear_waste
	name = "szlam plutonowy"
	desc = "Wijąca się kałuża silnie napromieniowanego, zużytego paliwa reaktorowego. Lepiej w to nie wchodzić..."
	icon = 'nsv13/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150
	light_color = LIGHT_COLOR_CYAN
	color = "#ff9eff"

/obj/effect/decal/nuclear_waste/Initialize(mapload)
	. = ..()
	set_light(3)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/nuclear_waste/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)

/obj/effect/decal/nuclear_waste/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(isliving(AM))
		var/mob/living/L = AM
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)
	radiation_pulse(src, max_range = 1, threshold = RAD_EXTREME_INSULATION, intensity = 15) // AQ EDIT - promieniowanie z Bee#13442

/obj/effect/decal/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		radiation_pulse(src, max_range = 1, threshold = RAD_EXTREME_INSULATION, intensity = 20) // AQ EDIT - promieniowanie z Bee#13442
		to_chat(user, "<span class='notice'>Zaczynasz usuwać [src]...</span>")
		if(tool.use_tool(src, user, 50, volume=100))
			to_chat(user, "<span class='notice'>Usuwasz [src]. </span>")
			qdel(src)
			return
	. = ..()

/obj/effect/decal/nuclear_waste/epicenter //The one that actually does the irradiating. This is to avoid every bit of sludge PROCESSING
	name = "gęsty szlam jądrowy"


/obj/effect/decal/nuclear_waste/epicenter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radioactive, 3, RAD_EXTREME_INSULATION, 5) // AQ EDIT - promieniowanie z Bee#13442 (Bee usunął promieniowanie epicentrum)
