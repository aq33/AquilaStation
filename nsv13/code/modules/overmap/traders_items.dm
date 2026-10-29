
//Credit goes to cdey for these sprites (Thanks!)
/obj/structure/overmap/trader
	name = "stacja handlowa"
	icon = 'nsv13/icons/overmap/neutralstation.dmi'
	icon_state = "combust"
	damage_states = FALSE //Not yet implemented
	faction = "nanotrasen"//Placeholder, set by trader.
	mass = MASS_IMMOBILE
	brakes = TRUE
	obj_integrity = 3000 //Really robust, but not invincible.
	max_integrity = 3000
	bound_width = 224
	bound_height = 224
	req_one_access = list(ACCESS_CARGO, ACCESS_SYNDICATE, ACCESS_HEADS)
	var/datum/trader/inhabited_trader = null

/obj/structure/overmap/trader/try_hail(mob/living/user)
	if(!isliving(user))
		return FALSE
	if(inhabited_trader)
		if(!allowed(user)) //Only cargo auth'd personnel can make purchases at traders.
			to_chat(user, "<span class='warning'>Ostrzeżenie: nie możesz otworzyć kanału komunikacyjnego bez odpowiedniego dostępu zaopatrzeniowego zarejestrowanego na karcie ID.</span>")
			return FALSE
		inhabited_trader.greeting = pick(inhabited_trader.greetings)
		inhabited_trader.ui_interact(user)
		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
		to_chat(user, "<span class='boldnotice'>[pick(inhabited_trader.greetings)]</span>")
	else
		return ..()

/obj/structure/overmap/trader/can_move()
	//Nope!
	return FALSE

/obj/structure/overmap/trader/shipyard
	name = "stocznia"
	icon_state = "robust"

/obj/structure/overmap/trader/syndicate
	name = "skład broni"
	icon_state = "syndie"
	faction = "syndicate"
	supply_pod_type = /obj/structure/closet/supplypod/syndicate_odst

/obj/structure/overmap/trader/independent
	faction = "unaligned" //TODO: make this actually do something
	supply_pod_type = /obj/structure/closet/supplypod

/obj/structure/overmap/trader/proc/set_trader(datum/trader/bob) //The love story of alice and bob continues.
	name = "[bob.name]"
	ai_controlled = FALSE //Yep, not a whole lot we can do about that.
	inhabited_trader = bob
	bob.current_location = src

/obj/structure/overmap/trader/Destroy()
	qdel(inhabited_trader)
	. = ..()

/obj/structure/overmap/trader/LateInitialize()
	. = ..()
	if((datum_flags & DF_ISPROCESSING) && (!current_system || !current_system.occupying_z))
		STOP_PROCESSING(SSphysics_processing, src)

/datum/map_template/boarding/smalloutpost
	name = "placówka klasy Crab (wnętrze)"
	mappath = "_maps/templates/boarding/syndicate/smalloutpost.dmm"

/obj/structure/overmap/trader/syndicate/outpost
	name = "placówka Syndykatu"
	icon = 'nsv13/icons/overmap/smallstation.dmi'
	icon_state = "outpost"
	ai_controlled = TRUE
	ai_behaviour = AI_GUARD
	missiles = 4
	armor = list("overmap_light" = 90, "overmap_medium" = 50, "overmap_heavy" = 40)
	overmap_deletion_traits = DAMAGE_STARTS_COUNTDOWN //When it's been boarded, it can break
	can_resupply = TRUE //Of course the station can supply
	ai_flags = AI_FLAG_STATIONARY
	combat_dice_type = /datum/combat_dice/civilian
	area_type = /area/ruin/powered/nsv13/boarding_interior
	possible_interior_maps = list(/datum/map_template/boarding/smalloutpost)

/obj/structure/overmap/trader/syndicate/outpost/set_trader()
	return //They're for boarding, not trading


//General items:

/datum/trader_item/ship_repair
	name = "Szybka i łatwa naprawa okrętu"
	desc = "Połatamy ci okręt bez trosk i bez stresu, dzięki naszym tajnym składnikom: taśmie klejącej i modlitwie! (Copyright CzanekCorp 2258, wszelkie prawa zastrzeżone)"
	price = 1000
	stock = 5
	var/failure_chance = 20 //Chance of the repair going wrong. You get what you pay for.
	var/repair_amount = 35 //% of health this repair will heal up.

