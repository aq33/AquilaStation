// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/_lhs = ##a; \
	var/_rhs = ##b; \
	if (_lhs != _rhs) { \
		return Fail("Expected [isnull(_lhs) ? "null" : _lhs] to be equal to [isnull(_rhs) ? "null" : _rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - a sealed MODsuit on a digitigrade lizard: gauntlets are drawn, the helmet hides antennae,
/// legs are plantigrade while sealed and digitigrade again after unsealing
/datum/unit_test/aquila_modsuit_species

/datum/unit_test/aquila_modsuit_species/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	wearer.set_species(/datum/species/lizard/ashwalker)
	var/obj/item/bodypart/leg = wearer.get_bodypart(BODY_ZONE_L_LEG)
	TEST_ASSERT(leg.bodytype & BODYTYPE_DIGITIGRADE, "An ash walker should have digitigrade legs")
	TEST_ASSERT_EQUAL(leg.limb_id, "digitigrade", "Naked ash walker legs should be drawn digitigrade")

	var/obj/item/mod/control/pre_equipped/standard/mod = allocate(/obj/item/mod/control/pre_equipped/standard)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(mod, mod.slot_flags, disable_warning = TRUE), "The MODsuit could not be put on")
	var/list/parts = mod.get_parts()
	for(var/obj/item/part as anything in parts)
		TEST_ASSERT(mod.deploy(null, part), "[part] could not be deployed")
	TEST_ASSERT_EQUAL(leg.limb_id, "digitigrade", "Unsealed MODsuit should not change the legs")
	for(var/obj/item/part as anything in parts)
		mod.seal_part(part, is_sealed = TRUE)

	var/obj/item/clothing/gloves/mod/gauntlets = mod.get_part_from_slot(ITEM_SLOT_GLOVES)
	var/mutable_appearance/gloves_overlay = wearer.overlays_standing[GLOVES_LAYER]
	TEST_ASSERT(istype(gloves_overlay), "Sealed gauntlets have no worn overlay")
	TEST_ASSERT_EQUAL(gloves_overlay.icon_state, gauntlets.icon_state, "Gauntlets are drawn with the wrong state")
	TEST_ASSERT(icon_exists(gloves_overlay.icon, gloves_overlay.icon_state), "Gauntlet worn state \"[gloves_overlay.icon_state]\" is missing from [gloves_overlay.icon]")

	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	TEST_ASSERT(helmet.flags_inv & HIDEANTENNAE, "Sealed MOD helmet does not hide antennae")

	TEST_ASSERT_EQUAL(leg.limb_id, "lizard", "Legs in a sealed MODsuit should be plantigrade")

	for(var/obj/item/part as anything in parts)
		mod.seal_part(part, is_sealed = FALSE)
	TEST_ASSERT(!(helmet.flags_inv & HIDEANTENNAE), "Unsealed MOD helmet still hides antennae")
	TEST_ASSERT_EQUAL(leg.limb_id, "digitigrade", "Legs should be digitigrade again after unsealing")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
