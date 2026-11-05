/client/proc/cmd_admin_drop_everything(mob/M in GLOB.mob_list)
	set category = null
	set name = "Drop Everything"
	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Kazać [M] upuścić wszystko?", "Wiadomość", "Tak", "Nie")
	if(confirm != "Tak")
		return

	for(var/obj/item/W in M)
		if(!M.dropItemToGround(W))
			qdel(W)
			M.regenerate_icons()

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	var/msg = "[key_name_admin(usr)] każe [ADMIN_LOOKUPFLW(M)] upuścić wszystko!"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN))
		return

	message_admins("[key_name_admin(src)] zaczyna odpowiadać na modlitwę [ADMIN_LOOKUPFLW(M)].")
	var/msg = capped_input(usr, "Wiadomość:", "Subtelna PW do [M.key]")

	if(!msg)
		message_admins("[key_name_admin(src)] rezygnuje z odpowiedzi na modlitwę [ADMIN_LOOKUPFLW(M)]")
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, "<i>Słyszysz w głowie głos... <b>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	msg = "<span class='adminnotice'><b> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] :</b> [msg]</span>"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H))
		to_chat(usr, "Działa tylko na instancjach typu /mob/living/carbon/human")
		return
	if(!istype(H.ears, /obj/item/radio/headset))
		to_chat(usr, "Osoba, z którą próbujesz się skontaktować, nie ma zestawu słuchawkowego.")
		return

	if (!sender)
		sender = input("Od kogo jest wiadomość?", "Nadawca") as null|anything in list(RADIO_CHANNEL_CENTCOM,RADIO_CHANNEL_SYNDICATE)
		if(!sender)
			return

	message_admins("[key_name_admin(src)] zaczyna odpowiadać na prośbę ([sender]) od [key_name_admin(H)].")
	var/input = capped_input(usr, "Podaj wiadomość, którą [key_name(H)] usłyszy w zestawie słuchawkowym.","Wiadomość wychodząca: [sender]")
	if(!input)
		message_admins("[key_name_admin(src)] rezygnuje z odpowiedzi na prośbę ([sender]) od [key_name_admin(H)].")
		return

	log_directed_talk(mob, H, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] odpowiada na wiadomość ([sender]) od [key_name_admin(H)]: „[input]”")
	to_chat(H, "Przez chwilę słyszysz w uszach trzaski, po czym odzywa się głos. „Proszę czekać na wiadomość od [sender == RADIO_CHANNEL_SYNDICATE ? "twojego dobroczyńcy" : JOB_CENTCOM_CENTRAL_COMMAND]. Treść wiadomości[sender == RADIO_CHANNEL_SYNDICATE ? ", agencie" : ""]: <span class='bold'>[input].</span> Koniec wiadomości.”")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_mod_antag_rep(client/C in GLOB.clients, var/operation)
	set category = "Adminbus"
	set name = "Modify Antagonist Reputation"

	if(!check_rights(R_ADMIN))
		return

	var/msg = ""
	var/log_text = ""

	if(operation == "zero")
		log_text = "Set to 0"
		SSpersistence.antag_rep -= C.ckey
	else
		var/prompt = "Podaj wartość reputacji ([operation]):"

		if(operation == "set")
			prompt = "Podaj nową wartość reputacji:"

		msg = input("Wiadomość:", prompt) as num|null

		if (!msg)
			return

		var/ANTAG_REP_MAXIMUM = CONFIG_GET(number/antag_rep_maximum)

		if(operation == "set")
			log_text = "Set to [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(0, min(msg, ANTAG_REP_MAXIMUM))
		else if(operation == "add")
			log_text = "Added [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = min(SSpersistence.antag_rep[C.ckey]+msg, ANTAG_REP_MAXIMUM)
		else if(operation == "subtract")
			log_text = "Subtracted [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(SSpersistence.antag_rep[C.ckey]-msg, 0)
		else
			to_chat(src, "Nieprawidłowa operacja na reputacji antagonisty: [operation], użytkownik [key_name(usr)]")
			return

		if(SSpersistence.antag_rep[C.ckey] <= 0)
			SSpersistence.antag_rep -= C.ckey

	log_admin("[key_name(usr)]: Modified [key_name(C)]'s antagonist reputation [log_text]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)]: zmienia reputację antagonisty gracza [key_name(C)] ([log_text])</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Modify Antagonist Reputation") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate()
	set category = "Adminbus"
	set name = "Global Narrate"

	if(!check_rights(R_ADMIN))
		return

	var/msg = capped_input(usr, "Wiadomość:", "Podaj tekst, który ma się pokazać wszystkim:")

	if (!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] wysyła globalną narrację</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)
	set category = "Adminbus"
	set name = "Direct Narrate"

	if(!check_rights(R_ADMIN))
		return

	if(!M)
		M = input("Bezpośrednia narracja do kogo?", "Aktywni gracze") as null|anything in GLOB.player_list

	if(!M)
		return

	var/msg = capped_input(usr, "Wiadomość:", "Podaj tekst, który ma się pokazać twojemu celowi:")

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	msg = "<span class='adminnotice'><b> DirectNarrate: [key_name(usr)] do ([M.name]/[M.key]):</b> [msg]<BR></span>"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(atom/A)
	set category = "Adminbus"
	set name = "Local Narrate"

	if(!check_rights(R_ADMIN))
		return
	if(!A)
		return
	var/range = input("Zasięg:", "Narracja do mobów w promieniu ilu pól:", 7) as num|null
	if(!range)
		return
	var/msg = capped_input(usr, "Wiadomość:", "Podaj tekst, który ma się pokazać wszystkim w zasięgu wzroku:")
	if (!msg)
		return
	for(var/mob/M as() in hearers(range,A))
		to_chat(M, msg)

	log_admin("LocalNarrate: [key_name(usr)] at [AREACOORD(A)]: [msg]")
	message_admins("<span class='adminnotice'><b> LocalNarrate: [key_name_admin(usr)] w [ADMIN_VERBOSEJMP(A)]:</b> [msg]<BR></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Godmode"
	if(!check_rights(R_ADMIN))
		return

	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='adminnotice'>Przełączono: [(M.status_flags & GODMODE) ? "WŁ." : "WYŁ."]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	var/msg = "[key_name_admin(usr)] przełącza nieśmiertelność [ADMIN_LOOKUPFLW(M)]: [(M.status_flags & GODMODE) ? "wł." : "wył."]"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Godmode", "[M.status_flags & GODMODE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(whom, mute_type, automute = FALSE)
	if(!whom || !mute_type)
		return

	var/muteunmute
	var/mute_string
	var/feedback_string
	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (mowa i emotki)"
			feedback_string = "IC"
		if(MUTE_OOC)
			mute_string = "OOC"
			feedback_string = "OOC"
		if(MUTE_LOOC) //nsv13
			mute_string = "LOOC"
			feedback_string = "LOOC"
		if(MUTE_PRAY)
			mute_string = "modlitwy"
			feedback_string = "Pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, PW do adminów i ASAY"
			feedback_string = "Adminhelp"
		if(MUTE_MHELP)
			mute_string = "mhelp"
			feedback_string = "Mentorhelp"
		if(MUTE_DEADCHAT)
			mute_string = "czat martwych i DSAY"
			feedback_string = "Deadchat"
		if(MUTE_ALL)
			mute_string = "wszystko"
			feedback_string = "Everything"
		else
			CRASH("mute_type in cmd_admin_mute was invalid: [mute_type]")

	var/client/C
	if(istype(whom, /client))
		C = whom
	else if(istext(whom))
		C = GLOB.directory[whom]
	else
		return

	var/datum/preferences/P
	if(C)
		P = C.prefs
	else
		P = GLOB.preferences_datums[whom]

	if(!P)
		return

	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return

	else
		if(!check_rights())
			return

	if(automute)
		muteunmute = "auto-muted"
		P.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(whom)] from [mute_string]")
		message_admins("AUTOWYCISZENIE SPAMU: [key_name_admin(whom)] – [mute_string].")

		if(C)
			to_chat(C, "System AUTOWYCISZANIA SPAMU wyciszył cię: [mute_string]. Skontaktuj się z adminem.")

		SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Auto Mute [feedback_string]", "1")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(P.muted & mute_type)
		muteunmute = "unmuted"
		P.muted &= ~mute_type

	else
		muteunmute = "muted"
		P.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(whom)] from [mute_string]")
	message_admins("[key_name_admin(usr)] [muteunmute == "muted" ? "wycisza" : "cofa wyciszenie"]: [key_name_admin(whom)] – [mute_string].")
	if(C)
		to_chat(C, "[muteunmute == "muted" ? "Wyciszono cię" : "Cofnięto ci wyciszenie"]: [mute_string] (przez [key_name(usr, include_name = FALSE)]).")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Mute [feedback_string]", "[P.muted & mute_type]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)
				continue	//we are not dead!
			if(!M.client?.should_include_for_role(ROLE_ALIEN, /datum/role_preference/midround_ghost/xenomorph))
				continue	//we don't want to be an alium
			if(M.client.is_afk())
				continue	//we are afk
			if(M.mind?.current && M.mind.current.stat != DEAD)
				continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Wybierz gracza, którego chcesz odrodzić jako ksenomorfa.", "Odpowiedni kandydaci") as null|anything in sortKey(candidates)
		else
			to_chat(usr, "<span class='danger'>Błąd: create_xeno(): brak odpowiednich kandydatów.</span>")
	if(!istext(ckey))
		return 0

	var/alien_caste = input(usr, "Wybierz kastę do stworzenia.","Wybór kasty",null) as null|anything in list("Królowa","Pretorianin","Łowca","Strażnik","Dron","Larwa")
	var/obj/effect/landmark/spawn_here = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : null
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Królowa")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(spawn_here)
		if("Pretorianin")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(spawn_here)
		if("Łowca")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Strażnik")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Dron")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larwa")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0
	if(!spawn_here)
		SSjob.SendToLateJoin(new_xeno, FALSE)

	new_xeno.ckey = ckey
	var/msg = "<span class='notice'>[key_name_admin(usr)] tworzy [ckey] jako plugawego ksenomorfa ([alien_caste]).</span>"
	message_admins(msg)
	admin_ticket_log(new_xeno, msg)
	return 1

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Adminbus"
	set name = "Respawn Character"
	set desc = "Odradza osobę, która została rozerwana/zamieniona w pył/zabita. Musi być duchem i najlepiej nie mieć ciała, do którego mogłaby wrócić."
	if(!check_rights(R_ADMIN))
		return

	var/input = ckey(input(src, "Podaj klucz gracza do odrodzenia.", "Klucz", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>W grze nie ma takiego aktywnego klucza albo ta osoba nie jest teraz duchem.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role == ROLE_ALIEN)
			if(alert("Wygląda na to, że ta postać była obcym. Odrodzić ją jako obcego?",,"Tak","Nie")=="Tak")
				var/turf/T
				if(GLOB.xeno_spawn.len)
					T = pick(GLOB.xeno_spawn)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Praetorian")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(T)
					if("Queen")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				if(!T)
					SSjob.SendToLateJoin(new_xeno, FALSE)

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "Zostałeś w pełni odrodzony. Miłej gry.")
				var/msg = "<span class='adminnotice'>[key_name_admin(usr)] odradza [new_xeno.key] jako plugawego ksenomorfa.</span>"
				message_admins(msg)
				admin_ticket_log(new_xeno, msg)
				return	//all done. The ghost is auto-deleted

		//check if they were a monkey
		else if(findtext(G_found.real_name,"monkey"))
			if(alert("Wygląda na to, że ta postać była małpą. Odrodzić ją jako małpę?",,"Tak","Nie")=="Tak")
				var/mob/living/carbon/monkey/new_monkey = new
				SSjob.SendToLateJoin(new_monkey)
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				to_chat(new_monkey, "Zostałeś w pełni odrodzony. Miłej gry.")
				var/msg = "<span class='adminnotice'>[key_name_admin(usr)] odradza [new_monkey.key] jako małpę.</span>"
				message_admins(msg)
				admin_ticket_log(new_monkey, msg)
				return	//all done. The ghost is auto-deleted


	//Ok, it's not a xeno or a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through GLOB.data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = rustg_hash_string(RUSTG_HASH_MD5, "[G_found.real_name][G_found.mind.assigned_role]")

		record_found = find_record("id", id, GLOB.data_core.locked)

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["gender"]
		new_character.age = record_found.fields["age"]
		new_character.hardset_dna(record_found.fields["identity"], record_found.fields["enzymes"], record_found.fields["name"], record_found.fields["blood_type"], new record_found.fields["species"], record_found.fields["features"], null)
	else
		var/datum/character_save/CS = new()
		CS.randomise()
		CS.pref_species.random_name(CS.gender, TRUE)
		CS.copy_to(new_character)
		new_character.dna.update_dna_identity()

	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = JOB_NAME_ASSISTANT//If they somehow got a null assigned role.

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	var/datum/antagonist/traitor/traitordatum = new_character.mind.has_antag_datum(/datum/antagonist/traitor)
	if(traitordatum)
		SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)
		traitordatum.equip()


	switch(new_character.mind.special_role)
		if(ROLE_WIZARD)
			new_character.forceMove(pick(GLOB.wizardstart))
			var/datum/antagonist/wizard/A = new_character.mind.has_antag_datum(/datum/antagonist/wizard,TRUE)
			A.equip_wizard()
		if(ROLE_OPERATIVE)
			new_character.forceMove(pick(GLOB.nukeop_start))
			var/datum/antagonist/nukeop/N = new_character.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
			N.equip_op()
		if(ROLE_NINJA)
			var/list/ninja_spawn = list()
			for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
				ninja_spawn += L
			var/datum/antagonist/ninja/ninjadatum = new_character.mind.has_antag_datum(/datum/antagonist/ninja)
			ninjadatum.equip_space_ninja()
			if(ninja_spawn.len)
				new_character.forceMove(pick(ninja_spawn))

		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if(JOB_NAME_CYBORG)//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize(TRUE)
				if(JOB_NAME_AI)
					new_character = new_character.AIize()
				else
					SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!=new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Uwaga: brak wpisu w rdzeniu danych. Czy chcesz ogłosić przybycie tej postaci, dodając ją do różnych baz danych, np. kartotek medycznych?",,"Nie","Tak")=="Tak")
				GLOB.data_core.manifest_inject(new_character)

			if(alert(new_character,"Czy aktywna SI ma ogłosić tę postać?",,"Nie","Tak")=="Tak")
				AnnounceArrival(new_character, new_character.mind.assigned_role)

	var/msg = "<span class='adminnotice'>[admin] odradza [player_key] jako [new_character.real_name].</span>"
	message_admins(msg)
	admin_ticket_log(new_character, msg)

	to_chat(new_character, "Zostałeś w pełni odrodzony. Miłej gry.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"

	if(!check_rights(R_ADMIN))
		return

	var/input = capped_input(usr, "Wpisz cokolwiek, co ma zrobić SI. Cokolwiek. Na serio.", "Co?")
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] dodaje nowe prawo SI - [input]")

	var/show_log = alert(src, "Pokazać komunikat o burzy jonowej?", "Wiadomość", "Tak", "Nie")
	var/announce_ion_laws = (show_log == "Tak" ? 100 : 0)

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announceChance = announce_ion_laws
	ion.ionMessage = input
	ion.lawsource = "Admin fuckery by [key_name(usr)]"

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		return

	if(!mob)
		return
	if(!istype(M))
		alert("Nie można wskrzesić ducha")
		return
	M.revive(full_heal = 1, admin_revive = 1)

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	var/msg = "<span class='danger'>Admin [key_name_admin(usr)] leczy / wskrzesza [ADMIN_LOOKUPFLW(M)]!</span>"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvinate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Round"
	set name = "Create Command Report"

	if(!check_rights(R_ADMIN))
		return

	// AQUILA EDIT - okno TGUI (CommandReport z tg) zamiast serii input()/alert()
	var/datum/command_report_menu/tgui = new(usr)
	tgui.ui_interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Command Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#define REPORT_DEFAULT_SOUND "domyślny"