/datum/trader_item/ship_repair/tier2
	name = "Naprawa pancerza okrętu"
	desc = "Pełna naprawa płyt pancerza twojego okrętu. Naprawy konstrukcji nośnej nie są wliczone!"
	price = 2500
	failure_chance = 0
	repair_amount = 50
	stock = 2

/datum/trader_item/ship_repair/tier3
	name = "Luksusowa naprawa okrętu"
	desc = "Kompletna naprawa całego kadłuba i pancerza twojego okrętu, bo na to zasłużyłeś!"
	price = 2000
	failure_chance = 0
	repair_amount = 100
	stock = 1
	special_requirement = 400 //Prove those scars are worth the cost

/datum/trader_item/ship_repair/on_purchase(obj/structure/overmap/OM)
	OM.repair_all_quadrants(repair_amount, failure_chance)

/datum/trader_item/mining_point_card
	name = "karta punktów górniczych"
	desc = "Karta transferu punktów górniczych warta 500 w najbliższym automacie ze sprzętem."
	price = 500                                    //1:1 price because 2000 points can turn into 1000 credits.
	stock = 5
	unlock_path = /obj/item/card/mining_point_card

/datum/trader_item/titanium
	name = "Tytan"
	desc = "Niezbędny składnik pancerza każdej porządnej jednostki bojowej."
	price = 700                             //Price for minerals is roughly 6x their export value
	stock = 30
	unlock_path = /obj/item/stack/sheet/mineral/titanium

/datum/trader_item/silver
	name = "Srebro"
	desc = "Błyszczące i przystępne cenowo!"
	price = 600
	stock = 10
	unlock_path = /obj/item/stack/sheet/mineral/silver

/datum/trader_item/diamond
	name = "Diament"
	desc = "W przeciwieństwie do innych miejsc nasze nie są umazane krwią. Tylko mnóstwem potu i łez."
	price = 2000
	stock = 4
	unlock_path = /obj/item/stack/sheet/mineral/diamond

/datum/trader_item/uranium
	name = "Uran"
	desc = "Lekko radioaktywny, obchodź się z nim ostrożnie."
	price = 650
	stock = 8
	unlock_path = /obj/item/stack/sheet/mineral/uranium

/datum/trader_item/gold
	name = "Złoto"
	desc = "Wspaniale przewodzi prąd! Zapytaj Steve'a."
	price = 800
	stock = 5
	unlock_path = /obj/item/stack/sheet/mineral/gold

/datum/trader_item/bluespace_crystal
	name = "Kryształ bluespace"
	desc = "Cudowny materiał, który wywrócił nasz obraz świata. Teraz wywróci ci portfel, jeśli zechcesz go trochę."
	price = 8000
	stock = 3
	unlock_path = /obj/item/stack/ore/bluespace_crystal

/datum/trader_item/mac
	name = "Zestaw działa MAC"
	desc = "Wszystko, czego potrzebujesz, żeby zbudować wielkie działo MAC."
	price = 10000
	stock = 1
	unlock_path = /obj/structure/closet/crate/secure/weapon/trader_arms

/obj/structure/closet/crate/secure/weapon/trader_arms
	name = "zestaw konstrukcyjny działa MAC"
	var/list/preset_contents = list(
		/obj/structure/ship_weapon/mac_assembly,\
		/obj/item/ship_weapon/parts/mac_barrel,\
		/obj/item/ship_weapon/parts/firing_electronics,\
		/obj/item/ship_weapon/parts/loading_tray,\
	)

/obj/structure/closet/crate/secure/weapon/trader_arms/PopulateContents()
	. = ..()
	for(var/X in preset_contents)
		new X(src)

/datum/trader_item/railgun
	name = "Zestaw działa szynowego"
	desc = "Wszystko, czego potrzebujesz, żeby zbudować okrętowe działo szynowe."
	price = 6000
	stock = 1
	unlock_path = /obj/structure/closet/crate/secure/weapon/trader_arms/railgun

/obj/structure/closet/crate/secure/weapon/trader_arms/railgun
	name = "zestaw konstrukcyjny działa szynowego"
	preset_contents = list(
		/obj/structure/ship_weapon/railgun_assembly,\
		/obj/item/ship_weapon/parts/railgun_rail,\
		/obj/item/ship_weapon/parts/firing_electronics,\
		/obj/item/ship_weapon/parts/loading_tray,\
	)

