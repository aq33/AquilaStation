/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/antag_spawner/contract
	name = "kontrakt"
	desc = "Magiczny kontrakt podpisany wcześniej przez ucznia. W zamian za naukę sztuk magicznych jest zobowiązany odpowiedzieć na twoje wezwanie o pomoc."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	/// AQ EDIT - czy właśnie trwa szukanie ucznia wśród duchów
	var/polling = FALSE

// AQ EDIT - okno TGUI ApprenticeContract (port z tg) zamiast okna HTML
/obj/item/antag_spawner/contract/attack_self(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>Już przywołano twojego ucznia.</span>")
		return
	ui_interact(user)

/obj/item/antag_spawner/contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApprenticeContract", name)
		ui.open()

/obj/item/antag_spawner/contract/ui_state(mob/user)
	if(used)
		return GLOB.never_state
	return GLOB.default_state

/obj/item/antag_spawner/contract/ui_data(mob/user)
	var/list/data = list()
	data["polling"] = polling
	return data

/obj/item/antag_spawner/contract/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			var/mob/living/carbon/human/H = usr
			if(used || polling || !ishuman(H))
				return
			if(H.stat || H.restrained())
				return
			var/selected_school = params["school"]
			if(!(selected_school in list(APPRENTICE_DESTRUCTION, APPRENTICE_BLUESPACE, APPRENTICE_HEALING, APPRENTICE_ROBELESS, APPRENTICE_WILDMAGIC)))
				return
			INVOKE_ASYNC(src, PROC_REF(poll_for_student), H, selected_school)
			SStgui.close_uis(src)
			return TRUE

/obj/item/antag_spawner/contract/proc/poll_for_student(mob/living/carbon/human/teacher, apprentice_school)
	to_chat(teacher, "<span class='notice'>Próbujesz nawiązać kontakt z uczniem...</span>")
	polling = TRUE
	var/list/candidates = pollGhostCandidates("Chcesz zagrać jako uczeń czarodzieja (szkoła: [apprentice_school])?", ROLE_WIZARD, /datum/role_preference/midround_ghost/wizard, 15 SECONDS, ignore_category = POLL_IGNORE_WIZARD_HELPER)
	polling = FALSE
	if(!LAZYLEN(candidates))
		to_chat(teacher, "Nie udało się skontaktować z uczniem! Możesz uderzyć umową w księgę zaklęć, żeby odzyskać punkty, albo spróbować ponownie później.")
		return
	if(QDELETED(src))
		return
	if(used)
		to_chat(teacher, "Ta umowa została już wykorzystana!")
		return
	used = TRUE
	var/mob/dead/observer/C = pick(candidates)
	spawn_antag(C.client, get_turf(src), apprentice_school, teacher.mind)

/obj/item/antag_spawner/contract/spawn_antag(client/C, turf/T, kind ,datum/mind/user)
	new /obj/effect/particle_effect/smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.active_character.copy_to(M)
	M.key = C.key
	var/datum/mind/app_mind = M.mind

	var/datum/antagonist/wizard/apprentice/app = new()
	app.master = user
	app.school = kind

	var/datum/antagonist/wizard/master_wizard = user.has_antag_datum(/datum/antagonist/wizard)
	if(master_wizard)
		if(!master_wizard.wiz_team)
			master_wizard.create_wiz_team()
		app.wiz_team = master_wizard.wiz_team
		master_wizard.wiz_team.add_member(app_mind)
	app_mind.add_antag_datum(app)
	//TODO Kill these if possible
	app_mind.assigned_role = "Apprentice"
	app_mind.special_role = "apprentice"
	//
	SEND_SOUND(M, sound('sound/effects/magic.ogg'))

///////////BORGS AND OPERATIVES


/obj/item/antag_spawner/nuke_ops
	name = "teleporter operatora Syndykatu"
	desc = "Jednorazowy teleporter do szybkiego wzmacniania agentów w terenie."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] nie ma energii!</span>")
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE))
		to_chat(user, "<span class='danger'>BŁĄD UWIERZYTELNIANIA. ODMOWA DOSTĘPU.</span>")
		return FALSE
	if(is_station_level(user.z)) //Nsv13 - Changed to allow spawning on syndie pvp ships
		to_chat(user, "<span class='warning'>[src] jest poza zasięgiem! Można go użyć tylko w twojej bazie!</span>")
		return FALSE
	return TRUE


/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, "<span class='notice'>Aktywujesz [src] i czekasz na potwierdzenie.</span>")
	var/list/nuke_candidates = pollGhostCandidates("Chcesz zagrać jako [borg_to_spawn ? "cyborg Syndykatu ([lowertext(borg_to_spawn)])":"operator Syndykatu"]?", ROLE_OPERATIVE, /datum/role_preference/midround_ghost/nuclear_operative, 15 SECONDS)
	if(LAZYLEN(nuke_candidates))
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), "syndieborg", user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>Nie można połączyć się z dowództwem Syndykatu. Spróbuj ponownie później albo użyj teleportera na uplinku, żeby odzyskać punkty.</span>")

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.active_character.copy_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/new_op = new()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op,creator_op.nuke_team)
		M.mind.special_role = "Nuclear Operative"

//////CLOWN OP
/obj/item/antag_spawner/nuke_ops/clown
	name = "teleporter klauna-operatora"
	desc = "Jednorazowy teleporter do szybkiego wzmacniania agentów-klaunów w terenie."

