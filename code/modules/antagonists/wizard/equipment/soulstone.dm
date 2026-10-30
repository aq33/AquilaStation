/obj/item/soulstone
	name = "odłamek kamienia duszy"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	layer = HIGH_OBJ_LAYER
	desc = "Fragment legendarnego skarbu znanego po prostu jako „Kamień Duszy”. W odłamku wciąż migocze cząstka mocy całego artefaktu."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	var/usability = FALSE

	var/old_shard = FALSE
	var/spent = FALSE
	var/purified = FALSE

/obj/item/soulstone/proc/was_used()
	if(old_shard)
		spent = TRUE
		name = "[name] (bez mocy)"
		desc = "Fragment legendarnego skarbu znanego po prostu jako \
			„Kamień Duszy”. Odłamek leży nieruchomo, matowy i martwy; \
			iskra, którą kiedyś w sobie nosił, dawno zgasła."

/obj/item/soulstone/anybody
	usability = TRUE

/obj/item/soulstone/anybody/revolver
	old_shard = TRUE

/obj/item/soulstone/anybody/purified
	icon = 'icons/obj/wizard.dmi'
	icon_state = "purified_soulstone"
	purified = TRUE


/obj/item/soulstone/anybody/chaplain
	name = "tajemniczy stary odłamek"
	old_shard = TRUE

/obj/item/soulstone/pickup(mob/living/user)
	..()
	if(!iscultist(user) && !iswizard(user) && !usability)
		to_chat(user, "<span class='danger'>Gdy podnosisz kamień dusz, ogarnia cię przytłaczające uczucie grozy. Lepiej szybko się go pozbyć.</span>")

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(usability || iscultist(user) || iswizard(user) || isobserver(user))
		if (old_shard)
			. += "<span class='cult'>Kamień dusz, służący do chwytania duszy zmarłych ludzi albo uwolnionych cieni.</span>"
		else
			. += "<span class='cult'>Kamień dusz, służący do chwytania dusz nieprzytomnych lub śpiących ludzi albo uwolnionych cieni.</span>"
		. += "<span class='cult'>Schwytaną duszę można umieścić w powłoce konstruktu, by stworzyć konstrukt, albo uwolnić z kamienia jako cień.</span>"
		if(spent)
			. += "<span class='cult'>Ten odłamek jest zużyty; to teraz tylko upiorny kamień.</span>"

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/A in src)
		A.death()
	return ..()

/obj/item/soulstone/Exited(mob/living/simple_animal/shade/S, atom/newLoc)
	..()
	if(istype(S))
		// Things that *really should always* happen to the shade when it comes out should go here.
		S.status_flags &= ~GODMODE
		S.mobility_flags = MOBILITY_FLAGS_DEFAULT
		S.cancel_camera()
		if(purified)
			S.icon_state = "ghost1"
			S.name = "Oczyszczony [initial(S.name)]"

/obj/item/soulstone/proc/hot_potato(mob/living/user)
	to_chat(user, "<span class='userdanger'>Święta magia zaklęta w [src] parzy ci dłoń!</span>")
	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	affecting.receive_damage( 0, 10 )	// 10 burn damage
	user.emote("scream")
	user.update_damage_overlays()
	user.dropItemToGround(src)

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(!iscultist(user) && !iswizard(user) && !usability)
		user.Unconscious(100)
		to_chat(user, "<span class='userdanger'>Twoje ciało przeszywa obezwładniający ból!</span>")
		return
	if(spent)
		to_chat(user, "<span class='warning'>W odłamku nie została już żadna moc.</span>")
		return
	if(!ishuman(M))//If target is not a human.
		return ..()
	if(M.mind && !M.mind.hasSoul)
		to_chat(user, "<span class='warning'>Ta osoba nie ma duszy!</span>")
		return
	if(iscultist(M))
		if(iscultist(user))
			to_chat(user, "<span class='cultlarge'>\"No już, nie chwytaj duszy swojego brata.\"</span>")
			return
	if(purified && iscultist(user))
		hot_potato(user)
		return
	log_combat(user, M, "captured [M.name]'s soul", src)
	transfer_soul("VICTIM", M, user)

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return
	if(!iscultist(user) && !iswizard(user) && !usability)
		user.Unconscious(100)
		to_chat(user, "<span class='userdanger'>Twoje ciało przeszywa obezwładniający ból!</span>")
		return
	if(purified && iscultist(user))
		hot_potato(user)
		return
	release_shades(user)

