// AQUILA - the bandage replaced medical gauze (aq33/AquilaStation#530): a stack that stops bleeding like Bee gauze,
// heals a little brute, splints fractures (aquila/code/modules/wounds/blunt.dm) and can be cut into cloth.
// Gauze, bruise packs and ointment are gone from code/game/objects/items/stacks/medical.dm.
// Sprites from tgstation, already in aquila/icons/obj/medical/stack_medical.dmi (CC-BY-SA 3.0).

/obj/item/stack/medical/bandage
	name = "bandaż"
	singular_name = "bandaż"
	desc = "Rolka elastycznego bandaża, która świetnie tamuje krwawienie i leczy drobne stłuczenia. Unieruchomi też złamaną kończynę."
	icon = 'aquila/icons/obj/medical/stack_medical.dmi'
	icon_state = "bandage"
	item_state = "bandage"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	novariants = TRUE
	max_amount = 12
	stop_bleeding = BLEED_CRITICAL
	heal_brute = 5

/obj/item/stack/medical/bandage/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>Potrzebujesz co najmniej dwóch bandaży, by to zrobić!</span>")
			return
		new /obj/item/stack/sheet/cotton/cloth(user.drop_location())
		user.visible_message("[user] tnie [src] na kawałki materiału za pomocą [I].", \
					"<span class='notice'>Tniesz [src] na kawałki materiału za pomocą [I].</span>", \
					"<span class='italics'>Słyszysz cięcie.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/bandage/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] zaczyna zaciskać [src] na swojej szyi! Wygląda na to, że zapomniał, jak używać środków medycznych!</span>")
	return OXYLOSS

/obj/item/stack/medical/bandage/makeshift
	name = "prowizoryczny bandaż"
	singular_name = "prowizoryczny bandaż"
	desc = "Pas materiału z grubsza z czegoś wycięty. Tamuje krwawienie, ale nie leczy ran."
	icon_state = "bandage_makeshift"
	stop_bleeding = BLEED_SURFACE
	heal_brute = 0

/obj/item/stack/medical/bandage/sterile
	name = "sterylny bandaż"
	singular_name = "sterylny bandaż"
	desc = "Rolka elastycznego, sterylnego bandaża, która świetnie tamuje krwawienie, leczy drobne rany i je oczyszcza."
	self_delay = 0.5 SECONDS

/obj/item/stack/medical/bandage/sterile/one
	amount = 1

/obj/item/stack/medical/bandage/cyborg
	mats_per_unit = null
	is_cyborg = TRUE
	cost = 250
