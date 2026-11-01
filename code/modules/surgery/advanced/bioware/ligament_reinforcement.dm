/datum/surgery/advanced/bioware/ligament_reinforcement
	name = "Wzmocnienie więzadeł"
	desc = "Zabieg chirurgiczny, który dodaje ochronną klatkę z tkanki i kości wokół połączeń między tułowiem a kończynami, zapobiegając ich odcięciu. \
	Przez to jednak połączenia nerwowe łatwiej przerwać, więc obrażenia łatwiej unieruchamiają kończyny."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/reinforce_ligaments,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reinforce_ligaments
	name = "wzmocnij więzadła"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/reinforce_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wzmacniać więzadła [target].</span>",
		"[user] zaczyna wzmacniać więzadła [target].",
		"[user] zaczyna manipulować więzadłami [target].")

/datum/surgery_step/reinforce_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Wzmacniasz więzadła [target]!</span>",
		"[user] wzmacnia więzadła [target]!",
		"[user] kończy manipulować więzadłami [target].")
	new /datum/bioware/reinforced_ligaments(target)
	return TRUE

/datum/bioware/reinforced_ligaments
	name = "Wzmocnione więzadła"
	desc = "Więzadła i zakończenia nerwowe łączące tułów z kończynami chroni mieszanka kości i tkanek, przez co znacznie trudniej oddzielić je od ciała, ale łatwiej je unieruchomić."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/reinforced_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, "reinforced_ligaments")
	ADD_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "reinforced_ligaments")

/datum/bioware/reinforced_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, "reinforced_ligaments")
	REMOVE_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "reinforced_ligaments")
