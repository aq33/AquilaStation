//Split into Team List -> Team Details ?
/datum/admins/proc/team_listing()
	var/list/content = list()
	for(var/datum/team/T in GLOB.antagonist_teams)
		content += "<h3>[T.name] - [T.type]</h3>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=rename_team;team=[REF(T)]'>Zmień nazwę</a>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=delete_team;team=[REF(T)]'>Usuń</a>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=communicate;team=[REF(T)]'>Wyślij wiadomość</a>"
		for(var/command in T.get_admin_commands())
			content += "<a href='byond://?src=[REF(T)];command=[command]'>[command]</a>"
		content += "<br>"
		content += "Cele:<br><ol>"
		for(var/datum/objective/O in T.objectives)
			content += "<li>[O.explanation_text] - "
			content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=edit_objective;team=[REF(T)];tobjective=[REF(O)]'>Edytuj</a>"
			content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=remove_objective;team=[REF(T)];tobjective=[REF(O)]'>Usuń</a>"
			content += "</li>"
		content += "</ol><a href='byond://?_src_=holder;[HrefToken()];team_command=add_objective;team=[REF(T)]'>Dodaj cel</a><br>"
		content += "Członkowie: <br><ul>"
		for(var/datum/mind/M in T.members)
			content += "<li>[M.name] - <a href='byond://?_src_=holder;[HrefToken()];team_command=remove_member;team=[REF(T)];tmember=[REF(M)]'>Usuń członka</a></li>"
		content += "</ul><a href='byond://?_src_=holder;[HrefToken()];team_command=add_member;team=[REF(T)]'>Dodaj członka</a>"
		content += "<hr>"
	content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=create_team'>Utwórz drużynę</a><br>"
	return content.Join()


/datum/admins/proc/check_teams()
	if(!SSticker.HasRoundStarted())
		alert("Gra jeszcze się nie zaczęła!")
		return

	var/datum/browser/popup = new(usr, "teams", "Lista drużyn", 500, 500)
	popup.set_content(team_listing())
	popup.open()

/datum/admins/proc/admin_create_team(mob/user)
	var/team_name = stripped_input(user,"Nazwa drużyny?")
	if(!team_name)
		return
	var/datum/team/custom/T = new()
	T.name = team_name

	message_admins("[key_name_admin(usr)] tworzy nową drużynę antagonistów: [name].")
	log_admin("[key_name(usr)] created new [name] antagonist team.")

/datum/team/proc/admin_rename(mob/user)
	var/old_name = name
	var/team_name = stripped_input(user,"Nowa nazwa drużyny?","Zmiana nazwy drużyny",old_name)
	if(!team_name)
		return
	name = team_name
	message_admins("[key_name_admin(usr)] zmienia nazwę drużyny [old_name] na [name]")
	log_admin("[key_name(usr)] renamed [old_name] team to [name]")

/datum/team/proc/admin_communicate(mob/user)
	var/message = capped_input(user,"Wiadomość dla drużyny?","Wiadomość dla drużyny")
	if(!message)
		return
	for(var/datum/mind/M in members)
		to_chat(M.current,message)

	message_admins("[key_name_admin(usr)] pisze do drużyny [name]: [message]")
	log_admin("Team Message: [key_name(usr)] -> [name] team : [message]")

/datum/team/proc/admin_add_objective(mob/user)
	//any antag with get_team == src => add objective to that antag
	//otherwise create new custom antag
	if(!GLOB.admin_objective_list)
		generate_admin_objective_list()

	var/selected_type = input("Wybierz typ celu:", "Typ celu") as null|anything in GLOB.admin_objective_list
	selected_type = GLOB.admin_objective_list[selected_type]
	if (!selected_type)
		return

	var/datum/objective/O = new selected_type
	O.team = src
	O.admin_edit(user)
	objectives |= O

	var/custom_antag_name

	for(var/datum/mind/M in members)
		var/datum/antagonist/team_antag
		for(var/datum/antagonist/A in M.antag_datums)
			if(A.get_team() == src)
				team_antag = A
		if(!team_antag)
			team_antag = new /datum/antagonist/custom
			if(!custom_antag_name)
				custom_antag_name = stripped_input(user, "Własna nazwa antagonisty drużyny:", "Własny antag", "Antagonista")
				if(!custom_antag_name)
					custom_antag_name = "Członek drużyny"
			team_antag.name = custom_antag_name
			M.add_antag_datum(team_antag,src)
		team_antag.objectives |= O
		log_objective(M, O.explanation_text, usr)

	message_admins("[key_name_admin(usr)] dodaje cel „[O.explanation_text]” drużynie [name]")
	log_admin("[key_name(usr)] added objective \"[O.explanation_text]\" to [name]")

