/**
 * tgui state: admin_state
 *
 * Checks that the user is an admin, end-of-story.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

GLOBAL_DATUM_INIT(admin_state, /datum/ui_state/admin_state, new)

/datum/ui_state/admin_state
	/// AQUILA - uprawnienia wymagane przez okno (domyślnie R_ADMIN, jak wcześniej), port z tg
	var/required_perms = R_ADMIN

/datum/ui_state/admin_state/New(required_perms = R_ADMIN)
	. = ..()
	src.required_perms = required_perms

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, required_perms))
		return UI_INTERACTIVE
	return UI_CLOSE

/datum/ui_state/admin_state/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, required_perms))
		return FALSE
	return ..()

/// AQUILA - stany admina dla konkretnych uprawnień (odpowiednik ADMIN_STATE(perms) z tg)
GLOBAL_LIST_EMPTY(admin_states)
GLOBAL_PROTECT(admin_states)

/proc/get_admin_state(required_perms = R_ADMIN)
	var/key = "[required_perms]"
	var/datum/ui_state/admin_state/state = GLOB.admin_states[key]
	if(!state)
		state = new /datum/ui_state/admin_state(required_perms)
		GLOB.admin_states[key] = state
	return state