/datum/trader_item/vls_circuit
	name = "Płytka drukowana wyrzutni VLS"
	desc = "Kluczowy element, jeśli chcesz powiększyć zapas rakiet!"
	price = 5000
	stock = 10
	unlock_path = /obj/item/circuitboard/machine/vls
	special_requirement = 100 //At least put some effort into it

/datum/trader_item/firing_electronics
	name = "Elektronika spustowa"
	desc = "Elektronika niezbędna do budowy większości nowoczesnych broni okrętowych."
	price = 20000
	stock = 2
	unlock_path = /obj/item/ship_weapon/parts/firing_electronics
	special_requirement = 500 //Kick their ass!!!

/datum/trader_item/pdc_circuit
	name = "Płytka drukowana stanowiska PDC"
	desc = "Za mało obrony punktowej? Po prostu zbuduj więcej!"
	price = 2500
	stock = 4
	unlock_path = /obj/item/circuitboard/machine/pdc_mount

/datum/trader_item/torpedo
	name = "Standardowa torpeda"
	desc = "Standardowa torpeda do walki między okrętami."
	price = 900 //Price is 1000 per in cargo
	stock = 15
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo

/datum/trader_item/missile
	name = "Standardowa rakieta"
	desc = "Standardowa rakieta do walki między okrętami."
	price = 500 //Price in cargo is 833 per, this is a real steal
	stock = 20
	unlock_path = /obj/item/ship_weapon/ammunition/missile

/datum/trader_item/hellfire
	name = "Plazmowa torpeda zapalająca"
	desc = "Alfa i omega, dostarczona szybko i sprawnie! (UWAGA: OBCHODZIĆ SIĘ OSTROŻNIE)."
	price = 2500
	stock = 4
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo/hellfire

/datum/trader_item/c20r
	name = "Pistolet maszynowy C20R od Donk Co."
	desc = "Bardzo potężna i wszechstronna broń używana przez komandosów Syndykatu."
	price = 10000
	stock = 3
	unlock_path = /obj/item/gun/ballistic/automatic/c20r/unrestricted

/datum/trader_item/stechkin
	name = "Pistolet Stieczkin"
	desc = "Niezawodna, zabójcza broń boczna Syndykatu. Lepsza niż cokolwiek, co da ci NT."
	price = 5500
	stock = 5
	unlock_path = /obj/item/gun/ballistic/automatic/pistol

/datum/trader_item/c45
	name = "Pudełko amunicji .45 ACP"
	desc = "Naboje .45 ACP do broni palnej."
	price = 1500
	stock = 5
	unlock_path = /obj/item/ammo_box/c45

/datum/trader_item/pdc
	name = "Skrzynka amunicji PDC"
	desc = "Pociski PDC do okrętowych dział."
	price = 175 //cost of buying in cargo is 200 per box
	stock = 20
	unlock_path = /obj/item/ammo_box/magazine/nsv/pdc

/datum/trader_item/anti_air
	name = "Skrzynka amunicji przeciwlotniczej"
	desc = "Pociski przeciwlotnicze do okrętowych dział."
	price = 800
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/nsv/pdc

/datum/trader_item/flak
	name = "Skrzynka amunicji flak"
	desc = "Pociski flak do okrętowych dział."
	price = 500
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/nsv/flak

/datum/trader_item/fighter/light
	name = "Lekki myśliwiec"
	desc = "Zmontowany lekki myśliwiec, wyposażony we wszystko, czego pilot potrzebuje, żeby wrócić do walki."
	price = 11000
	stock = 2
	unlock_path = /obj/structure/overmap/small_craft/combat/light

/datum/trader_item/fighter/utility
	name = "Jednostka pomocnicza"
	desc = "Zmontowana jednostka pomocnicza, która uzupełnia zapasy innych myśliwców i je naprawia."
	price = 9000
	stock = 5
	unlock_path = /obj/structure/overmap/small_craft/transport/sabre

/datum/trader_item/fighter/heavy
	name = "Ciężki myśliwiec"
	desc = "Zmontowany ciężki myśliwiec klasy Scimitar, wyprodukowany na miejscu przez naszych inżynierów."
	price = 15000
	stock = 2
	unlock_path = /obj/structure/overmap/small_craft/combat/heavy