#define REPORT_CUSTOM_SOUND "własny plik"
#define REPORT_CENTCOM_PRESET "Centrala"
#define REPORT_SYNDICATE_PRESET "Syndykat"
#define REPORT_WIZARD_PRESET "Federacja Czarodziejów"
#define REPORT_CUSTOM_PRESET "Własna nazwa"

/// AQUILA - okno raportu Dowództwa (port CommandReport z tg)
/datum/command_report_menu
	/// The mob using the UI.
	var/mob/ui_user
	/// The name of central command that will accompany our report
	var/command_name = REPORT_CENTCOM_PRESET
	/// Whether we are using a custom name instead of a preset.
	var/custom_name = FALSE
	/// The actual contents of the report we're going to send.
	var/command_report_content
	/// Whether the report's contents are announced.
	var/announce_contents = TRUE
	/// Whether a copy of the report is printed at every console.
	var/print_report = FALSE
	/// The sound that's going to accompany our message.
	var/played_sound = REPORT_DEFAULT_SOUND
	/// The subheader to include when sending the announcement. Keep blank to not include a subheader
	var/subheader = ""
	/// A list of preset names that can be chosen.
	var/list/preset_names = list(REPORT_CENTCOM_PRESET, REPORT_SYNDICATE_PRESET, REPORT_WIZARD_PRESET, REPORT_CUSTOM_PRESET)

