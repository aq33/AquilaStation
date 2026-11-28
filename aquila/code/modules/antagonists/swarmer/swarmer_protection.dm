// AQUILA - rojowce nie rozbierają systemów okrętu, tak jak już nie ruszały napędu FTL i studni naprawczych pancerza
// (ochrony NSV13 w code/modules/antagonists/swarmer/swarmer.dm i nsv13/.../FTL). Mistrzowie chcą przejąć sprawny okręt,
// a nie wrak: chronione są silniki i reaktory, konsole okrętu (stery, sensory, uzbrojenie), działa i wyrzutnie,
// maszyny do amunicji i sama amunicja okrętowa.

/// Odmowa rozbiórki systemu okrętu: komunikat dla rojowca i FALSE, żeby rojowiec AI nie próbował znowu
/mob/living/simple_animal/hostile/swarmer/proc/refuse_ship_system(message)
	to_chat(src, "<span class='warning'>[message]</span>")
	return FALSE

// Silniki i reaktory. Maszyny atmosferyczne i energetyczne są już chronione w core, ale bez komunikatu.
/obj/machinery/atmospherics/components/binary/stormdrive_reactor/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten reaktor należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten reaktor należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten reaktor należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/hypertorus/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten reaktor należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/ship_thruster/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten silnik okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/inertial_dampener/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Ten silnik okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

// Konsole okrętu: stery, nawigacja, sensory, uzbrojenie, reaktory (FTL ma własne ochrony w podtypach)
/obj/machinery/computer/ship/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/reactor/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/turbine_computer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/ams/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/anti_air/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/deckgun/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/laser_pd/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/sts_bsa_control/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/computer/ammo_sorter/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę konsolę okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

// Działa, wyrzutnie i maszyny do amunicji
/obj/machinery/ship_weapon/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/deck_turret/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/ammo_sorter/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/gauss_dispenser/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/railgun_charger/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/railgun_forge/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/missile_builder/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/machinery/broadside_shell_packer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/structure/gauss_rack/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("To uzbrojenie okrętu należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

// Amunicja okrętowa: pociski, torpedy, rakiety, ładunki prochowe, magazynki dział i ich części
/obj/item/ship_weapon/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę amunicję okrętową należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/item/powder_bag/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę amunicję okrętową należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/item/munition_part/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę amunicję okrętową należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")

/obj/item/ammo_box/magazine/nsv/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	return S.refuse_ship_system("Tę amunicję okrętową należy zachować, przyda się w przyszłości naszym panom. Przerywanie.")
