// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - koło emotek: gwiazdka dodaje i usuwa emotkę, koło ma limit
/datum/unit_test/emote_wheel_toggle

/datum/unit_test/emote_wheel_toggle/Run()
	var/datum/preferences/prefs = new
	var/list/keys = list()
	for(var/key in GLOB.emote_list)
		keys += key
	TEST_ASSERT(length(keys) > 13, "Too few emotes to fill the wheel")
	TEST_ASSERT(prefs.toggle_quick_emote(keys[1]), "Couldn't add an emote to an empty wheel")
	TEST_ASSERT(keys[1] in prefs.get_quick_emotes(), "The added emote isn't in the wheel")
	TEST_ASSERT(prefs.toggle_quick_emote(keys[1]), "Couldn't remove the emote")
	TEST_ASSERT_EQUAL(length(prefs.get_quick_emotes()), 0, "The emote stayed in the wheel")
	for(var/i in 1 to 12)
		prefs.toggle_quick_emote(keys[i])
	TEST_ASSERT(!prefs.toggle_quick_emote(keys[13]), "The wheel took a 13th emote")
	qdel(prefs)

/// AQUILA - limit rewolucji: tak jak kult, w granicach min-max i tylko w górę
/datum/unit_test/revolution_cap

/datum/unit_test/revolution_cap/Run()
	var/datum/team/revolution/team = new
	team.update_rev_cap()
	TEST_ASSERT(team.rev_cap >= team.min_rev_cap && team.rev_cap <= team.max_rev_cap, "Revolution cap [team.rev_cap] out of bounds")
	team.rev_cap = team.max_rev_cap
	team.update_rev_cap()
	TEST_ASSERT_EQUAL(team.rev_cap, team.max_rev_cap, "Revolution cap went down")
	TEST_ASSERT(team.can_convert(), "An empty revolution can't convert")
	qdel(team)

/// AQUILA - zlecenia amunicji w konsoli cargo: każde chce czegoś, co istnieje
/datum/unit_test/munitions_bounties

/datum/unit_test/munitions_bounties/Run()
	for(var/bounty_type in subtypesof(/datum/bounty/item/munitions))
		var/datum/bounty/item/bounty = new bounty_type
		TEST_ASSERT(length(bounty.wanted_types), "[bounty_type] wants nothing")
		TEST_ASSERT(bounty.name && bounty.description, "[bounty_type] has no name or description")
		qdel(bounty)

/// AQUILA - wybór misji: losowane misje się nie powtarzają, pierwsza to wybrany tryb
/datum/unit_test/mission_choice

/datum/unit_test/mission_choice/Run()
	var/list/choices = SSovermap_mode.mission_choices
	if(!length(choices))
		return
	TEST_ASSERT_EQUAL(choices[1], SSovermap_mode.mode.type, "The first mission isn't the rolled mode")
	TEST_ASSERT_EQUAL(length(choices), length(uniqueList(choices)), "A mission was offered twice")
	for(var/mode_type in choices)
		TEST_ASSERT(mission_choice_name(mode_type), "[mode_type] has no name")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