/datum/command_report_menu/New(mob/user)
	ui_user = user
	if(command_name() != REPORT_CENTCOM_PRESET)
		command_name = command_name()
		preset_names.Insert(1, command_name())

/datum/command_report_menu/Destroy()
	ui_user = null
	return ..()

/datum/command_report_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/command_report_menu/ui_close(mob/user)
	qdel(src)

/datum/command_report_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommandReport")
		ui.open()

/datum/command_report_menu/ui_data(mob/user)
	var/list/data = list()
	data["command_name"] = command_name
	data["custom_name"] = custom_name
	data["command_report_content"] = command_report_content
	data["announce_contents"] = announce_contents
	data["print_report"] = print_report
	data["played_sound"] = isfile(played_sound) ? "[played_sound]" : played_sound
	data["subheader"] = subheader
	return data

/datum/command_report_menu/ui_static_data(mob/user)
	var/list/data = list()
	data["command_name_presets"] = preset_names
	var/list/sounds = list(REPORT_DEFAULT_SOUND)
	for(var/sound_key in SSstation.announcer?.event_sounds)
		sounds += sound_key
	sounds += REPORT_CUSTOM_SOUND
	data["announcer_sounds"] = sounds
	return data

/datum/command_report_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("update_command_name")
			var/new_name = params["updated_name"]
			if(!new_name)
				return
			if(new_name == REPORT_CUSTOM_PRESET)
				custom_name = TRUE
			else if(new_name in preset_names)
				custom_name = FALSE
			command_name = new_name
		if("set_report_sound")
			var/picked = params["picked_sound"]
			if(picked == REPORT_CUSTOM_SOUND)
				played_sound = REPORT_DEFAULT_SOUND // fallback by default
				var/sound_file = input(ui_user, "Wybierz plik dźwiękowy", "Własny dźwięk") as sound|null
				if(!sound_file)
					return TRUE
				played_sound = sound_file
			else if(picked == REPORT_DEFAULT_SOUND || (picked in SSstation.announcer?.event_sounds))
				played_sound = picked
		if("toggle_announce")
			announce_contents = !announce_contents
		if("toggle_printing")
			print_report = !print_report
		if("set_subheader")
			subheader = params["new_subheader"]
		if("submit_report")
			if(!command_name)
				to_chat(ui_user, "<span class='danger'>Raport musi mieć nadawcę.</span>")
				return
			if(!params["report"])
				to_chat(ui_user, "<span class='danger'>Raport nie może być pusty.</span>")
				return
			command_report_content = params["report"]
			send_announcement()

	return TRUE

