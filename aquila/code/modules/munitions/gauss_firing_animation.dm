// Animacja strzału podwójnego działa Gaussa. Seria ma dwa strzały (burst_size = 2), a bazowa do_animation()
// pokazywała przy każdym strzale obie lufy, w dodatku chamber(rapidfire) od razu nadpisywał ją flickiem _chambering.
// Widać było tylko drugą lufę drugiego strzału, więc wyglądało, jakby strzelało jedno działko.
// Teraz każdy strzał to jedna lufa na zmianę (gauss_firing0, gauss_firing1), a szybkie przeładowanie w serii nie zmienia sprite'a.

/obj/machinery/ship_weapon/gauss_gun
	/// Lufa następnego strzału: 0 albo 1 (stany gauss_firing0 i gauss_firing1)
	var/next_barrel = 0
	/// Numer ostatniego strzału; starsza animacja nie dokańcza się na nowszej
	var/firing_animation_id = 0

// Pełne nadpisanie (LEGACY_OVERRIDES.md): bazowa wersja w nsv13/.../gauss_gun.dm animuje obie lufy na jeden strzał
/obj/machinery/ship_weapon/gauss_gun/do_animation()
	var/animation_id = ++firing_animation_id
	shake_with_inertia(gunner, 2, 1)
	flick("[initial(icon_state)]_firing[next_barrel]", src)
	next_barrel = !next_barrel
	sleep(0.3 SECONDS)
	if(animation_id != firing_animation_id)
		return // druga lufa tej serii już strzela
	flick("[initial(icon_state)]_unloading", src)
	sleep(fire_animation_length)
	if(animation_id != firing_animation_id)
		return
	if(chambered && ("[initial(icon_state)]_chambered" in icon_state_list))
		icon_state = "[initial(icon_state)]_chambered"
	else
		icon_state = initial(icon_state)

// Przeładowanie w serii bez flick(_chambering), który przerywał animację strzału. Sprite ustawia do_animation()
/obj/machinery/ship_weapon/gauss_gun/chamber(rapidfire = FALSE)
	if(!rapidfire)
		return ..()
	if((state == STATE_FED) && length(ammo))
		state = STATE_CHAMBERING
		sleep(chamber_delay_rapid)
		chambered = ammo[1]
		state = STATE_CHAMBERED
	update()
