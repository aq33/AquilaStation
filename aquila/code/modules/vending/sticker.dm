/obj/machinery/vending/sticker
	name = "\improper automat z naklejkami"
	desc = "Mechanika niespodzianek!"
	product_ads = "Przyklej się do mnie!;Zostań na dłużej, przylgnij!;Trzymaj się tego!"
	icon = 'aquila/icons/obj/vending_sticker.dmi'
	icon_state = "gacha"
	light_color = LIGHT_COLOR_CYAN
	products = list(/obj/item/sticker_gacha/series_1 = 15, /obj/item/sticker_gacha/series_2 = 15)
	refill_canister = /obj/item/vending_refill/sticker
	default_price = 35
	extra_price = 50

/obj/machinery/vending/sticker/Initialize(mapload)
	. = ..()
	fill_sticker_globals()

/obj/item/vending_refill/sticker
	machine_name = "automat z naklejkami"
	icon_state = "refill_smoke"

//You can make this generic if you want to use it elsehwere
/obj/item/sticker_gacha
	name = "kula gacha z naklejką"
	desc = "Kula z nagrodą. Co może być w środku?!"
	icon = 'aquila/icons/obj/sticker.dmi'
	icon_state = "gacha_red"
	w_class = WEIGHT_CLASS_SMALL
	///What series does this gacha pull from
	var/series = STICKER_SERIES_1

/obj/item/sticker_gacha/Initialize(mapload)
	. = ..()
	icon_state = "gacha_[pick("red", "green", "blue")]"

/obj/item/sticker_gacha/interact(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Zaczynasz podważać [src].</span>")
	if(do_after(user, 2.5 SECONDS, target = src))
		playsound(user, 'sound/effects/cartoon_pop.ogg', 35, TRUE)
		//Build prize
		user.dropItemToGround(src)
		fill_sticker_globals()
		//aquila: losowanie ważone drop_rate - samo pick() dawało mitycznym te same szanse co pospolitym
		var/list/weighted_pool = list()
		for(var/obj/item/sticker/sticker_type as anything in GLOB.stickers_by_series["[series]"])
			weighted_pool[sticker_type] = initial(sticker_type.drop_rate)
		var/obj/item/sticker/S = pickweight(weighted_pool)
		S = new S(get_turf(src))
		user.put_in_active_hand(S)
		//Dopamine
		playsound(user, 'sound/items/party_horn.ogg', 35, TRUE)
		user.add_emitter(/obj/emitter/confetti, "confetti", 10, lifespan = 15)
		//Kill ourselves
		qdel(src)
	else
		to_chat(user, "<span class='warning'>Nie udaje ci się otworzyć [src].</span>")

/obj/item/sticker_gacha/series_1
	series = STICKER_SERIES_1
	custom_price = 35
/obj/item/sticker_gacha/series_2
	series = STICKER_SERIES_2
	custom_price = 35