/// Wysyła ogłoszenie i/lub drukuje raport według ustawień z okna
/datum/command_report_menu/proc/send_announcement()
	var/original_command_name = command_name()
	change_command_name(command_name)

	var/report_sound = played_sound
	if(played_sound == REPORT_DEFAULT_SOUND)
		report_sound = SSstation.announcer.get_rand_report_sound()

	if(announce_contents)
		priority_announce(command_report_content, subheader == "" ? null : subheader, report_sound, has_important_message = TRUE)

	if(!announce_contents || print_report)
		print_command_report(command_report_content, "[announce_contents ? "Komunikat" : "Tajny komunikat"]: [command_name]", !announce_contents)

	change_command_name(original_command_name)

	log_admin("[key_name(ui_user)] has created a command report: \"[command_report_content]\", sent from \"[command_name]\" with the sound \"[played_sound]\".")
	message_admins("[key_name_admin(ui_user)] tworzy raport dowództwa, nadawca: „[command_name]”")
	if(!announce_contents)
		message_admins("Treść wiadomości: [command_report_content]")

#undef REPORT_DEFAULT_SOUND
#undef REPORT_CUSTOM_SOUND
#undef REPORT_CENTCOM_PRESET
#undef REPORT_SYNDICATE_PRESET
#undef REPORT_WIZARD_PRESET
#undef REPORT_CUSTOM_PRESET

/client/proc/cmd_change_command_name()
	set category = "Round"
	set name = "Change Command Name"

	if(!check_rights(R_ADMIN))
		return

	var/input = capped_input(usr, "Podaj nową nazwę Centrali.", "Co?")
	if(!input)
		return
	change_command_name(input)
	message_admins("[key_name_admin(src)] zmienia nazwę Centrali na [input]")
	log_admin("[key_name(src)] has changed the Central Command name to: [input]")

/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in world)
	set category = "Adminbus"
	set name = "Delete"

	if(!check_rights(R_SPAWN|R_DEBUG))
		return

	admin_delete(A)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Adminbus"
	set name = "Manage Job Slots"

	if(!check_rights(R_ADMIN))
		return
	holder.manage_free_slots()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Job Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Adminbus"
	set name = "Explosion"

	if(!check_rights(R_ADMIN))
		return

	var/devastation = input("Zasięg całkowitego zniszczenia. -1, by pominąć", text("Wartość"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Zasięg ciężkich zniszczeń. -1, by pominąć", text("Wartość"))  as num|null
	if(heavy == null)
		return
	var/light = input("Zasięg lekkich zniszczeń. -1, by pominąć", text("Wartość"))  as num|null
	if(light == null)
		return
	var/flash = input("Zasięg błysku. -1, by pominąć", text("Wartość"))  as num|null
	if(flash == null)
		return
	var/flames = input("Zasięg płomieni. -1, by pominąć", text("Wartość"))  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (alert(src, "Na pewno chcesz to zrobić? Będzie laaagować.", "Potwierdzenie", "Tak", "Nie") != "Tak")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] wywołuje eksplozję ([devastation],[heavy],[light],[flames]) w [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Explosion") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Adminbus"
	set name = "EM Pulse"

	if(!check_rights(R_ADMIN))
		return

	var/heavy = input("Zasięg silnego impulsu.", text("Wartość"))  as num|null
	if(heavy == null)
		return
	var/light = input("Zasięg słabego impulsu.", text("Wartość"))  as num|null
	if(light == null)
		return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] wywołuje impuls EMP ([heavy],[light]) w [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EM Pulse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Gib"

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Zostawić mózg?", "Potwierdzenie", "Tak", "Nie","Anuluj")
	if(confirm == "Anuluj" || !confirm)
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] rozrywa na strzępy [key_name_admin(M)]")

	if(isobserver(M))
		new /obj/effect/gibspawner/generic(get_turf(M), M)
		return
	if(confirm == "Tak")
		M.gib()
	else
		M.gib(1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	var/confirm = alert(src, "Na pewno?", "Potwierdzenie", "Tak", "Nie")
	if(confirm == "Tak")
		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] używa gibself.</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		mob.gib(1, 1, 1)

/client/proc/cmd_admin_check_contents(mob/living/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Adminbus"
	set name = "Change View Range"
	set desc = "przełącza między widokiem 1x a własnym"

	if(view_size.getView() == view_size.default)
		view_size.setTo(input("Wybierz zasięg widoku:", "KURDE TAK", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128) - 7)
	else
		view_size.resetToDefault(getScreenSize(mob))

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].")	//why? removed by order of XSI

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Change View Range", "[view]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Round"
	set name = "Call Shuttle"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Na pewno?", "Potwierdzenie", "Tak", "Tak (bez odwołania)", "Nie")
	switch(confirm)
		if(null, "Nie")
			return
		if("Tak (bez odwołania)")
			SSshuttle.adminEmergencyNoRecall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] wzywa prom ewakuacyjny (admin).</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Round"
	set name = "Cancel Shuttle"
	if(!check_rights(0))
		return
	if(alert(src, "Na pewno?", "Potwierdzenie", "Tak", "Nie") != "Tak")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(SSshuttle.adminEmergencyNoRecall)
		SSshuttle.adminEmergencyNoRecall = FALSE

	SSshuttle.emergency.cancel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] odwołuje prom ewakuacyjny (admin).</span>")

	return