//Trader exclusive specialty fighters
/obj/structure/overmap/small_craft/combat/light/judgement
	name = "myśliwiec dyrektorski"
	icon_state = "judgement"
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier2,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine/tier2,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy/tier2,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery/tier2,
						/obj/item/fighter_component/primary/cannon)

/datum/trader_item/fighter/judgement
	name = "Myśliwiec na zamówienie AX-49 „Classic”"
	desc = "Lekki myśliwiec zbudowany na zamówienie i dopracowany do perfekcji. Tę piękność napędzają dbałość o szczegóły i duma."
	price = 20000
	stock = 1
	unlock_path = /obj/structure/overmap/small_craft/combat/light/judgement

/datum/trader_item/fighter/prototype
	name = "Myśliwiec przewagi powietrznej SU-148 Czelabińsk"
	desc = "Wysoce eksperymentalny prototyp myśliwca z działem szynowym. Ta prawdziwa potęga łączy prędkość, siłę ognia i skrytość w pakiecie, który z gwarancją przewyższa wszystko, co może na ciebie rzucić Syndykat. Schematy amunicji sprzedawane osobno!"
	price = 50000
	stock = 1
	unlock_path = /obj/structure/overmap/small_craft/combat/light/prototype

/obj/structure/overmap/small_craft/combat/light/prototype
	name = "myśliwiec przewagi powietrznej SU-148 Czelabińsk"
	icon_state = "prototype"
	components = list(/obj/item/fighter_component/fuel_tank/tier3,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating/tier3,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine/tier3,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher/railgun,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy/tier2,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery/tier2,
						/obj/item/fighter_component/primary/cannon/heavy)

/datum/trader_item/railgun_disk
	name = "Przestarzały dysk z projektami pocisków szynowych"
	desc = "Dysk ze schematami pocisków szynowych."
	price = 5000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/hybrid_rail_slugs

/datum/trader_item/fighter/syndicate
	name = "Lekki myśliwiec Syndykatu AV-41 „Corvid”"
	desc = "Nieco przestarzała konstrukcja myśliwca Syndykatu, która być może jest kopią wycofanej już serii „Viper” od Nanotrasen."
	price = 7000
	stock = 5
	unlock_path = /obj/structure/overmap/small_craft/combat/light/syndicate //Good luck using these without boarder IDs

/datum/trader_item/taser
	name = "Paralizator CzanekCorp (zgłoszony do opatentowania)"
	desc = "Tani, ale bardzo niezawodny (i nieco zabójczy) paralizator używany przez ochronę NT."
	price = 1000
	stock = 5
	unlock_path = /obj/item/gun/ballistic/tazer

/datum/trader_item/taser_ammo
	name = "Amunicja do paralizatora CzanekCorp (zgłoszona do opatentowania)"
	desc = "Amunicja do paralizatora CC."
	price = 100
	stock = 5
	unlock_path = /obj/item/ammo_box/magazine/tazer_cartridge

/datum/trader_item/overmap_shields
	name = "Dysk eksperymentalnej technologii tarcz SolGov"
	desc = "Ukradziony im sprzed nosa! Szkoda, że nie umiemy go odczytać."
	price = 100000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/overmap_shields

/datum/trader_item/deck_gun_autoelevator
	name = "Dysk eksperymentalnej technologii autopodnośnika działa artylerii okrętowej"
	desc = "Ulepszenie działa artylerii okrętowej, które drastycznie skraca czas ładowania."
	price = 10000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/deck_gun_autoelevator

/datum/trader_item/deck_gun_autorepair
	name = "Dysk eksperymentalnej technologii autonaprawy działa artylerii okrętowej"
	desc = "Ulepszenie działa artylerii okrętowej, które pozwala mu naprawiać się samemu."
	price = 8000
	stock = 1
	unlock_path = /obj/item/disk/design_disk/deck_gun_autorepair

/datum/trader_item/yellow_pages
	name = "Kosmiczne Żółte Strony"
	desc = "Książka pełna przydatnych informacji o pobliskich stacjach kosmicznych"
	price = 1000
	stock = 1
	unlock_path = /obj/item/book/space_yellow_pages

/datum/trader_item/yellow_pages/on_purchase(obj/structure/overmap/OM)
	. = ..()
	var/obj/item/book/space_yellow_pages/book = .
	book.set_basic_info(owner)
