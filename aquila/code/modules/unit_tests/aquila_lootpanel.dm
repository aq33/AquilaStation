// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - port tgstation/tgstation#82533 (code/modules/unit_tests/lootpanel.dm): okno kafelka zbiera zawartość i reaguje na usunięcie
/datum/unit_test/aquila_lootpanel_contents

/datum/unit_test/aquila_lootpanel_contents/Run()
	// allocate() wkłada pole do argumentów, a datumy bez New(loc) wtedy padają, więc tworzymy je ręcznie
	var/datum/client_interface/mock_client = new
	var/datum/lootpanel/panel = new(mock_client)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	mock_client.mob = labrat
	var/turf/one_over = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	// W pełnym przebiegu wcześniejsze testy zostawiały na tym polu obiekty i okno widziało ich więcej
	for(var/atom/movable/leftover in one_over)
		qdel(leftover)
	var/obj/item/storage/toolbox/box = allocate(/obj/item/storage/toolbox, one_over)

	panel.open(one_over)
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Contents should populate on open")
	TEST_ASSERT_EQUAL(length(panel.to_image), 2, "to_image should've populated (unit testing)")
	var/datum/search_object/first = panel.contents[1]
	TEST_ASSERT_EQUAL(first.item, one_over, "First item should be the source turf")

	var/datum/search_object/searchable = panel.contents[2]
	TEST_ASSERT_EQUAL(searchable.item, box, "Second item should be the box")

	qdel(box)
	TEST_ASSERT_EQUAL(length(panel.contents), 1, "Contents should update on searchobj deleted")
	TEST_ASSERT_EQUAL(length(panel.to_image), 1, "to_image should update on searchobj deleted")

	allocate(/obj/item/storage/toolbox, one_over)
	TEST_ASSERT_EQUAL(length(panel.contents), 1, "Contents shouldn't update, we're dumb")
	TEST_ASSERT_EQUAL(length(panel.to_image), 1, "to_image shouldn't update, we're dumb")

	panel.populate_contents() // this also calls reset_contents bc length(contents)
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Contents should repopulate with the new toolbox")

	panel.populate_contents()
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Panel shouldnt dupe searchables if reopened")

	panel.ui_close(labrat)
	mock_client.mob = null
	qdel(panel)
	qdel(mock_client)

/// AQUILA - Alt+klik na krzesło obraca je i nie otwiera okna kafelka; na skrzynkę z narzędziami otwiera
/datum/unit_test/aquila_lootpanel_alt_click_blockers

/datum/unit_test/aquila_lootpanel_alt_click_blockers/Run()
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, run_loc_floor_bottom_left)
	var/obj/item/storage/toolbox/box = allocate(/obj/item/storage/toolbox, run_loc_floor_bottom_left)
	TEST_ASSERT(!chair.opens_loot_panel(), "A chair (it has its own Alt+click action) opened the tile window")
	TEST_ASSERT(box.opens_loot_panel(), "A toolbox does not open the tile window")
	TEST_ASSERT(run_loc_floor_bottom_left.opens_loot_panel(), "A floor does not open the tile window")

	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!labrat.open_loot_panel(box, run_loc_floor_bottom_left), "A mob without a client opened a tile window")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
