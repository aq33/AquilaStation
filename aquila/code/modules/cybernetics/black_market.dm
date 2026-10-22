// Port cybernetyki z Monkestation: używane implanty („shoddy”) na czarnym rynku.
// Monke sprzedaje je na aukcjach; u nas nie ma aukcji, więc to zwykłe pozycje czarnego rynku z małym zapasem.

/datum/market_item/shoddy_implant
	category = BLACKMARKET_CATEGORY_IMPLANTS
	abstract_path = /datum/market_item/shoddy_implant
	stock_max = 1
	availability_prob = 50

/datum/market_item/shoddy_implant/knockout
	name = "Implant nokautujący"
	desc = "Jakiś szalony klaun zrobił to, żeby naprawdę porządnie zrobić załodze kawał."
	item = /obj/item/organ/cyberimp/chest/spinal/knockout
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	availability_prob = 70

/datum/market_item/shoddy_implant/rage
	name = "System chemiczny R.A.G.E."
	desc = "Skrajnie niebezpieczny system, który zalewa nosiciela mieszanką silnych narkotyków."
	item = /obj/item/organ/cyberimp/chest/spinal/chemvat
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 7
	availability_prob = 20

/datum/market_item/shoddy_implant/dualwield
	name = "Odnowiony implant C.C.M.S."
	desc = "Odnowiony implant do walki dwiema rękami. Stary i czasem nie odpala, ale nadal działa."
	item = /obj/item/organ/cyberimp/chest/spinal/dualwield/refurbished
	price_min = MARKET_CRATE_VALUE * 6
	price_max = MARKET_CRATE_VALUE * 8
	availability_prob = 10

/datum/market_item/shoddy_implant/heater
	name = "Podskórny implant grzewczy"
	desc = "Implant w dłoni, który ogrzewa cię, gdy marzniesz."
	item = /obj/item/organ/cyberimp/arm/cooler/heater
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3

/datum/market_item/shoddy_implant/cooler
	name = "Podskórny implant chłodzący"
	desc = "Implant w dłoni, który schładza cię, gdy się przegrzewasz."
	item = /obj/item/organ/cyberimp/arm/cooler
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3

/datum/market_item/shoddy_implant/strongarm
	name = "Implant wzmocnienia mięśni Strong-Arm"
	desc = "Wzmacnia mięśnie ręki, by każdy ruch miał więcej siły. Śrubokrętem przestawisz go na drugą rękę."
	item = /obj/item/organ/cyberimp/arm/strongarm
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 6
	stock_max = 2
	availability_prob = 30

/datum/market_item/shoddy_implant/razorwire
	name = "Implant ze szpulą drutu tnącego"
	desc = "Wbudowana szpula drutu tnącego, którym smaga się przeciwników jak biczem."
	item = /obj/item/organ/cyberimp/arm/razorwire
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 9
	availability_prob = 10

/datum/market_item/shoddy_implant/table_glider
	name = "Implant ślizgu po stołach"
	desc = "Błyskawicznie przeskakujesz przez stoły. Trzeba go wszczepić w obie nogi, śrubokrętem przestawisz stronę."
	item = /obj/item/organ/cyberimp/leg/trait/table_glider
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	stock_max = 2

/datum/market_item/shoddy_implant/shove_resist
	name = "Implant oporowy BU-TAM"
	desc = "Popchnięcia cię nie przewracają, tylko męczą. Trzeba go wszczepić w obie nogi."
	item = /obj/item/organ/cyberimp/leg/trait/shove_resist
	price_min = MARKET_CRATE_VALUE * 3
	price_max = MARKET_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 40

/datum/market_item/shoddy_implant/sprinter
	name = "System wiązadeł wakuolowych"
	desc = "Serwa w nogach wydłużają krok, popularne wśród miłośników parkouru. Trzeba go wszczepić w obie nogi."
	item = /obj/item/organ/cyberimp/leg/trait/sprinter
	price_min = MARKET_CRATE_VALUE * 3
	price_max = MARKET_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 30

/datum/market_item/shoddy_implant/accelerator
	name = "System przyspieszenia P.R.Y.Z.H.O.K."
	desc = "Rosyjski implant do powalania ludzi szarżą. Trzeba go wszczepić w obie nogi."
	item = /obj/item/organ/cyberimp/leg/accelerator
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 7
	stock_max = 2
	availability_prob = 20

/datum/market_item/shoddy_implant/drugs
	name = "Głębokożylny awaryjny wzmacniacz morale"
	desc = "Niebezpieczny implant nogi, którym Syndykat wzmacnia oddziały szturmowe wysyłane na misje samobójcze."
	item = /obj/item/organ/cyberimp/leg/chemplant/drugs
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 7
	availability_prob = 40

/datum/market_item/shoddy_implant/emergency
	name = "Głęboki awaryjny dozownik chemikaliów"
	desc = "Implant nogi, który przy ciężkich obrażeniach wstrzykuje mieszankę leków."
	item = /obj/item/organ/cyberimp/leg/chemplant/emergency
	price_min = MARKET_CRATE_VALUE * 5
	price_max = MARKET_CRATE_VALUE * 7
	availability_prob = 20

// Ostrza A.R.A.S.A.K.A. w uplinku (premade_storages/antags.dm z Monke)

/obj/item/storage/briefcase/syndie_mantis
	desc = "Całkowicie metalowa teczka. Na boku wygrawerowano A.R.A.S.A.K.A. czcionką Futura."

/obj/item/storage/briefcase/syndie_mantis/PopulateContents()
	..()
	new /obj/item/autosurgeon/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/syndicate/syndie_mantis/l(src)

/obj/item/autosurgeon/syndicate/syndie_mantis
	name = "podejrzany autochirurg (ostrze A.R.A.S.A.K.A., prawa ręka)"
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/syndie_mantis)

/obj/item/autosurgeon/syndicate/syndie_mantis/l
	name = "podejrzany autochirurg (ostrze A.R.A.S.A.K.A., lewa ręka)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/syndie_mantis/l)

/datum/uplink_item/implants/syndie_mantis
	name = "Ostrza modliszki A.R.A.S.A.K.A."
	desc = "Teczka z dwoma autochirurgami: ostrze modliszki do prawej i do lewej ręki. Z dwoma ostrzami tniesz oboma naraz \
		i doskakujesz do celu oddalonego o 3 kratki."
	item = /obj/item/storage/briefcase/syndie_mantis
	cost = 14
	surplus = 10