/obj/item/soulstone/proc/release_shades(mob/user)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(get_turf(user))
		if(purified)
			icon_state = "purified_soulstone"
		else
			icon_state = "soulstone"
		name = initial(name)
		if(iswizard(user) || usability)
			to_chat(A, "<b>Zostajesz uwolniony z więzienia, ale wciąż wiąże cię wola [user.real_name]. Pomóż mu osiągnąć cele za wszelką cenę.</b>")
		else if(iscultist(user))
			to_chat(A, "<b>Zostajesz uwolniony z więzienia, ale wciąż wiąże cię wola kultu. Pomóż mu osiągnąć cele za wszelką cenę.</b>")
		was_used()

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "pusta powłoka"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct-cult"
	desc = "Złowroga maszyna używana przez biegłych w sztukach magicznych. Jest nieaktywna."

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(iscultist(user) || iswizard(user) || user.stat == DEAD)
		. += "<span class='cult'>Powłoka konstruktu, mieszcząca dusze związane w kamieniu dusz.\n"+\
		"Umieszczenie w niej kamienia z duszą pozwala stworzyć jeden z poniższych konstruktów:\n"+\
		"<b>Rzemieślnika</b>, który tworzy <b>kolejne powłoki i kamienie dusz</b> oraz umocnienia.\n"+\
		"<b>Zjawę</b>, która zadaje duże obrażenia i przenika przez ściany, ale jest dość krucha.\n"+\
		"<b>Juggernauta</b>, którego bardzo trudno zabić i który tworzy tymczasowe ściany, ale jest powolny.</span>"

