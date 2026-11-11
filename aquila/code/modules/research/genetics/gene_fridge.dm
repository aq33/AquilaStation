// AQUILA - gablota DNA: odpowiednik lodówki chemika dla genetyka.
// Genetyk wystawia w niej iniektory DNA i chromosomy, a załoga widzi przy każdym iniektorze,
// jakie mutacje daje lub usuwa, ich opis i niestabilność.

/obj/machinery/smartfridge/genetics
	name = "gablota DNA"
	desc = "Chłodzona gablota, w której genetyk wystawia iniektory DNA i chromosomy. Przy każdym iniektorze widać, co robi."
	contents_overlay_icon = "viro"

/obj/machinery/smartfridge/genetics/accept_check(obj/item/O)
	if(O.item_flags & ABSTRACT)
		return FALSE
	if(istype(O, /obj/item/dnainjector))
		var/obj/item/dnainjector/injector = O
		return !injector.used
	return istype(O, /obj/item/chromosome)

/obj/machinery/smartfridge/genetics/ui_data(mob/user)
	. = ..()
	var/list/listofitems = .["contents"]
	for(var/obj/item/stored in src)
		if(stored in component_parts)
			continue
		var/key = smartfridge_item_key(stored)
		if(listofitems[key] && isnull(listofitems[key]["desc"]))
			listofitems[key]["desc"] = gene_fridge_desc(stored)

/// Konsola DNA nazywa każdy aktywator „aktywator DNA”, a każdy mutator „mutator DNA”, więc grupowanie po typie i nazwie
/// sklejałoby różne mutacje w jeden wiersz. Klucz i nazwa w oknie zawierają więc mutacje iniektora.
/obj/machinery/smartfridge/genetics/smartfridge_item_key(atom/movable/stored)
	. = ..()
	var/list/mutations = gene_fridge_mutation_names(stored)
	if(length(mutations))
		. += "|[jointext(mutations, ",")]"

/obj/machinery/smartfridge/genetics/smartfridge_display_name(atom/movable/stored)
	. = ..()
	var/list/mutations = gene_fridge_mutation_names(stored)
	if(length(mutations))
		. += " ([jointext(mutations, ", ")])"

/// Nazwy mutacji, które iniektor daje (posortowane, żeby ta sama kombinacja dawała ten sam klucz)
/obj/machinery/smartfridge/genetics/proc/gene_fridge_mutation_names(atom/movable/stored)
	var/list/names = list()
	if(!istype(stored, /obj/item/dnainjector))
		return names
	var/obj/item/dnainjector/injector = stored
	for(var/mutation in injector.add_mutations)
		var/datum/mutation/info = gene_fridge_mutation(mutation)
		if(info)
			names += info.name
	return sortList(names)

/// Opis przedmiotu w oknie gabloty jako lista linii (każdą tłumaczy się osobno): mutacje z iniektora albo opis chromosomu
/obj/machinery/smartfridge/genetics/proc/gene_fridge_desc(obj/item/stored)
	if(istype(stored, /obj/item/chromosome))
		return list(stored.desc)
	if(!istype(stored, /obj/item/dnainjector))
		return list()
	var/obj/item/dnainjector/injector = stored
	var/list/parts = list()
	for(var/mutation in injector.add_mutations)
		var/datum/mutation/info = gene_fridge_mutation(mutation)
		if(!info)
			continue
		parts += "Daje: [info.name]"
		if(info.instability)
			parts += "Niestabilność: [info.instability]"
		if(info.desc)
			parts += info.desc
	for(var/mutation in injector.remove_mutations)
		var/datum/mutation/info = gene_fridge_mutation(mutation)
		if(info)
			parts += "Usuwa: [info.name]"
	if(injector.fields)
		parts += "Zmienia wygląd lub tożsamość według zapisanego DNA"
	if(!length(parts))
		return list("Nie zawiera znanych mutacji")
	return parts

/// Iniektory trzymają mutacje jako typy (gotowe iniektory) albo jako obiekty (iniektory z konsoli DNA)
/obj/machinery/smartfridge/genetics/proc/gene_fridge_mutation(mutation)
	if(istype(mutation, /datum/mutation))
		return mutation
	if(ispath(mutation, /datum/mutation))
		return GET_INITIALIZED_MUTATION(mutation)

/// Płytkę lodówki przestawia się śrubokrętem między typami; gablota DNA dochodzi do listy
/obj/item/circuitboard/machine/smartfridge/Initialize(mapload, new_type)
	if(!fridges_name_paths[/obj/machinery/smartfridge/genetics])
		fridges_name_paths[/obj/machinery/smartfridge/genetics] = "DNA"
	return ..()
