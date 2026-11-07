// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - runtime'y z rund 6562-6563: każdy przypadek wywołany tak jak w grze, runtime oblewa test
/datum/unit_test/aquila_logi_rund_6563

/datum/unit_test/aquila_logi_rund_6563/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Broń energetyczna: strzał tańszy niż 1% ogniwa dawał 0% i dzielenie przez zero w fire_sounds()
	var/obj/item/gun/energy/laser/gun = allocate(/obj/item/gun/energy/laser)
	gun.cell.maxcharge = 10000000
	gun.cell.charge = gun.cell.maxcharge
	gun.fire_sounds()

	// Płótno: klik poza siatką trafiał w grid[x][y] bez sprawdzenia zakresu
	var/obj/item/canvas/canvas = allocate(/obj/item/canvas)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	user.put_in_active_hand(pen)
	var/datum/tgui/ui = new(user, canvas, "Canvas")
	ui.status = UI_INTERACTIVE
	usr = user
	TEST_ASSERT(!canvas.ui_act("paint", list("x" = "0", "y" = "1"), ui), "Painting outside the canvas succeeded")
	TEST_ASSERT(!canvas.ui_act("paint", list("x" = "1", "y" = "[canvas.height + 1]"), ui), "Painting below the canvas succeeded")
	TEST_ASSERT(canvas.ui_act("paint", list("x" = "1", "y" = "1"), ui), "Painting inside the canvas failed")
	usr = null
	qdel(ui)

	// Chmura z opryskiwacza bez sprayującego: log_combat() czytał null.log_message
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	log_combat(null, target, "sprayed")

	// Działo bez podpiętej broni overmapy
	var/obj/machinery/ship_weapon/railgun/railgun = allocate(/obj/machinery/ship_weapon/railgun)
	railgun.linked_overmap_ship_weapon = null
	railgun.overmap_sound()

#undef TEST_ASSERT
