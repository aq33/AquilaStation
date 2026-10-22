// Machines from other modules that can be fed by plumbing, like on tg

// Tace hydroponiczne z nowej botaniki (Bee) mają własny komponent plumbing/tank

/obj/machinery/limbgrower/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)
