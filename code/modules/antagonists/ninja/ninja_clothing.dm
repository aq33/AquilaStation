/**
 * # Ninja Mask
 *
 * Space ninja's mask.  Other than looking cool, doesn't do anything.
 *
 * A mask which only spawns as a part of space ninja's starting kit.  Functions as a gas mask.
 *
 */
/obj/item/clothing/mask/gas/ninja
	name = "maska ninja"
	desc = "Dopasowana maska, która jest jednocześnie filtrem powietrza i postmodernistycznym manifestem mody."
	icon_state = "ninja"
	item_state = "sechailer"
	strip_delay = 12 SECONDS
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/under/syndicate/ninja
	name = "kombinezon ninja"
	desc = "Wzmocniony nanotechnologią kombinezon zaprojektowany z myślą o maksymalnym komforcie i taktyczności."
	icon_state = "ninja_suit"
	strip_delay = 12 SECONDS
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	can_adjust = FALSE