/datum/team/proc/admin_edit_objective(mob/user,datum/objective/old_objective)
	if(!GLOB.admin_objective_list)
		generate_admin_objective_list()

	var/selected_type = input("Wybierz typ celu:", "Typ celu") as null|anything in GLOB.admin_objective_list
	selected_type = GLOB.admin_objective_list[selected_type]
	if (!selected_type)
		return

	var/objective_pos = src.objectives.Find(old_objective) //Keep them in the same order, else it breaks muh immursion
	var/datum/objective/new_objective

	new_objective = new selected_type
	new_objective.team = src
	new_objective.admin_edit(user)

	//Apply it to the team
	objectives -= old_objective
	objectives.Insert(objective_pos, new_objective)

	//Now apply it to the members
	for(var/datum/mind/M in members)
		objective_pos = 0
		for(var/datum/antagonist/A in M.antag_datums)
			objective_pos = A.objectives.Find(old_objective)
			if(objective_pos) //Just in case an admin messed with their individual objectives
				//And yes, we'll assume it was intentional. They can always remove and re-add the objective.
				A.objectives -= old_objective
				A.objectives.Insert(objective_pos, new_objective)
				break
		if(!objective_pos)
			to_chat(user, "<span class='warning'>Wygląda na to, że [M.current] nie ma tego celu, choć należy do drużyny. Jeśli to niezamierzone, usuń cel i dodaj go ponownie.</span>")

	message_admins("[key_name_admin(usr)] zmienia cel drużyny [src.name] na: [new_objective.explanation_text]")
	log_admin("[key_name(usr)] edited team [src.name]'s objective to [new_objective.explanation_text]")

/datum/team/proc/admin_remove_objective(mob/user,datum/objective/O)
	for(var/datum/mind/M in members)
		for(var/datum/antagonist/A in M.antag_datums)
			A.objectives -= O
	objectives -= O

	message_admins("[key_name_admin(usr)] usuwa cel „[O.explanation_text]” drużynie [name]")
	log_admin("[key_name(usr)] removed objective \"[O.explanation_text]\" from [name]")
	//qdel maybe

/datum/team/proc/admin_add_member(mob/user)
	var/list/candidates = list()
	for(var/mob/M in GLOB.player_list)
		if(M.mind?.special_role)
			continue
		candidates += M.mind
	var/datum/mind/value = input("Wybierz nowego członka:", "Nowy członek drużyny", null) as null|anything in sortNames(candidates)
	if (!value)
		return

	message_admins("[key_name_admin(usr)] dodaje [key_name_admin(value)] do drużyny [name]")
	log_admin("[key_name(usr)] added [key_name(value)] as a member of [name] team")

	add_member(value)

/datum/team/proc/admin_remove_member(mob/user,datum/mind/M)
	message_admins("[key_name_admin(usr)] usuwa [key_name_admin(M)] z drużyny [name]")
	log_admin("[key_name(usr)] removed [key_name(M)] from [name] team")
	remove_member(M)

//After a bit of consideration i block team deletion if there's any members left until unified objective handling is in.
/datum/team/proc/admin_delete(mob/user)
	if(members.len > 0)
		to_chat(user,"W drużynie są jeszcze członkowie. Najpierw ich usuń i upewnij się, że wiesz, co robisz.")
		return
	qdel(src)

/datum/team/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			return

/datum/team/proc/get_admin_commands()
	return list()

//Custom team subtype created by the panel, allow forcing hud for the team for now
/datum/team/custom
	var/datum/atom_hud/antag/custom_hud
	var/custom_hud_state = "traitor"

/datum/team/custom/add_member(datum/mind/new_member)
	. = ..()
	if(custom_hud)
		custom_hud.join_hud(new_member.current)
		set_antag_hud(new_member.current,custom_hud_state)

/datum/team/custom/remove_member(datum/mind/member)
	. = ..()
	if(custom_hud)
		custom_hud.leave_hud(member.current)

/datum/team/custom/get_admin_commands()
	. = ..()
	.["Force HUD"] = CALLBACK(src,PROC_REF(admin_force_hud))

//This is here if you want admin created teams to tell each other apart easily.
/datum/team/custom/proc/admin_force_hud(mob/user)
	var/list/possible_icons = icon_states('icons/mob/hud.dmi')
	var/new_hud_state = input(user,"Wybierz stan ikony HUD-a","Własny HUD","traitor") as null|anything in sortList(possible_icons)
	if(!new_hud_state)
		return
	//suppose could ask for color too
	custom_hud_state = new_hud_state
	custom_hud = new
	custom_hud.self_visible = TRUE
	GLOB.huds += custom_hud //Make it show in admin hud

	for(var/datum/mind/M in members)
		custom_hud.join_hud(M.current)
		set_antag_hud(M.current,custom_hud_state)
