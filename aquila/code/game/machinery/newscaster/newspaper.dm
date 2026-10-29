/obj/item/newspaper
	name = "gazeta"
	desc = "Wydanie Gryfa, gazety krążącej po stacjach kosmicznych Nanotrasen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bapped")
	resistance_flags = FLAMMABLE
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/scribble=""
	var/scribble_page = null
	var/wantedAuthor
	var/wantedCriminal
	var/wantedBody
	var/wantedPhoto
	var/creation_time

/obj/item/newspaper/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] wpatruje się intensywnie w [src]! Wygląda na to, że próbuje popełnić sudoku... aż nagle w oczach pojawia się olśnienie!"))
	user.say(";DZIENNIKARSTWO TO MOJE POWOŁANIE! WSZYSCY CENIĄ BEZSTRONNE REPORTA-GLORF", forced="newspaper suicide")
	var/mob/living/carbon/human/H = user
	var/obj/W = new /obj/item/reagent_containers/food/drinks/bottle/whiskey(H.loc)
	playsound(H.loc, 'sound/items/drink.ogg', rand(10,50), TRUE)
	W.reagents.trans_to(H, W.reagents.total_volume, transfered_by = user)
	user.visible_message(span_suicide("[user] wypija zawartość butelki ([W.name]) jednym haustem! Trzeba było zostać przy sudoku!"))
	return TOXLOSS

/obj/item/newspaper/attack_self(mob/user)
	if(!istype(user) || !user.can_read(src))
		return
	ui_interact(user)

/obj/item/newspaper/ui_interact(mob/user, datum/tgui/ui)
	if(resistance_flags & ON_FIRE)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Newspaper", name)
		ui.open()

/obj/item/newspaper/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("next_page")
			//We're at the very end, nowhere else to go.
			if(curr_page >= length(news_content) + 1)
				return TRUE
			curr_page++
		if("prev_page")
			//We haven't started yet, nowhere else to go.
			if(curr_page <= 0)
				return TRUE
			curr_page--
		else
			return TRUE
	playsound(loc, "pageturn", 50, TRUE)
	return TRUE

/obj/item/newspaper/ui_static_data(mob/user)
	var/list/data = list()
	var/list/channels = list()
	var/page = 0
	for(var/datum/feed_channel/news_channel as anything in news_content)
		page++
		channels += list(list(
			"name" = news_channel.channel_name,
			"page_number" = page,
		))
	data["channels"] = channels
	return data

/obj/item/newspaper/ui_data(mob/user)
	var/list/data = list()
	data["current_page"] = curr_page
	data["scribble_message"] = (scribble_page == curr_page) ? scribble : null
	data["wanted_criminal"] = wantedAuthor ? wantedCriminal : null
	data["wanted_body"] = wantedAuthor ? wantedBody : null
	data["wanted_photo"] = null
	if(wantedAuthor && wantedPhoto)
		user << browse_rsc(wantedPhoto, "tmp_photow.png")
		data["wanted_photo"] = "tmp_photow.png"

	var/list/channel_data = list()
	data["channel_has_messages"] = FALSE
	if(!curr_page || curr_page > length(news_content))
		channel_data["channel_name"] = null
		channel_data["author_name"] = null
		channel_data["is_censored"] = null
		channel_data["channel_messages"] = list()
		data["channel_data"] = list(channel_data)
		return data
	var/datum/feed_channel/current_channel = news_content[curr_page]
	if(istype(current_channel))
		channel_data["channel_name"] = current_channel.channel_name
		channel_data["author_name"] = current_channel.return_author(notContent(current_channel.author_censor_time))
		var/censored = notContent(current_channel.D_class_censor_time)
		channel_data["is_censored"] = censored
		var/list/messages = list()
		if(!censored)
			var/i = 0
			for(var/datum/feed_message/feed_message as anything in current_channel.messages)
				i++
				if(feed_message.creation_time > creation_time)
					continue
				data["channel_has_messages"] = TRUE
				var/photo = null
				if(feed_message.img)
					photo = "tmp_photo[curr_page]_[i].png"
					user << browse_rsc(feed_message.img, photo)
				messages += list(list(
					"message" = "-[feed_message.return_body(notContent(feed_message.body_censor_time))]",
					"photo" = photo,
					"author" = feed_message.return_author(notContent(feed_message.author_censor_time)),
				))
		channel_data["channel_messages"] = messages
	data["channel_data"] = list(channel_data)
	return data

/obj/item/newspaper/proc/notContent(list/L)
	if(!L.len)
		return FALSE
	for(var/i=L.len;i>0;i--)
		var/num = abs(L[i])
		if(creation_time <= num)
			continue
		else
			if(L[i] > 0)
				return TRUE
			else
				return FALSE
	return FALSE

/obj/item/newspaper/attackby(obj/item/W, mob/living/user, list/modifiers)
	if(burn_paper_product_attackby_check(W, user))
		return

	if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			return
		if(scribble_page == curr_page)
			to_chat(user, span_warning("Na tej stronie już coś nabazgrano... Chyba nie chcesz robić tu bałaganu, co?"))
		else
			var/s = stripped_input(user, "Napisz coś", "Gazeta")
			if (!s)
				return
			if(!user.canUseTopic(src, BE_CLOSE))
				return
			scribble_page = curr_page
			scribble = s
			SStgui.update_uis(src)
			add_fingerprint(user)
	else
		return ..()
