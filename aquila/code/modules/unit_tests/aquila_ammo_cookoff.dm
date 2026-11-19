/// AQUILA - przegrzewanie się amunicji (aquila/code/modules/munitions/ammo_cookoff.dm): worek prochu w ogniu od 200°C
/// zaczyna odliczanie zamiast wybuchać od razu, wybucha po odliczaniu, wyjęty z ognia stygnie, postrzał i wybuch
/// obok go odpalają z limitem łańcucha, a obojętna kula armatnia i nieuzbrojony pocisk na to nie reagują.

/// Komponent testowy: zapisuje wybuch zamiast robić prawdziwą eksplozję w miejscu testów.
/datum/component/volatile/aquila_test_dummy
	var/detonated = FALSE

/datum/component/volatile/aquila_test_dummy/explode()
	if(aquila_cookoff_intercept())
		return FALSE
	detonated = TRUE
	return TRUE

/datum/unit_test/aquila_ammo_cookoff

/datum/unit_test/aquila_ammo_cookoff/proc/dummy_bag()
	var/obj/item/powder_bag/bag = allocate(/obj/item/powder_bag)
	qdel(bag.GetComponent(/datum/component/volatile))
	// niestabilność 10 daje 100% szans w każdym losowaniu, więc test jest deterministyczny
	return bag.AddComponent(/datum/component/volatile/aquila_test_dummy, 10, TRUE)

/datum/unit_test/aquila_ammo_cookoff/proc/stop_timer(datum/component/volatile/volatile)
	if(volatile.cookoff_timer)
		deltimer(volatile.cookoff_timer)
		volatile.cookoff_timer = null

/datum/unit_test/aquila_ammo_cookoff/Run()
	var/old_window = GLOB.aquila_cookoff_chain_window_start
	var/old_count = GLOB.aquila_cookoff_chain_count
	. = run_checks()
	GLOB.aquila_cookoff_chain_window_start = old_window
	GLOB.aquila_cookoff_chain_count = old_count

/datum/unit_test/aquila_ammo_cookoff/proc/run_checks()
	// obojętna kula armatnia nie ma komponentu i nic jej nie robi ogień
	var/obj/item/ship_weapon/ammunition/naval_artillery/cannonball/ball = allocate(/obj/item/ship_weapon/ammunition/naval_artillery/cannonball)
	if(ball.GetComponent(/datum/component/volatile))
		return Fail("Kula armatnia dostała komponent niestabilności")
	ball.fire_act(T0C + 500, 1000)
	if(QDELETED(ball))
		return Fail("Kula armatnia zniknęła w ogniu")

	var/obj/item/powder_bag/real_bag = allocate(/obj/item/powder_bag)
	var/datum/component/volatile/real = real_bag.GetComponent(/datum/component/volatile)
	if(!real || !real.volatile_when_hit)
		return Fail("Worek prochu nie jest niestabilny albo nie reaguje na uderzenia")
	var/obj/item/ship_weapon/ammunition/broadside_shell/broadside = allocate(/obj/item/ship_weapon/ammunition/broadside_shell)
	if(!broadside.GetComponent(/datum/component/volatile))
		return Fail("Pocisk burtowy (spakowany proch) nie jest niestabilny")

	// ogień poniżej progu nie odpala, od progu zaczyna odliczanie, ale nie wybucha od razu
	var/datum/component/volatile/aquila_test_dummy/fire = dummy_bag()
	var/obj/item/powder_bag/bag = fire.parent
	for(var/i in 1 to 5)
		bag.fire_act(T20C, 100)
	if(fire.cooking_off)
		return Fail("Worek prochu zaczął się przegrzewać w 20°C")
	bag.fire_act(T0C + 300, 100)
	if(!fire.cooking_off || !fire.cookoff_timer)
		return Fail("Worek prochu w ogniu 300°C nie zaczął odliczania")
	if(fire.detonated)
		return Fail("Worek prochu w ogniu wybuchł od razu, bez ostrzeżenia")
	// dalej w ogniu po odliczaniu: wybucha
	stop_timer(fire)
	bag.fire_act(T0C + 300, 100)
	fire.finish_cookoff()
	if(!fire.detonated)
		return Fail("Worek prochu, który został w ogniu, nie wybuchł po odliczaniu")

	// wyjęty z ognia (zimny kafel, dawno bez ognia) stygnie
	var/datum/component/volatile/aquila_test_dummy/cooled = dummy_bag()
	var/obj/item/powder_bag/cooled_bag = cooled.parent
	cooled_bag.fire_act(T0C + 300, 100)
	if(!cooled.cooking_off)
		return Fail("Drugi worek prochu w ogniu nie zaczął odliczania")
	stop_timer(cooled)
	cooled.last_heat_time = -INFINITY
	cooled.finish_cookoff()
	if(cooled.detonated || cooled.cooking_off)
		return Fail("Worek prochu wyjęty z ognia wybuchł albo dalej odlicza")

	// postrzał: słaby nie odpala, mocny tak
	var/obj/item/projectile/bullet/shot = allocate(/obj/item/projectile/bullet)
	shot.damage_type = BRUTE
	shot.nodamage = FALSE
	var/datum/component/volatile/aquila_test_dummy/shot_bag = dummy_bag()
	shot.damage = 4
	shot_bag.on_bullet_act(shot_bag.parent, shot)
	if(shot_bag.cooking_off)
		return Fail("Pocisk za 4 obrażenia odpalił worek prochu")
	shot.damage = 20
	shot_bag.on_bullet_act(shot_bag.parent, shot)
	if(!shot_bag.cooking_off)
		return Fail("Pocisk za 20 obrażeń nie odpalił worka prochu")
	stop_timer(shot_bag)

	// nieuzbrojony pocisk artyleryjski nie reaguje na postrzał
	var/obj/item/ship_weapon/ammunition/naval_artillery/unarmed = allocate(/obj/item/ship_weapon/ammunition/naval_artillery)
	var/datum/component/volatile/unarmed_volatile = unarmed.GetComponent(/datum/component/volatile)
	if(!unarmed_volatile)
		return Fail("Pocisk artylerii okrętowej nie jest niestabilny")
	shot.damage = 50
	unarmed_volatile.on_bullet_act(unarmed, shot)
	if(unarmed_volatile.cooking_off)
		return Fail("Nieuzbrojony pocisk artyleryjski zapalił się od postrzału")

	// wybuch obok: po wyczerpaniu limitu łańcucha nic się nie zapala
	var/datum/component/volatile/aquila_test_dummy/chain = dummy_bag()
	GLOB.aquila_cookoff_chain_window_start = world.time
	GLOB.aquila_cookoff_chain_count = 1000
	for(var/i in 1 to 20)
		chain.on_ex_act(chain.parent, EXPLODE_HEAVY, null)
	if(chain.cooking_off)
		return Fail("Wybuch obok odpalił worek mimo wyczerpanego limitu łańcucha")
	GLOB.aquila_cookoff_chain_count = 0
	for(var/i in 1 to 40)
		chain.on_ex_act(chain.parent, EXPLODE_HEAVY, null)
		if(chain.cooking_off)
			break
	if(!chain.cooking_off)
		return Fail("Ciężka fala wybuchu w 40 próbach nie odpaliła worka prochu")
	if(chain.detonated)
		return Fail("Worek prochu od wybuchu obok wybuchł od razu, bez odliczania")
	if(GLOB.aquila_cookoff_chain_count != 1)
		return Fail("Wybuch łańcuchowy nie zaliczył się do limitu (licznik [GLOB.aquila_cookoff_chain_count])")
	stop_timer(chain)
	return TRUE
