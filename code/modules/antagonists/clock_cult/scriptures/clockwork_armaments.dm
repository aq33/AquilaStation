//==================================//
// !           Armaments          ! //
//==================================//
/datum/clockcult/scripture/clockwork_armaments
	name = "Mechaniczne uzbrojenie"
	desc = "Przywołujesz mechaniczną zbroję i broń, by być gotowym do walki."
	tip = "Przywołuje mechaniczną zbroję i broń, byś był gotów do walki."
	button_icon_state = "clockwork_armor"
	power_cost = 150
	invokation_time = 20
	invokation_text = list("Dzięki odwadze i nadziei...", "...będziemy cię chronić!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 0

/datum/clockcult/scripture/clockwork_armaments/invoke_success()
	var/mob/living/M = invoker
	var/choice = input(M,"Jaką broń chcesz przywołać?", "Mechaniczne Uzbrojenie") as anything in list("Mosiężna włócznia","Mosiężny młot bojowy","Mosiężny miecz", "Mosiężny łuk", "Standardowy ekwipunek (bez broni)")
	var/datum/antagonist/servant_of_ratvar/servant = is_servant_of_ratvar(M)
	if(!servant)
		return FALSE
	//Equip mob with gamer gear
	var/static/datum/outfit/clockcult/armaments/armaments_spear = new
	var/static/datum/outfit/clockcult/armaments/hammer/armaments_hammer = new
	var/static/datum/outfit/clockcult/armaments/sword/armaments_sword = new
	var/static/datum/outfit/clockcult/armaments/bow/armaments_bow = new
	var/static/datum/outfit/clockcult/default = new
	var/static/datum/outfit/clockcult_plasmaman/plasmaman = new
	if(is_species(M, /datum/species/plasmaman))
		plasmaman.equip(M)
	switch(choice)
		if("Mosiężna włócznia")
			armaments_spear.equip(M)
		if("Mosiężny młot bojowy")
			armaments_hammer.equip(M)
		if("Mosiężny miecz")
			armaments_sword.equip(M)
		if("Mosiężny łuk")
			armaments_bow.equip(M)
		if("Standardowy ekwipunek (bez broni)")
			default.equip(M)
