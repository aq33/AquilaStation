/// AQUILA - TGUI chemical menu in place of the old HTML window (horror_html.dm)
/datum/horror_chem_menu
	var/mob/living/simple_animal/horror/owner

/datum/horror_chem_menu/New(mob/living/simple_animal/horror/new_owner)
	. = ..()
	owner = new_owner

/datum/horror_chem_menu/Destroy()
	owner = null
	return ..()

/datum/horror_chem_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/horror_chem_menu/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(owner) || user != owner)
		return UI_CLOSE
	return ..()

/datum/horror_chem_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HorrorChemicals", "Chemikalia horroru")
		ui.open()

/datum/horror_chem_menu/ui_data(mob/user)
	var/list/data = list()
	data["chemicals"] = owner.chemicals
	data["has_host"] = !!owner.victim
	var/list/chems = list()
	for(var/datum/horror_chem/chem as anything in subtypesof(/datum/horror_chem))
		if(!(chem in owner.horror_chems))
			continue
		chems += list(list(
			"path" = "[chem]",
			"name" = initial(chem.chemname),
			"cost" = initial(chem.chemuse),
			"desc" = initial(chem.chem_desc),
		))
	data["chems"] = chems
	return data

/datum/horror_chem_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "use_chem")
		return
	var/chem_path = text2path(params["path"])
	if(!ispath(chem_path, /datum/horror_chem) || !(chem_path in owner.horror_chems))
		return
	owner.inject_horror_chem(chem_path)
	return TRUE

/mob/living/simple_animal/horror/proc/inject_horror_chem(chem_path)
	var/datum/horror_chem/C = new chem_path()

	if(!victim || controlling || stat)
		return

	if(chemicals < C.chemuse)
		to_chat(src, "<span class='boldnotice'>Potrzebujesz [C.chemuse] zgromadzonych chemikaliów, by użyć tej substancji!</span>")
		return

	to_chat(src, "<span class='danger'>Wstrzykujesz [C.quantity] jednostek [C.chemname] ze swoich zbiorników do krwiobiegu [victim].</span>")
	victim.reagents.add_reagent(C.R, C.quantity)
	chemicals -= C.chemuse
	log_game("[src]/([src.ckey]) has injected [C.chemname] into their host [victim]/([victim.ckey])")

/datum/horror_chem
	var/chemname
	var/chem_desc = "To jest substancja chemiczna."
	var/datum/reagent/R
	var/chemuse = 30
	var/quantity = 10

/datum/horror_chem/epinephrine
	chemname = "epinephrine"
	R = /datum/reagent/medicine/epinephrine
	chem_desc = "Stabilizuje stan krytyczny i powoli leczy niedotlenienie."

/datum/horror_chem/mannitol
	chemname = "mannitol"
	R = /datum/reagent/medicine/mannitol
	chem_desc = "Leczy uszkodzenia mózgu."

/datum/horror_chem/bicaridine
	chemname = "bicaridine"
	R = /datum/reagent/medicine/bicaridine
	chem_desc = "Leczy obrażenia fizyczne."

/datum/horror_chem/kelotane
	chemname = "kelotane"
	R = /datum/reagent/medicine/kelotane
	chem_desc = "Leczy oparzenia."

/datum/horror_chem/charcoal
	chemname = "charcoal"
	R = /datum/reagent/medicine/charcoal
	chem_desc = "Powoli leczy zatrucia i stopniowo usuwa z organizmu inne substancje."

/datum/horror_chem/adrenaline
	chemname = "adrenaline"
	R = /datum/reagent/medicine/changelingadrenaline
	chemuse = 100
	chem_desc = "Pobudza mózg, pozwalając otrząsnąć się z ogłuszeń i regenerując wytrzymałość."

/datum/horror_chem/rezadone
	chemname = "rezadone"
	R = /datum/reagent/medicine/rezadone
	chemuse = 50
	chem_desc = "Leczy uszkodzenia komórkowe."

/datum/horror_chem/pen_acid
	chemname = "pentetic acid"
	R = /datum/reagent/medicine/pen_acid
	chemuse = 50
	chem_desc = "Mocno redukuje napromieniowanie i zatrucia, usuwając z organizmu inne substancje."

/datum/horror_chem/sal_acid
	chemname = "salicylic acid"
	R = /datum/reagent/medicine/sal_acid
	chem_desc = "Przyspiesza gojenie ciężkich stłuczeń. Szybko leczy poważne obrażenia fizyczne, a lżejsze powoli."

/datum/horror_chem/oxandrolone
	chemname = "oxandrolone"
	R = /datum/reagent/medicine/oxandrolone
	chem_desc = "Przyspiesza gojenie ciężkich oparzeń. Szybko leczy poważne oparzenia, a lżejsze powoli."
