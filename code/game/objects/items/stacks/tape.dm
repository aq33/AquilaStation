

/obj/item/stack/sticky_tape
	name = "taśma klejąca"
	singular_name = "taśma klejąca"
	desc = "Służy do przyklejania rzeczy, żeby te rzeczy przyklejały się do ludzi."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "z taśmą"
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5

	var/list/conferred_embed = EMBED_HARMLESS
	var/overwrite_existing = FALSE

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user)
	if(!istype(I))
		return

	if(I.embedding == conferred_embed)
		to_chat(user, "<span class='warning'>[I] jest już pokryty [src]!</span>")
		return

	user.visible_message("<span class='notice'>[user] zaczyna owijać [I] za pomocą [src].</span>", "<span class='notice'>Zaczynasz owijać [I] za pomocą [src].</span>")

	if(do_after(user, 30, target=I))
		I.embedding = conferred_embed
		I.updateEmbedding()
		to_chat(user, "<span class='notice'>Kończysz owijać [I] za pomocą [src].</span>")
		use(1)
		I.name = "[I.name] [prefix]"

		if(istype(I, /obj/item/grenade))
			var/obj/item/grenade/sticky_bomb = I
			sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "superklejąca taśma"
	singular_name = "superklejąca taśma"
	desc = "Być może najbardziej psotna substancja w galaktyce. Używaj z wyjątkowym brakiem ostrożności."
	icon_state = "tape_y"
	prefix = "z supertaśmą"
	conferred_embed = EMBED_HARMLESS_SUPERIOR

/obj/item/stack/sticky_tape/pointy
	name = "kolczasta taśma"
	singular_name = "kolczasta taśma"
	desc = "Służy do przyklejania rzeczy, żeby te rzeczy wbijały się w ludzi."
	icon_state = "tape_evil"
	prefix = "z kolczastą taśmą"
	conferred_embed = EMBED_POINTY

/obj/item/stack/sticky_tape/pointy/super
	name = "superkolczasta taśma"
	singular_name = "superkolczasta taśma"
	desc = "Nie wiedziałeś, że taśma może wyglądać tak złowrogo. Witaj na Stacji Kosmicznej 13."
	icon_state = "tape_spikes"
	prefix = "z superkolczastą taśmą"
	conferred_embed = EMBED_POINTY_SUPERIOR
