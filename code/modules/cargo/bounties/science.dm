/datum/bounty/item/science/boh
	name = "Torba bez dna"
	description = "Nanotrasen dobrze wykorzystałby plecaki o dużej pojemności. Jeśli jakieś macie, wyślijcie je."
	reward = 10000
	wanted_types = list(/obj/item/storage/backpack/holding)

/datum/bounty/item/science/tboh
	name = "Worek na śmieci bez dna"
	description = "Nanotrasen dobrze wykorzystałby worki na śmieci o dużej pojemności. Jeśli jakieś macie, wyślijcie je."
	reward = 10000
	wanted_types = list(/obj/item/storage/bag/trash/bluespace)

/datum/bounty/item/science/bluespace_syringe
	name = "Strzykawka bluespace"
	description = "Nanotrasen dobrze wykorzystałby strzykawki o dużej pojemności. Jeśli jakieś macie, wyślijcie je."
	reward = 10000
	wanted_types = list(/obj/item/reagent_containers/syringe/bluespace)

/datum/bounty/item/science/bluespace_body_bag
	name = "Worek na zwłoki bluespace"
	description = "Nanotrasen dobrze wykorzystałby worki na zwłoki o dużej pojemności. Jeśli jakieś macie, wyślijcie je."
	reward = 10000
	wanted_types = list(/obj/item/bodybag/bluespace)

/datum/bounty/item/science/nightvision_goggles
	name = "Gogle noktowizyjne"
	description = "Burza elektryczna zniszczyła wszystkie światła w Centrali. Czy w czasie, gdy kierownictwo czeka na zamienniki, można by wysłać gogle noktowizyjne?"
	reward = 10000
	wanted_types = list(/obj/item/clothing/glasses/night, /obj/item/clothing/glasses/meson/night, /obj/item/clothing/glasses/hud/health/night, /obj/item/clothing/glasses/hud/security/night, /obj/item/clothing/glasses/hud/diagnostic/night)

/datum/bounty/item/science/experimental_welding_tool
	name = "Eksperymentalna spawarka"
	description = "Niedawny wypadek sprawił, że większość spawarek w Centrali wybuchła. Wyślijcie zamienniki, by otrzymać nagrodę."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/weldingtool/experimental)

/datum/bounty/item/science/cryostasis_beaker
	name = "Zlewka kriostatyczna"
	description = "Chemicy w Centrali odkryli nową substancję, którą można przechowywać tylko w zlewkach kriostazy. Jedyny problem: nie mają żadnych! Zaradźcie temu, by otrzymać zapłatę."
	reward = 10000
	wanted_types = list(/obj/item/reagent_containers/glass/beaker/noreact)

/datum/bounty/item/science/diamond_drill
	name = "Diamentowe wiertło górnicze"
	description = "Centrala jest gotowa zapłacić trzymiesięczną pensję za jedno diamentowe wiertło górnicze."
	reward = 15000
	wanted_types = list(/obj/item/pickaxe/drill/diamonddrill, /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill)

/datum/bounty/item/science/floor_buffer
	name = "Ulepszenie polerki do podłóg"
	description = "Jeden z woźnych Centrali zbił małą fortunę na zakładach wyścigów karpi. Teraz chciałby zamówić ulepszenie swojej polerki do podłóg."
	reward = 10000
	wanted_types = list(/obj/item/janiupgrade)

/datum/bounty/item/science/advanced_mop
	name = "Zaawansowany mop"
	description = "Przepraszam. Chciałbym poprosić o 17 dolarów na nowe włosie do szczotki. Albo o zaawansowany mop."
	reward = 10000
	wanted_types = list(/obj/item/mop/advanced)

/datum/bounty/item/science/advanced_egun
	name = "Zaawansowana broń energetyczna"
	description = "Ceny ładowarek rosną, więc wyższe kierownictwo chce kupić broń z własnym zasilaniem. Jeśli ją wyślecie, zapłacą."
	reward = 10000
	wanted_types = list(/obj/item/gun/energy/e_gun/nuclear)
