/datum/design/shield_fan
{
	name = "Wentylator chłodzący generatora tarczy";
	desc = "Podzespół potrzebny do zbudowania generatora tarczy.";
	id = "shield_fan";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 4000, /datum/material/glass = 1000);
	build_path = /obj/item/shield_component/fan;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_capacitor
{
	name = "Kondensator strumienia";
	desc = "Podzespół potrzebny do zbudowania generatora tarczy.";
	id = "shield_capacitor";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000);
	build_path = /obj/item/shield_component/capacitor;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}


/datum/design/shield_modulator
{
	name = "Modulator tarczy";
	desc = "Podzespół potrzebny do zbudowania generatora tarczy.";
	id = "shield_modulator";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 10000, /datum/material/diamond = 10000);
	build_path = /obj/item/shield_component/modulator;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_interface
{
	name = "Interfejs kryształu bluespace";
	desc = "Podzespół potrzebny do zbudowania generatora tarczy.";
	id = "shield_interface";
	build_type = PROTOLATHE;
	materials = list(/datum/material/titanium = 10000, /datum/material/bluespace = MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 10000);
	build_path = /obj/item/shield_component/interface;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_frame
{
	name = "Rama generatora tarczy";
	desc = "Podstawowa rama generatora tarczy. Wymaga montażu, części sprzedawane osobno.";
	id = "shield_frame";
	build_type = PROTOLATHE;
	materials = list(/datum/material/titanium = 20000, /datum/material/iron = 20000);
	build_path = /obj/structure/shieldgen_frame;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}