/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Nadaje wszystkim losowy wygląd. Działa tylko przed rundą!"

	if(SSticker.HasRoundStarted())
		to_chat(usr, "O nie, nie możesz tego zrobić, gra już się zaczęła. To działa tylko przed rundą!")
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(usr)] wyłącza tryb „Każdy jest wyjątkowy”.")
		to_chat(usr, "Wyłączono.")
		return


	var/notifyplayers = alert(src, "Czy chcesz powiadomić graczy?", "Opcje", "Tak", "Nie", "Anuluj")
	if(notifyplayers == "Anuluj" || !notifyplayers)
		return

	if(SSticker.HasRoundStarted())
		to_chat(usr, "O nie, nie możesz tego zrobić, gra już się zaczęła. To działa tylko przed rundą!")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] wymusza losowy wygląd wszystkich graczy.")

	if(notifyplayers == "Tak")
		to_chat(world, "<span class='adminnotice'>Admin [usr.key] wymusił całkowicie losowe tożsamości wszystkich graczy!</span>")

	to_chat(usr, "<i>Pamiętaj: losowość zawsze możesz wyłączyć, używając tego verba ponownie, o ile runda jeszcze się nie zaczęła.</i>")

	CONFIG_SET(flag/force_random_names, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"
	set desc = "Włącza/wyłącza losowe zdarzenia, takie jak meteory, czarne dziury i grzyb (ale nie kosmiczny pył)"
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	if(new_are)
		to_chat(usr, "Włączono losowe zdarzenia.")
		message_admins("Admin [key_name_admin(usr)] włącza losowe zdarzenia.")
	else
		to_chat(usr, "Wyłączono losowe zdarzenia.")
		message_admins("Admin [key_name_admin(usr)] wyłącza losowe zdarzenia.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Random Events", "[new_are ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/admin_change_sec_level()
	set category = "Round"
	set name = "Set Security Level"
	set desc = "Zmienia poziom alarmu. Tylko ogłoszenie, np. ustawienie Delty nie uzbroi bomby"

	if(!check_rights(R_ADMIN))
		return

	var/level = input("Wybierz poziom bezpieczeństwa","Poziom alarmu") as null|anything in list("green","blue","red","delta")
	if(level)
		set_security_level(level)

		log_admin("[key_name(usr)] changed the security level to [level]")
		message_admins("[key_name_admin(usr)] zmienia poziom alarmu na [level]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Security Level [capitalize(level)]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_nuke(obj/machinery/nuclearbomb/N in GLOB.nuke_list)
	set name = "Toggle Nuke"
	set category = "Fun"
	set popup_menu = 0
	if(!check_rights(R_DEBUG))
		return

	if(!N.timing)
		var/newtime = input(usr, "Ustaw licznik aktywacji.", "Uzbrój bombę", "[N.timer_set]") as num|null
		if(!newtime)
			return
		N.timer_set = newtime
	N.set_safety()
	N.set_active()

	log_admin("[key_name(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(N)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] [N.timing ? "uzbraja" : "rozbraja"] bombę atomową w [ADMIN_VERBOSEJMP(N)].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Nuke", "[N.timing]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_combo_hud()
	set category = "Admin"
	set name = "Toggle Combo HUD"
	set desc = "Przełącza zbiorczy HUD admina (antagoniści, nauka, medycyna, inżynieria)"

	if(!check_rights(R_ADMIN))
		return

	var/adding_hud = !has_antag_hud()

	for(var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED)) // add data huds
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)
	for(var/datum/atom_hud/antag/H in GLOB.huds) // add antag huds
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	if(prefs.toggles & PREFTOGGLE_COMBOHUD_LIGHTING)
		if(adding_hud)
			mob.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			mob.lighting_alpha = initial(mob.lighting_alpha)

	mob.update_sight()

	to_chat(usr, "Zbiorczy HUD admina: [adding_hud ? "WŁ." : "WYŁ."].")
	message_admins("[key_name_admin(usr)] przełącza swój zbiorczy HUD admina: [adding_hud ? "WŁ." : "WYŁ."].")
	log_admin("[key_name(usr)] toggled their admin combo HUD [adding_hud ? "ON" : "OFF"].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Combo HUD", "[adding_hud ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/has_antag_hud()
	var/datum/atom_hud/A = GLOB.huds[ANTAG_HUD_TRAITOR]
	return A.hudusers[mob]

/client/proc/open_shuttle_manipulator()
	set category = "Round"
	set name = "Shuttle Manipulator"
	set desc = "Otwiera interfejs manipulatora promów."

	for(var/obj/machinery/shuttle_manipulator/M in GLOB.machines)
		M.ui_interact(usr)

/client/proc/run_weather()
	set category = "Fun"
	set name = "Run Weather"
	set desc = "Wywołuje pogodę na wybranym poziomie z."

	if(!holder)
		return

	var/weather_type = input("Wybierz pogodę", "Pogoda")  as null|anything in sortList(subtypesof(/datum/weather), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!weather_type)
		return

	var/turf/T = get_turf(mob)
	var/z_level = input("Docelowy poziom z?", "Poziom z", T?.z) as num|null
	if(!isnum_safe(z_level))
		return

	SSweather.run_weather(weather_type, z_level)

	message_admins("[key_name_admin(usr)] wywołuje pogodę typu [weather_type] na poziomie z [z_level].")
	log_admin("[key_name(usr)] started weather of type [weather_type] on the z-level [z_level].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Run Weather")

/client/proc/mass_zombie_infection()
	set category = "Fun"
	set name = "Mass Zombie Infection"
	set desc = "Zaraża wszystkich ludzi uśpionym organem, który po śmierci \
		zamieni ich w zombie."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Potwierdź, że chcesz dodać wszystkim ludziom uśpione organy zombie.", "Potwierdź zombie", "Tak", "Nie")
	if(confirm != "Tak")
		return

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		new /obj/item/organ/zombie_infection/nodamage(H)

	message_admins("[key_name_admin(usr)] dodaje wszystkim ludziom uśpioną infekcję zombie.")
	log_admin("[key_name(usr)] added a latent zombie infection to all humans.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Infection")

/client/proc/mass_zombie_cure()
	set category = "Fun"
	set name = "Mass Zombie Cure"
	set desc = "Usuwa infekcję zombie u wszystkich ludzi, przywracając ich do normy."
	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Potwierdź, że chcesz wyleczyć wszystkie zombie.", "Potwierdź leczenie zombie", "Tak", "Nie")
	if(confirm != "Tak")
		return

	for(var/obj/item/organ/zombie_infection/nodamage/I in GLOB.zombie_infection_list)
		qdel(I)

	message_admins("[key_name_admin(usr)] leczy wszystkie zombie.")
	log_admin("[key_name(usr)] cured all zombies.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Cure")

/client/proc/polymorph_all()
	set category = "Fun"
	set name = "Polymorph All"
	set desc = "Nakłada efekt pocisku przemiany na każdego moba."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Potwierdź, że chcesz przemienić wszystkie moby.", "Potwierdź przemianę", "Tak", "Nie")
	if(confirm != "Tak")
		return

	var/list/mobs = shuffle(GLOB.alive_mob_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(usr)

	message_admins("[key_name_admin(usr)] zaczyna przemianę wszystkich żywych mobów.")
	log_admin("[key_name(usr)] polymorphed all living mobs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Polymorph All")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M)
			continue

		M.audible_message("<span class='italics'>...wabbajack...wabbajack...</span>")
		playsound(M.loc, 'sound/magic/staff_change.ogg', 50, 1, -1)

		wabbajack(M)

	message_admins("Masowa przemiana rozpoczęta przez [who_did_it] zakończona.")


/client/proc/show_tip()
	set category = "Server"
	set name = "Show Tip"
	set desc = "Wysyła wszystkim graczom wskazówkę (twojego autorstwa). W końcu \
		to ty jesteś tu doświadczonym graczem."

	if(!check_rights(R_ADMIN))
		return

	var/input = capped_multiline_input(usr, "Podaj wskazówkę, którą chcesz wysłać graczom.", "Wskazówka")
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()


	message_admins("[key_name_admin(usr)] wysyła wskazówkę rundy.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Tip")

/client/proc/modify_goals()
	set category = "Debug"
	set name = "Modify goals"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	holder.modify_goals()

// AQUILA EDIT - edycja celów stacji w TGUI (okno "StationGoalsPanel") zamiast HTML
/datum/admins/proc/modify_goals()
	if(!station_goals_ui)
		station_goals_ui = new(src)
	station_goals_ui.ui_interact(usr)

/datum/admins
	/// AQUILA - okno TGUI celów stacji
	var/datum/station_goals_panel/station_goals_ui

/datum/station_goals_panel
	var/datum/admins/holder

/datum/station_goals_panel/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/station_goals_panel/Destroy(force)
	if(holder?.station_goals_ui == src)
		holder.station_goals_ui = null
	holder = null
	return ..()

/datum/station_goals_panel/ui_state(mob/user)
	return get_admin_state(0)

/datum/station_goals_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationGoalsPanel")
		ui.open()

/datum/station_goals_panel/ui_data(mob/user)
	var/list/data = list()
	var/list/goals = list()
	if(SSticker.mode)
		for(var/datum/station_goal/S in SSticker.mode.station_goals)
			goals += list(list("name" = S.name, "ref" = REF(S)))
	data["goals"] = goals
	data["has_mode"] = !!SSticker.mode
	return data

/datum/station_goals_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	switch(action)
		if("add")
			holder.ui_topic(list("add_station_goal" = "1"))
			return TRUE
		if("announce", "remove")
			if(!SSticker.mode)
				return
			var/datum/station_goal/S = locate(params["ref"]) in SSticker.mode.station_goals
			if(!S)
				return
			if(action == "announce")
				S.on_report()
				S.send_report()
				log_admin("[key_name(usr)] announced the \"[S.name]\" station goal.")
			else
				log_admin("[key_name(usr)] removed the \"[S.name]\" station goal.")
				qdel(S)
			return TRUE


/client/proc/toggle_hub()
	set category = "Server"
	set name = "Toggle Hub"

	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(usr)] przełącza widoczność serwera w hubie na tę rundę, teraz serwer [(GLOB.hub_visibility?"jest":"nie jest")] widoczny w hubie.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("UWAGA: serwer nie pojawi się w hubie, bo BYOND wykrywa, że zapora sieciowa blokuje połączenia przychodzące.")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggled Hub Visibility", "[GLOB.hub_visibility ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/immerse_player(mob/living/carbon/target, toggle=TRUE, remove=FALSE)
	var/list/immersion_components = list(/datum/component/manual_breathing, /datum/component/manual_blinking)

	for(var/immersies in immersion_components)
		var/has_component = target.GetComponent(immersies)

		if(has_component && (toggle || remove))
			qdel(has_component)
		else if(toggle || !remove)
			target.AddComponent(immersies)

/proc/mass_immerse(remove=FALSE)
	for(var/mob/living/carbon/M in GLOB.mob_list)
		immerse_player(M, toggle=FALSE, remove=remove)

/client/proc/smite(mob/living/target as mob)
	set name = "Smite"
	set category = "Fun"
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/list/punishment_list = list(ADMIN_PUNISHMENT_LIGHTNING, ADMIN_PUNISHMENT_BRAINDAMAGE, ADMIN_PUNISHMENT_GIB, ADMIN_PUNISHMENT_BSA, ADMIN_PUNISHMENT_FIREBALL, ADMIN_PUNISHMENT_ROD, ADMIN_PUNISHMENT_SUPPLYPOD_QUICK, ADMIN_PUNISHMENT_SUPPLYPOD, ADMIN_PUNISHMENT_MAZING, ADMIN_PUNISHMENT_FLOORCLUWNE, ADMIN_PUNISHMENT_CLUWNE, ADMIN_PUNISHMENT_IMMERSE, ADMIN_PUNISHMENT_GHOST, ADMIN_PUNISHMENT_DEMOCRACY, ADMIN_PUNISHMENT_ANARCHY, ADMIN_PUNISHMENT_TOE, ADMIN_PUNISHMENT_TOEPLUS, ADMIN_PUNISHMENT_CRYO, ADMIN_PUNISHMENT_ENTRAPPED, ADMIN_PUNISHMENT_DOCK) //NSV13 - added entrapped + Dock
	if(istype(target, /mob/living/carbon))
		punishment_list += ADMIN_PUNISHMENT_NUGGET
	var/punishment = input("Wybierz karę", "BOSKA KARA") as null|anything in sortList(punishment_list)

	if(QDELETED(target) || !punishment)
		return

	switch(punishment)
		if(ADMIN_PUNISHMENT_ENTRAPPED) //NSV13 start
			for(var/turf/T in (orange(1, target) - target.loc))
				new /obj/item/ship_weapon/ammunition/naval_artillery/cannonball/admin(T)
			target.playsound_local(get_turf(target), 'sound/magic/clockwork/invoke_general.ogg', 200, pressure_affected = FALSE)
			to_chat(target, "<span class='narsiesmall'>W pułapce.</span>")
		if(ADMIN_PUNISHMENT_DOCK)
			if(!iscarbon(target))
				to_chat(usr,"<span class='warning'>To trzeba użyć na mobie węglowym.</span>")
				return
			var/mob/living/carbon/dude = target
			var/obj/item/card/id/card = dude.get_idcard(TRUE)
			if(!card)
				to_chat(usr,"<span class='warning'>[dude] nie ma przy sobie karty ID!</span>")
				return
			if(!card.registered_account)
				to_chat(usr,"<span class='warning'>[dude] nie ma karty ID z kontem!</span>")
				return
			if(card.registered_account.account_balance == 0)
				to_chat(usr, "<span class='warning'>Na karcie ID nie ma środków. Nie ma czego potrącić.</span>")
				return
			var/new_cost = input("Ile potrącamy z wypłaty? Obecne saldo: [card.registered_account.account_balance] kr.","CIĘCIA BUDŻETOWE") as num|null
			if(!new_cost)
				return
			if(!(card.registered_account.has_money(new_cost)))
				to_chat(usr, "<span class='warning'>Na karcie ID zabrakło środków. Opróżniam konto.</span>")
				card.registered_account.bank_card_talk("Na podstawie oceny wyników z twojego konta pobrano [new_cost] kr.")
				card.registered_account.account_balance = 0
			else
				card.registered_account.account_balance = card.registered_account.account_balance - new_cost
				card.registered_account.bank_card_talk("Na podstawie oceny wyników z twojego konta pobrano [new_cost] kr.")
			SEND_SOUND(target, 'sound/machines/buzz-sigh.ogg') //NSV13 end
		if(ADMIN_PUNISHMENT_LIGHTNING)
			var/turf/T = get_step(get_step(target, NORTH), NORTH)
			T.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
			target.adjustFireLoss(75)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.electrocution_animation(40)
			to_chat(target, "<span class='userdanger'>Bogowie ukarali cię za twoje grzechy!</span>")
		if(ADMIN_PUNISHMENT_BRAINDAMAGE)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 199, 199)
		if(ADMIN_PUNISHMENT_GIB)
			target.gib(FALSE)
		if(ADMIN_PUNISHMENT_BSA)
			bluespace_artillery(target)
		if(ADMIN_PUNISHMENT_FIREBALL)
			new /obj/effect/temp_visual/target(get_turf(target))
		if(ADMIN_PUNISHMENT_ROD)
			var/turf/T = get_turf(target)
			var/startside = pick(GLOB.cardinals)
			var/turf/startT = spaceDebrisStartLoc(startside, T.z)
			var/turf/endT = spaceDebrisFinishLoc(startside, T.z)
			new /obj/effect/immovablerod(startT, endT,target)
		if(ADMIN_PUNISHMENT_SUPPLYPOD_QUICK)
			var/target_path = input(usr,"Podaj ścieżkę typu atomu, który ma przylecieć w kapsule (wpisz „empty”, by wysłać pustą kapsułę):" ,"Ścieżka typu","/obj/item/food/grown/harebell") as null|text
			var/obj/structure/closet/supplypod/centcompod/pod = new()
			pod.damage = 40
			pod.explosionSize = list(0,0,0,2)
			pod.effectStun = TRUE
			if (isnull(target_path)) //The user pressed "Cancel"
				return
			if (target_path != "empty")//if you didn't type empty, we want to load the pod with a delivery
				var/delivery = text2path(target_path)
				if(!ispath(delivery))
					delivery = pick_closest_path(target_path)
					if(!delivery)
						alert("BŁĄD: podano nieprawidłową ścieżkę.")
						return
				new delivery(pod)
			new /obj/effect/pod_landingzone(get_turf(target), pod)
		if(ADMIN_PUNISHMENT_SUPPLYPOD)
			var/datum/centcom_podlauncher/plaunch  = new(usr)
			if(!holder)
				return
			plaunch.specificTarget = target
			plaunch.launchChoice = 0
			plaunch.damageChoice = 1
			plaunch.explosionChoice = 1
			plaunch.temp_pod.damage = 40//bring the mother fuckin ruckus
			plaunch.temp_pod.explosionSize = list(0,0,0,2)
			plaunch.temp_pod.effectStun = TRUE
			return //We return here because punish_log() is handled by the centcom_podlauncher datum

		if(ADMIN_PUNISHMENT_MAZING)
			if(!puzzle_imprison(target))
				to_chat(usr,"<span class='warning'>Uwięzienie się nie powiodło!</span>")
				return

		if(ADMIN_PUNISHMENT_FLOORCLUWNE)
			if(!ishuman(target))
				to_chat(usr,"<span class='warning'>Podłogowego cluwne'a możesz nasłać tylko na ludzi!</span>")
				return

			var/turf/T = get_turf(target)
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new(T)
			FC.invalid_area_typecache = list()  // works anywhere
			FC.delete_after_target_killed = TRUE
			FC.force_target(target)
			FC.stage = 4

		if(ADMIN_PUNISHMENT_CLUWNE)
			message_admins("[usr] zamienia [target] w cluwne'a")
			target.cluwne()

		if(ADMIN_PUNISHMENT_NUGGET)
			var/mob/living/carbon/C = target
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						BP.dismember()

		if(ADMIN_PUNISHMENT_IMMERSE)
			immerse_player(target)

		if(ADMIN_PUNISHMENT_GHOST)
			if (target.key)
				target.ghostize(FALSE,SENTIENCE_FORCE)
			else
				target.set_playable()
		if(ADMIN_PUNISHMENT_TOE)
			if(!ishuman(target))
				to_chat(usr, "<span class='warning'>Tylko humanoidy mogą uderzyć się w palec u nogi!</span>")
				return
			var/mob/living/carbon/human/H = target
			to_chat(H, "<span class='warning'>Uderzasz palcem u nogi w niewidzialny stół!</span>")
			H.stub_toe(5)
		if(ADMIN_PUNISHMENT_TOEPLUS)
			if(!ishuman(target))
				to_chat(usr, "<span class='warning'>Tylko humanoidy mogą uderzyć się w palec u nogi!</span>")
				return
			ADD_TRAIT(target, TRAIT_ALWAYS_STUBS, "adminabuse")

		if(ADMIN_PUNISHMENT_DEMOCRACY)
			target._AddComponent(list(/datum/component/deadchat_control, DEMOCRACY_MODE, list(
			 "up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, NORTH),
			 "down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, SOUTH),
			 "left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, WEST),
			 "right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, EAST)), 40))

		if(ADMIN_PUNISHMENT_ANARCHY)
			target._AddComponent(list(/datum/component/deadchat_control, ANARCHY_MODE, list(
			 "up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, NORTH),
			 "down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, SOUTH),
			 "left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, WEST),
			 "right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, EAST)), 10))

		if(ADMIN_PUNISHMENT_CRYO)
			forcecryo(target)

	punish_log(target, punishment)

/client/proc/punish_log(var/whom, var/punishment)
	var/msg = "[key_name_admin(usr)] karze [key_name_admin(whom)]: [punishment]."
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(usr)] punished [key_name(whom)] with [punishment].")

/client/proc/trigger_centcom_recall()
	if(!check_rights(R_ADMIN))
		return
	var/message = pick(GLOB.admiral_messages)
	message = capped_input(src, "Podaj wiadomość od dyżurnego admirała do raportu o odwołaniu.", "Wiadomość admirała", message)

	if(!message)
		return

	message_admins("[key_name_admin(usr)] wywołuje odwołanie promu przez Centralę z wiadomością admirała: [message]")
	log_game("[key_name(usr)] triggered a CentCom recall, with the message of: [message]")
	SSshuttle.centcom_recall(SSshuttle.emergency.timer, message)

/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Player Playtime"
	if(!check_rights(R_ADMIN))
		return

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='warning'>Śledzenie jest wyłączone w pliku konfiguracyjnym serwera.</span>")
		return

	// AQUILA EDIT - raport czasu gry w TGUI (okno "PlaytimeReport") zamiast HTML
	if(!holder.playtime_report_ui)
		holder.playtime_report_ui = new(holder)
	holder.playtime_report_ui.ui_interact(mob)

/datum/admins
	/// AQUILA - okno TGUI raportu czasu gry
	var/datum/playtime_report/playtime_report_ui

/datum/playtime_report
	var/datum/admins/holder

/datum/playtime_report/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/playtime_report/Destroy(force)
	if(holder?.playtime_report_ui == src)
		holder.playtime_report_ui = null
	holder = null
	return ..()

/datum/playtime_report/ui_state(mob/user)
	return GLOB.admin_state

/datum/playtime_report/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlaytimeReport")
		ui.open()

/datum/playtime_report/ui_data(mob/user)
	var/list/data = list()
	var/list/players = list()
	for(var/client/C in GLOB.clients)
		players += list(list(
			"key" = C.key,
			"ckey" = C.ckey,
			"name" = C.mob?.real_name,
			"mob_ref" = C.mob ? REF(C.mob) : null,
			"living_minutes" = C.get_exp_living(TRUE),
			"living" = C.get_exp_living(),
		))
	data["players"] = players
	return data

/datum/playtime_report/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	if(action == "playtime")
		holder.ui_topic(list("getplaytimewindow" = params["ref"]))
		return
	return holder.ui_common_action(action, params)

/datum/admins/proc/cmd_show_exp_panel(client/client_to_check)
	if(!check_rights(R_ADMIN))
		return
	if(!client_to_check)
		to_chat(usr, "<span class='danger'>BŁĄD: nie znaleziono klienta.</span>")
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='warning'>Śledzenie jest wyłączone w pliku konfiguracyjnym serwera.</span>")
		return

	new /datum/job_report_menu(client_to_check, usr)

/datum/admins/proc/toggle_exempt_status(client/C)
	if(!check_rights(R_ADMIN))
		return
	if(!C)
		to_chat(usr, "<span class='danger'>BŁĄD: nie znaleziono klienta.</span>")
		return

	if(!C.set_db_player_flags())
		to_chat(usr, "<span class='danger'>BŁĄD: nie udało się odczytać flag gracza z bazy danych. Sprawdź logi.</span>")
	var/dbflags = C.prefs.db_flags
	var/newstate = FALSE

	if(dbflags & DB_FLAG_EXEMPT || C.prefs.job_exempt)
		newstate = FALSE
	else
		newstate = TRUE

	C.prefs.job_exempt = newstate

	if(C.update_flag_db(DB_FLAG_EXEMPT, newstate))
		to_chat(usr, "<span class='danger'>BŁĄD: nie udało się zaktualizować flag gracza. Sprawdź logi.</span>")
	else
		message_admins("[key_name_admin(usr)] [newstate ? "włącza" : "wyłącza"] zwolnienie z wymogów czasu gry dla [key_name_admin(C)]")
		log_admin("[key_name(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name(C)]")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = input("Usunąć/dodać?", "Usuwanie/dodawanie cech") as null|anything in list("Dodaj","Usuń")
	if(!add_or_remove)
		return
	var/list/available_traits = list()

	switch(add_or_remove)
		if("Dodaj")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					available_traits += GLOB.traits_by_type[key]
		if("Usuń")
			if(!GLOB.trait_name_map)
				GLOB.trait_name_map = generate_trait_name_map()
			for(var/trait in D.status_traits)
				var/name = GLOB.trait_name_map[trait] || trait
				available_traits[name] = trait

	var/chosen_trait = input("Wybierz cechę do zmiany", "Cecha") as null|anything in available_traits
	if(!chosen_trait)
		return
	chosen_trait = available_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Dodaj") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			ADD_TRAIT(D,chosen_trait,source)
		if("Usuń")
			var/specific = input("Wszystkie źródła czy konkretne?", "Usuwanie/dodawanie cech") as null|anything in list("Wszystkie","Konkretne")
			if(!specific)
				return
			switch(specific)
				if("Wszystkie")
					source = null
				if("Konkretne")
					source = input("Źródło do usunięcia","Usuwanie/dodawanie cech") as null|anything in D.status_traits[chosen_trait]
					if(!source)
						return
			REMOVE_TRAIT(D,chosen_trait,source)

/client/proc/spawnhuman()
	set name = "Spawn human"
	set desc = "Tworzy bezmyślnego człowieka"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	var/turf/T = get_turf(usr)
	new /mob/living/carbon/human(T)
	log_admin("[key_name(usr)] spawned a mindless human.")

/client/proc/cmd_admin_send_pda_msg()
	set name = "Send PDA Message"
	set category = "Adminbus"

	if(!check_rights(R_ADMIN))
		return
	var/obj/machinery/telecomms/message_server/server
	for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
		server = S
		break
	tgui_send_admin_pda(usr, null, server, theme = "admin", allow_send_all = TRUE)
