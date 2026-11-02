// Shotgun

/obj/item/ammo_casing/shotgun
	name = "breneka"
	desc = "Ołowiana breneka kalibru 12."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet/shotgun_slug
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/beanbag
	name = "nabój z woreczkiem"
	desc = "Słaby nabój z woreczkiem do tłumienia zamieszek."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_beanbag
	materials = list(/datum/material/iron=250)

/obj/item/ammo_casing/shotgun/incendiary
	name = "breneka zapalająca"
	desc = "Breneka do strzelby pokryta mieszanką zapalającą."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "nabój smoczy oddech"
	desc = "Nabój do strzelby, który wystrzeliwuje rozrzut zapalających śrucin."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/stunslug
	name = "breneka paraliżująca"
	desc = "Ogłuszająca breneka paralizatora."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_stunslug
	materials = list(/datum/material/iron=250)

/obj/item/ammo_casing/shotgun/meteorslug
	name = "nabój meteorytowy"
	desc = "Nabój do strzelby z technologią CMC, który po wystrzale wyrzuca masywną brenekę."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_meteorslug

/obj/item/ammo_casing/shotgun/pulseslug
	name = "breneka pulsacyjna"
	desc = "Delikatne urządzenie, które ładuje się do strzelby. Spłonka działa jak przycisk, który pobudza ośrodek czynny i wystrzeliwuje potężny \
	impuls energii. Ciepło i pobór energii ograniczają ją do jednego użycia, ale pozwala zwalczać cele, z którymi amunicja balistyczna \
	miałaby kłopot."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shotgun

/obj/item/ammo_casing/shotgun/frag12
	name = "breneka FRAG-12"
	desc = "Burzący nabój wyważający do strzelby kalibru 12."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_frag12

/obj/item/ammo_casing/shotgun/buckshot
	name = "nabój śrutowy"
	desc = "Nabój śrutowy kalibru 12."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 10

/obj/item/ammo_casing/shotgun/rubbershot
	name = "nabój z gumowym śrutem"
	desc = "Łuska do strzelby wypełniona ciasno upakowanymi gumowymi kulkami. Służy do obezwładniania tłumu z dystansu."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 20
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/incapacitate
	name = "niestandardowy nabój obezwładniający"
	desc = "Łuska do strzelby wypełniona... czymś. Służy do obezwładniania celów."
	icon_state = "bountyshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_incapacitate
	pellets = 12//double the pellets, but half the stun power of each, which makes this best for just dumping right in someone's face.
	variance = 20
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/improvised
	name = "improwizowany nabój"
	desc = "Wyjątkowo słaby nabój do strzelby z wieloma drobnymi śrucinami z metalowych odłamków."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_improvised
	materials = list(/datum/material/iron=250)
	pellets = 10
	variance = 25

/obj/item/ammo_casing/shotgun/ion
	name = "nabój jonowy"
	desc = "Zaawansowany nabój do strzelby, który kryształem ansibla podprzestrzennego wywołuje efekt podobny do zwykłego karabinu jonowego. \
	Wyjątkowe właściwości kryształu rozbijają impuls na rozrzut pojedynczo słabszych pocisków."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/laserslug
	name = "nabój z laserem rozpraszającym"
	desc = "Zaawansowany nabój do strzelby, który za pomocą mikrolasera odtwarza działanie broni z laserem rozpraszającym w formie balistycznej."
	icon_state = "lshell"
	projectile_type = /obj/item/projectile/beam/weak
	pellets = 6
	variance = 35

/obj/item/ammo_casing/shotgun/techshell
	name = "pusty nabój technologiczny"
	desc = "Zaawansowany technicznie nabój do strzelby. Po załadowaniu materiałami daje wyjątkowe efekty."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/dart
	name = "strzałka do strzelby"
	desc = "Strzałka do strzelby. Mieści do 30 j. dowolnej substancji."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/dart
	var/reagent_amount = 30

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/noreact
	name = "kriostatyczna strzałka do strzelby"
	desc = "Strzałka do strzelby, która dzięki technologii podobnej jak w zlewkach kriostatycznych nie pozwala zawartości reagować. Mieści do 10 j. dowolnej substancji."
	icon_state = "cnrshell"
	reagent_amount = 10

/obj/item/ammo_casing/shotgun/dart/noreact/Initialize(mapload)
	. = ..()
	ENABLE_BITFIELD(reagents.flags, NO_REACT)

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "Strzałka do strzelby wypełniona zabójczymi toksynami."

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)

/obj/item/ammo_casing/shotgun/breacher
	name = "breneka wyważająca"
	desc = "Breneka kalibru 12 przeciw materiałom. Świetnie wyważa śluzy i okna niewielką liczbą strzałów."
	icon_state = "breacher"
	projectile_type = /obj/item/projectile/bullet/shotgun_breaching
	materials = list(/datum/material/iron=4000)
