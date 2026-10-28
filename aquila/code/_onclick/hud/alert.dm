/atom/movable/screen/alert/turgid
	name = "Nabrzmiały" // tak mi gugel translejt sugeruje
	desc = "Tak się opiłeś, że czujesz się jak beczka." // idk joker zmienisz na lepsze
	icon = 'aquila/icons/mob/screen_alert.dmi'
	icon_state = "turgid"

/atom/movable/screen/alert/thirsty
	name = "Spragniony"
	desc = "Jakiś napój byłby mile widziany."
	icon = 'aquila/icons/mob/screen_alert.dmi'
	icon_state = "thirsty"

/atom/movable/screen/alert/parched
	name = "Odwodniony"
	desc = "Jesteś odwodniony." // tu coś dopisać może
	icon = 'aquila/icons/mob/screen_alert.dmi'
	icon_state = "dehydrated"

/atom/movable/screen/alert/need_to_shit
	name = "Przemiana materii"
	desc = "Musisz skorzystać z ubikacji. Kliknij, żeby załatwić się na miejscu."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	clickable_glow = TRUE

/atom/movable/screen/alert/about_to_shit_myself
	name = "Pilna potrzeba"
	desc = "Krecik puka w taborecik! Kliknij, żeby załatwić się na miejscu."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet10"
	clickable_glow = TRUE

// Kliknięcie w potrzebę: wypróżnienie na miejscu (na sedesie jak z ubikacji)
/atom/movable/screen/alert/need_to_shit/Click()
	var/mob/living/L = usr
	if(istype(L) && L == owner)
		L.defecate_here()

/atom/movable/screen/alert/about_to_shit_myself/Click()
	var/mob/living/L = usr
	if(istype(L) && L == owner)
		L.defecate_here()
