/datum/surgery/advanced/bioware/ligament_hook
	name = "Hak więzadłowy"
	desc = "Zabieg chirurgiczny, który przekształca połączenia między tułowiem a kończynami, dzięki czemu odcięte kończyny można przyczepić ręcznie. \
	Osłabia to jednak połączenie, przez co łatwiej je też odczepić."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/reshape_ligaments,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reshape_ligaments
	name = "przekształć więzadła"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/reshape_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz przekształcać więzadła [target] w kształt haka.</span>",
		"[user] zaczyna przekształcać więzadła [target] w kształt haka.",
		"[user] zaczyna manipulować więzadłami [target].")

/datum/surgery_step/reshape_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Przekształcasz więzadła [target] w łączący hak!</span>",
		"[user] przekształca więzadła [target] w łączący hak!",
		"[user] kończy manipulować więzadłami [target].")
	new /datum/bioware/hooked_ligaments(target)
	return TRUE

/datum/bioware/hooked_ligaments
	name = "Hakowate więzadła"
	desc = "Więzadła i zakończenia nerwowe łączące tułów z kończynami mają kształt haka, więc kończyny można przyczepić bez operacji, ale łatwiej je odciąć."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/hooked_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_LIMBATTACHMENT, "ligament_hook")
	ADD_TRAIT(owner, TRAIT_EASYDISMEMBER, "ligament_hook")

/datum/bioware/hooked_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_LIMBATTACHMENT, "ligament_hook")
	REMOVE_TRAIT(owner, TRAIT_EASYDISMEMBER, "ligament_hook")
