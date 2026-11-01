/obj/machinery/the_singularitygen/tesla
	name = "generator kuli energii"
	desc = "Po ostrzale z akceleratora cząstek sprawia, że Wardenclyffe wygląda przy nim jak dziecięca zabawka."
	icon = 'icons/obj/tesla_engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/anomaly/energy_ball

/obj/machinery/the_singularitygen/tesla/tesla_act(power, tesla_flags)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		energy += power
