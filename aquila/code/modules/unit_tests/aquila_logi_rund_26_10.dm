// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Objective that remembers which team it had when find_target() ran
/datum/objective/aquila_test_team_probe
	var/datum/team/team_at_find_target

/datum/objective/aquila_test_team_probe/find_target(list/dupe_search_range, list/blacklist)
	team_at_find_target = team

/// AQUILA - runtime'y z logów rund 6556 i 6558 (26.10.2026) oraz 6539 i 6540 (29.10.2026), wycieki składów z 30.10.2026. Każdy z tych przypadków wcześniej kończył się runtime'em, a runtime oblewa test.
/datum/unit_test/aquila_logi_rund_26_10

/datum/unit_test/aquila_logi_rund_26_10/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Mech: handler COMSIG_PARENT_ATTACKBY zwracał /datum/task z INVOKE_ASYNC
	var/obj/item/mecha_parts/chassis/ripley/chassis = allocate(/obj/item/mecha_parts/chassis/ripley)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	TEST_ASSERT_EQUAL(SEND_SIGNAL(chassis, COMSIG_PARENT_ATTACKBY, pen, user), NONE, "Construction attackby handler must not return the async task")

	// Frytkownica: deconstruct() nie wołał ..(), zniszczona maszyna zostawała na mapie
	var/obj/machinery/deepfryer/fryer = allocate(/obj/machinery/deepfryer)
	fryer.deconstruct(FALSE)
	TEST_ASSERT(QDELETED(fryer), "A destroyed deep fryer was not deleted")

	// Sny: has_status_effect() zwraca FALSE, a ?. na zerze wywalał dream() u każdego bez snów heretyka
	user.dream()
	TEST_ASSERT(!user.dreaming, "A conscious human should not keep dreaming")

	// Infiltratorzy: zespół musi być ustawiony, zanim cel szuka celu
	var/datum/team/infiltrator/team = new
	var/datum/objective/aquila_test_team_probe/probe = team.add_objective(new /datum/objective/aquila_test_team_probe)
	TEST_ASSERT_EQUAL(probe.team_at_find_target, team, "Infiltrator objectives must know their team in find_target()")
	qdel(team)
	qdel(probe)

	// Broń: strzał bez magazynka dzielił przez null w fire_sounds()
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	QDEL_NULL(gun.magazine)
	gun.fire_sounds()

	// Flaki: pierwsza smuga dostawała null zamiast listy, a choroby znikały zaraz po sygnale
	var/obj/effect/decal/cleanable/blood/gibs/gibs = allocate(/obj/effect/decal/cleanable/blood/gibs)
	gibs.AddComponent(/datum/component/infective, list(new /datum/disease/cold))
	gibs.streak(list(NORTH))
	TEST_ASSERT(locate(/datum/disease/cold) in gibs.streak_diseases, "Gib streak lost the diseases of the gibs")

	// Zębatka do_after: zdjęcie nakładki, gdy lista zarządzanych nakładek już nie istnieje (null -= list)
	user.managed_vis_overlays = null
	SSvis_overlays.remove_vis_overlay(user, list(new /obj/effect/overlay/vis))
	TEST_ASSERT(isnull(user.managed_vis_overlays), "Removing a vis overlay must not create the managed list")

	// Składy: usunięty członek wisiał w members/leader, a pager z kanałem tworzył cykl referencji (GC fail, hard delete)
	var/datum/squad/squad = GLOB.squad_manager.squads[1]
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human)
	squad.add_member(member)
	var/obj/item/squad_pager/pager = new(member, squad)
	var/datum/action/teamchat/chat_action = pager.squad_channel.chatAction
	qdel(pager)
	TEST_ASSERT(isnull(chat_action.holder), "A deleted squad pager is still held by its chat action")
	qdel(member)
	TEST_ASSERT(!(member in squad.members), "A deleted human stayed in their squad")
	TEST_ASSERT(squad.leader != member, "A deleted human stayed the squad leader")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