/obj/structure/constructshell/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!iscultist(user) && !iswizard(user) && !SS.purified)
			to_chat(user, "<span class='danger'>Gdy próbujesz włożyć kamień dusz do powłoki, ogarnia cię przytłaczające uczucie grozy. Lepiej szybko się go pozbyć.</span>")
			user.Dizzy(30)
			return
		if(SS.purified && iscultist(user))
			SS.hot_potato(user)
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/soulstone/proc/transfer_soul(choice as text, target, mob/user)
	switch(choice)
		if("FORCE")
			if(!iscarbon(target))		//TODO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
				return FALSE
			if(contents.len)
				return FALSE
			var/mob/living/carbon/T = target
			if(T.client != null)
				for(var/obj/item/W in T)
					T.dropItemToGround(W)
				init_shade(T, user)
				return TRUE
			else
				to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Dusza opuściła już śmiertelne ciało. Próbujesz ją sprowadzić z powrotem...")
				return getCultGhost(T,user)

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			// AQ EDIT - kult „Cult 4” (Monke #3867): bez blokady celu ofiary
			if(contents.len)
				to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Kamień dusz jest pełny! Uwolnij którąś duszę, żeby zrobić miejsce.")
			else
				if((!old_shard && T.stat != CONSCIOUS) || (old_shard && T.stat == DEAD))
					if(T.client == null)
						to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Dusza opuściła już śmiertelne ciało. Próbujesz ją sprowadzić z powrotem...")
						getCultGhost(T,user)
					else
						if(old_shard) //no insta cremating on the spot
							to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Stary odłamek jest za słaby, by wchłonąć duszę tej istoty.")
							return FALSE
						for(var/obj/item/W in T)
							T.dropItemToGround(W)
						init_shade(T, user, vic = 1)
						qdel(T)
				else
					to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Najpierw zabij lub okalecz ofiarę!")

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(contents.len)
				to_chat(user, "<span class='userdanger'>Nie udało się schwytać!</span>: Kamień dusz jest pełny! Uwolnij którąś duszę, żeby zrobić miejsce.")
			else
				T.forceMove(src) //put shade in stone
				T.status_flags |= GODMODE
				T.mobility_flags = NONE
				T.health = T.maxHealth
				if(purified)
					icon_state = "purified_soulstone2"
					if(iscultist(T))
						T.mind.remove_antag_datum(/datum/antagonist/cult) // AQ EDIT - kult „Cult 4”
				else
					icon_state = "soulstone2"
				name = "kamień duszy: Cień [T.real_name]"
				to_chat(T, "<span class='notice'>Kamień dusz chwyta twoją duszę. Jego tajemne energie odtwarzają twoją eteryczną postać.</span>")
				if(user != T)
					to_chat(user, "<span class='info'><b>Schwytano!</b>:</span> Dusza [T.real_name] została schwytana i zamknięta w kamieniu dusz.")

		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/mob/living/simple_animal/shade/A = locate() in src
			if(A)
				var/construct_class = alert(user, "Wybierz rodzaj konstruktu, który chcesz stworzyć.",,"Juggernaut","Widmo","Rzemieślnik")
				if(!T || !T.loc)
					return
				// AQ EDIT START - kult „Cult 4”: klejnot dusz (perfect) daje doskonałe konstrukty kultystom
				if(perfect && iscultist(user))
					switch(construct_class)
						if("Juggernaut")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored/perfect, A, user, 0, T.loc)
						if("Wraith")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/perfect, A, user, 0, T.loc)
						if("Artificer")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder/perfect, A, user, 0, T.loc)
					construct_class = null
				// AQ EDIT END
				switch(construct_class)
					if("Juggernaut")
						if(iscultist(user) || iswizard(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored/noncult, A, user, 0, T.loc)
					if("Widmo")
						if(iscultist(user) || iswizard(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/noncult, A, user, 0, T.loc)
					if("Rzemieślnik")
						if(iscultist(user) || iswizard(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder/noncult, A, user, 0, T.loc)
				// AQ EDIT - kult „Cult 4”: bez listy SSticker.mode.cult, antag przechodzi z umysłem
				qdel(T)
				qdel(src)
			else
				to_chat(user, "<span class='userdanger'>Nie udało się stworzyć!</span>: Kamień dusz jest pusty! Idź kogoś zabić!")


/proc/makeNewConstruct(mob/living/simple_animal/hostile/construct/ctype, mob/target, mob/stoner = null, cultoverride = 0, loc_override = null)
	if(QDELETED(target))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype((loc_override) ? (loc_override) : (get_turf(target)))
	if(stoner)
		newstruct.faction |= "[REF(stoner)]"
		newstruct.master = stoner
		var/datum/action/innate/seek_master/SM = new()
		SM.Grant(newstruct)
	newstruct.key = target.key
	// AQ EDIT START - kult „Cult 4” (Monke #3867): limit konstruktów kultu, bez alertu bloodsense
	if(newstruct.mind && !iscultist(newstruct) && ((stoner && iscultist(stoner)) || cultoverride) && SSticker.HasRoundStarted())
		var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
		if(cult_team?.CanConvert(newstruct.construct_type))
			newstruct.mind.add_antag_datum(/datum/antagonist/cult)
	// AQ EDIT END
	if(iscultist(stoner) || cultoverride)
		to_chat(newstruct, "<b>Wciąż musisz służyć kultowi[stoner ? " i [stoner]":""]: wykonuj rozkazy i pomagaj osiągnąć cele za wszelką cenę.</b>")
	else if(stoner)
		to_chat(newstruct, "<b>Wciąż musisz służyć swojemu stwórcy, [stoner]: wykonuj jego rozkazy i pomagaj mu osiągnąć cele za wszelką cenę.</b>")
	newstruct.cancel_camera()


/obj/item/soulstone/proc/init_shade(mob/living/carbon/human/T, mob/U, vic = 0)
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.stop_sound_channel(CHANNEL_HEARTBEAT)
	T.invisibility = INVISIBILITY_ABSTRACT
	T.dust_animation()
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade(src)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.mobility_flags = NONE //Can't move out of the soul stone
	S.name = "Cień [T.real_name]"
	S.real_name = "Cień [T.real_name]"
	S.key = T.key
	S.copy_languages(T, LANGUAGE_MIND)//Copies the old mobs languages into the new mob holder.
	S.copy_languages(U, LANGUAGE_MASTER)
	S.update_atom_languages()
	grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
	if(U)
		S.faction |= "[REF(U)]" //Add the master as a faction, allowing inter-mob cooperation
	if(U && iscultist(U))
		S.mind?.add_antag_datum(/datum/antagonist/cult) // AQ EDIT - kult „Cult 4”
	S.cancel_camera()
	name = "kamień duszy: Cień [T.real_name]"
	if(purified)
		icon_state = "purified_soulstone2"
	else
		icon_state = "soulstone2"
	if(U && (iswizard(U) || usability))
		to_chat(S, "Twoja dusza została schwytana! Wiąże cię teraz wola [U.real_name]. Pomóż mu osiągnąć cele za wszelką cenę.")
	else if(U && iscultist(U))
		to_chat(S, "Twoja dusza została schwytana! Wiąże cię teraz wola kultu. Pomóż mu osiągnąć cele za wszelką cenę.")
	if(vic && U)
		to_chat(U, "<span class='info'><b>Schwytano!</b>:</span> Dusza [T.real_name] została wyrwana z ciała i zamknięta w kamieniu dusz.")


/obj/item/soulstone/proc/getCultGhost(mob/living/carbon/human/T, mob/U)
	var/mob/dead/observer/chosen_ghost

	for(var/mob/dead/observer/ghost in GLOB.player_list) //We put them back in their body
		if(ghost.mind && ghost.mind.current == T && ghost.client)
			chosen_ghost = ghost
			break

	if(!chosen_ghost)	//Failing that, we grab a ghost
		var/list/consenting_candidates = pollGhostCandidates("Chcesz zagrać jako cień?", ROLE_CULTIST, null, 5 SECONDS, ignore_category = POLL_IGNORE_CULT_SHADE)
		if(consenting_candidates.len)
			chosen_ghost = pick(consenting_candidates)
	if(!T)
		return FALSE
	if(!chosen_ghost)
		to_chat(U, "<span class='danger'>Żaden duch nie chciał zostać cieniem.</span>")
		return FALSE
	if(contents.len) //If they used the soulstone on someone else in the meantime
		return FALSE
	T.ckey = chosen_ghost.ckey
	for(var/obj/item/W in T)
		T.dropItemToGround(W)
	init_shade(T, U)
	qdel(T)
	return TRUE
