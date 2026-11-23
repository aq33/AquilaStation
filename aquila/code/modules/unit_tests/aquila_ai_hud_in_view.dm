// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Każdy element HUD-u SI mieści się w widoku 15x15. Przycisk poza widokiem poszerzał mapę o pas, w którym SI widziała same podłogi.
/datum/unit_test/aquila_ai_hud_in_view

/datum/unit_test/aquila_ai_hud_in_view/Run()
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, run_loc_floor_bottom_left, null, brain_holder)
	var/datum/hud/ai/hud = new(ai)
	var/list/outside = list()
	for(var/atom/movable/screen/element as anything in hud.static_inventory)
		if(!element.screen_loc)
			continue
		var/list/edges = aq_screen_loc_edges(element.screen_loc, 15, 15)
		if(!edges)
			outside += "[element.type] ([element.screen_loc]): nieczytelna pozycja"
		else if(edges[1] < 0 || edges[2] < 0 || edges[1] + 1 > 15 || edges[2] + 1 > 15)
			outside += "[element.type] ([element.screen_loc])"
	qdel(hud)
	TEST_ASSERT(!length(outside), "Poza widokiem 15x15: [english_list(outside)]")

/// Lewy dolny róg elementu ekranu w kafelkach od 0 (x, y) przy danym widoku; null, gdy format nieobsługiwany
/datum/unit_test/aquila_ai_hud_in_view/proc/aq_screen_loc_edges(screen_loc, view_x, view_y)
	var/list/parts = splittext(screen_loc, ",")
	if(length(parts) != 2)
		return null
	var/list/x_y = list(null, null)
	var/list/centers = list()
	for(var/part in parts)
		var/list/bits = splittext(part, ":")
		var/pixel = length(bits) > 1 ? text2num(bits[2]) : 0
		var/static/regex/anchor_regex = regex(@"^(WEST|EAST|SOUTH|NORTH|CENTER)([+-]\d+)?$")
		if(!anchor_regex.Find(bits[1]))
			return null
		var/anchor = anchor_regex.group[1]
		var/shift = anchor_regex.group[2] ? text2num(anchor_regex.group[2]) : 0
		switch(anchor)
			if("WEST")
				x_y[1] = shift + pixel / world.icon_size
			if("EAST")
				x_y[1] = view_x - 1 + shift + pixel / world.icon_size
			if("SOUTH")
				x_y[2] = shift + pixel / world.icon_size
			if("NORTH")
				x_y[2] = view_y - 1 + shift + pixel / world.icon_size
			if("CENTER")
				centers += list(list(shift, pixel))
	// CENTER bierze oś, której nie zajęła druga część (pierwsza część to x, gdy obie są CENTER)
	for(var/list/center in centers)
		var/axis = isnull(x_y[1]) ? 1 : 2
		x_y[axis] = round(((axis == 1 ? view_x : view_y) - 1) / 2) + center[1] + center[2] / world.icon_size
	if(isnull(x_y[1]) || isnull(x_y[2]))
		return null
	return x_y

#undef TEST_ASSERT
