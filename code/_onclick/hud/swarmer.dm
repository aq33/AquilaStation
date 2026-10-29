

/atom/movable/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/atom/movable/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Stwórz pułapkę (koszt: 5 zasobów)"
	desc = "Tworzy pułapkę, która nieśmiertelnie razi prądem każdego poza rojowcami, kto próbuje przez nią przejść. (koszt: 5 zasobów)"

/atom/movable/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/atom/movable/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Stwórz barykadę (koszt: 5 zasobów)"
	desc = "Tworzy zniszczalną barykadę, która zatrzymuje każdego poza rojowcami. Przepuszcza wiązki disablerów. (koszt: 5 zasobów)"

/atom/movable/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/atom/movable/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Powiel się (koszt: 50 zasobów)"
	desc = "Tworzy kolejnego z naszego rodzaju."

/atom/movable/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/atom/movable/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Napraw się"
	desc = "Naprawia uszkodzenia naszego ciała."

/atom/movable/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/atom/movable/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Przełącz światło"
	desc = "Włącza albo wyłącza nasze wbudowane światło."

/atom/movable/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ToggleLight()

/atom/movable/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Skontaktuj się z rojowcami"
	desc = "Wysyła wiadomość do wszystkich innych rojowców, jeśli jacyś istnieją."

/atom/movable/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/swarmer/FabricateTrap()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Barricade()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/Replicate()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/RepairSelf()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ToggleLight()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using
