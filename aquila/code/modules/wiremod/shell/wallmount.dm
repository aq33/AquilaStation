/obj/structure/wallmount_circuit
	name = "skrzynka na układ"
	desc = "Skrzynka na ścianę, w której można zainstalować układy scalone."
	icon = 'aquila/icons/obj/wiremod/circuits.dmi'
	icon_state = "wallmount"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE

	resistance_flags = LAVA_PROOF | FIRE_PROOF

/obj/structure/wallmount_circuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)

/obj/structure/wallmount_circuit/wrench_act(mob/living/user, obj/item/tool)
	var/datum/component/shell/shell_comp = GetComponent(/datum/component/shell)
	if(shell_comp.locked)
		balloon_alert(user, "zablokowane!")
		return ITEM_INTERACT_FAILURE
	to_chat(user, span_notice("Zaczynasz odkręcać skrzynkę układu..."))
	if(tool.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("Odkręcasz skrzynkę układu."))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/wallframe/circuit
	name = "rama skrzynki na układ"
	desc = "Skrzynka, którą można zamontować na ścianie i zainstalować w niej układy."
	icon = 'aquila/icons/obj/wiremod/circuits.dmi'
	icon_state = "wallmount_assembly"
	result_path = /obj/structure/wallmount_circuit
	pixel_shift = 32
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