/obj/item/antag_spawner/nuke_ops/clown/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.active_character.copy_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/clownop/new_op = new /datum/antagonist/nukeop/clownop()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/clownop/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop/clownop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op, creator_op.nuke_team)
		M.mind.special_role = "Clown Operative"


//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "teleporter cyborga Syndykatu"
	desc = "Jednorazowy teleporter do szybkiego wzmacniania agentów w terenie."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "teleporter szturmowego cyborga Syndykatu"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "teleporter medycznego cyborga Syndykatu"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "teleporter sabotażowego cyborga Syndykatu"
	borg_to_spawn = "Saboteur"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/silicon/robot/R
	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(!creator_op)
		return

	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/modules/syndicate/medical(T)
		if("Saboteur")
			R = new /mob/living/silicon/robot/modules/syndicate/saboteur(T)
		else
			R = new /mob/living/silicon/robot/modules/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = human_last_name_random()
	if(creator_op.nuke_team.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = creator_op.nuke_team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "[initial(R.mmi.name)]: [brainopsname]"
	R.mmi.brain.name = "mózg [brainopsname]"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname
	R.real_name = R.name

	R.key = C.key

	var/datum/antagonist/nukeop/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	R.mind.add_antag_datum(new_borg,creator_op.nuke_team)
	R.mind.special_role = "Syndicate Cyborg"

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "fiolka krwi"
	desc = "Magicznie nasycona butelka krwi, destylowana z niezliczonych ofiar morderstw. Używana w bezbożnych rytuałach do przywabiania przerażających stworzeń."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	var/shatter_msg = "<span class='notice'>Rozbijasz butelkę, nie ma już odwrotu!</span>"
	var/veil_msg = "<span class='warning'>Wyczuwasz mroczną obecność czającą się tuż za zasłoną...</span>"
	var/mob/living/demon_type = /mob/living/simple_animal/slaughter
	var/antag_type = /datum/antagonist/slaughter


/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(!is_station_level(user.z))
		to_chat(user, "<span class='notice'>Lepiej zaczekaj, aż dotrzesz na statek.</span>")
		return
	if(used)
		return
	var/list/candidates = pollGhostCandidates("Chcesz zagrać jako [initial(demon_type.name)]?", ROLE_SLAUGHTER_DEMON, null, 10 SECONDS, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		if(used || QDELETED(src))
			return
		used = TRUE
		var/mob/dead/observer/C = pick(candidates)
		spawn_antag(C.client, get_turf(src), initial(demon_type.name),user.mind)
		to_chat(user, shatter_msg)
		to_chat(user, veil_msg)
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>Nie możesz się zebrać na odwagę, żeby rozbić butelkę. Może spróbuj później.</span>")


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	var/obj/effect/dummy/phased_mob/slaughter/holder = new /obj/effect/dummy/phased_mob/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new demon_type(holder)
	S.holder = holder
	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	S.mind.add_antag_datum(antag_type)
	to_chat(S, S.playstyle_string)
	to_chat(S, "<B>Obecnie nie przebywasz na tym samym planie egzystencji co statek. \
	Kliknij z Ctrl kałużę krwi, żeby się zmaterializować.</B>")

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "fiolka łaskotek"
	desc = "Magicznie nasycona butelka klauniej miłości, destylowana z niezliczonych ataków przytulania. Używana w zabawnych rytuałach do przywabiania uroczych stworzeń."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = "<span class='warning'>Wyczuwasz uroczą obecność czającą się tuż za zasłoną...</span>"
	demon_type = /mob/living/simple_animal/slaughter/laughter
	antag_type = /datum/antagonist/slaughter/laughter

///////////GANGSTER REINFORCEMENT SPAWNER

/obj/item/antag_spawner/gangster
	name = "wzywacz oprychów"
	desc = "Niech kwatera główna przyśle ci oprycha, który właśnie rzucił liceum i jest gotów na pierwszą linię. Przychodzi w stroju twojej bandy i z farbą w sprayu w ręce."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"


/obj/item/antag_spawner/gangster/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, "<span class='notice'>Aktywujesz [src] i czekasz na potwierdzenie.</span>")
	var/list/candidates = pollGhostCandidates("Chcesz zagrać jako posiłki gangu?", ROLE_GANG, /datum/role_preference/antagonist/gangster, 15 SECONDS)
	if(LAZYLEN(candidates))
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(candidates)
		spawn_antag(G.client, get_turf(src), user.mind)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>Brak odpowiedzi z kwatery głównej. Spróbuj ponownie później.</span>")

/obj/item/antag_spawner/gangster/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] nie ma energii!</span>")
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/gang,TRUE))
		to_chat(user, "<span class='danger'>BŁĄD UWIERZYTELNIANIA. ODMOWA DOSTĘPU.</span>")
		return FALSE
	return TRUE

/obj/item/antag_spawner/gangster/spawn_antag(client/C, turf/T, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	if (C)
		C.prefs.active_character.copy_to(M)
		M.key = C.key

	var/datum/antagonist/gang/alignment = user.has_antag_datum(/datum/antagonist/gang,TRUE)
	if(alignment)
		M.mind.add_antag_datum(/datum/antagonist/gang, alignment)
		M.equip_to_slot_or_del(new alignment.gang.outfit(M),ITEM_SLOT_ICLOTHING)
		M.equip_to_slot_or_del(new alignment.gang.suit(M),ITEM_SLOT_OCLOTHING)
		M.equip_to_slot_or_del(new alignment.gang.hat(M),ITEM_SLOT_HEAD)

	M.mind.special_role = "Gangster"
	M.equipOutfit(/datum/outfit/crook)
