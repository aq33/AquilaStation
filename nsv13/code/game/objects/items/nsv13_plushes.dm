/* This file was unticked before so I just commented this out
/obj/item/toy/plush/random
	name = "\improper Random Plush"
	icon_state = "debug"
	desc = "Oh no! What have you done! (if you see this, contact an upper being as soon as possible)."

/obj/item/toy/plush/random/Initialize()
	var/plush_type = pick(subtypesof(/obj/item/toy/plush/) - /obj/item/toy/plush/random/)
	new plush_type(loc)
	return INITIALIZE_HINT_QDEL
*/
/obj/item/toy/plush/hfighter
	name = "pluszak ciężkiego myśliwca"
	desc = "Uroczy pluszak w kształcie ciężkiego myśliwca Su-410 Scimitar."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "heavyfighter"
	attack_verb = list("bombarduje", "trąca", "taranuje", "torpeduje")
	squeak_override = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg'=1)

/obj/item/toy/plush/lfighter
	name = "pluszak lekkiego myśliwca"
	desc = "Uroczy pluszak w kształcie lekkiego myśliwca Su-818 Rapier."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "lightfighter"
	attack_verb = list("trąca", "taranuje", "ostrzeliwuje rakietą")
	squeak_override = list('nsv13/sound/effects/fighters/autocannon.ogg'=1)

/obj/item/toy/plush/lfighter/synlfighter
	name = "pluszak lekkiego myśliwca Syndykatu"
	desc = "Uroczy pluszak w kształcie lekkiego myśliwca Su-818 Rapier w barwach Syndykatu."
	icon_state = "synlightfighter"

/obj/item/toy/plush/transport
	name = "pluszak statku użytkowego"
	desc = "Uroczy pluszak w kształcie statku użytkowego Su-437 Sabre."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "transport"
	attack_verb = list("trąca", "taranuje")
	squeak_override = list('nsv13/sound/effects/fighters/warmup.ogg'=1)

/obj/item/toy/plush/transport/mining
	name = "pluszak statku górniczego"
	desc = "Uroczy pluszak w kształcie statku górniczego Su-437 Sabre."
	icon_state = "mining"
