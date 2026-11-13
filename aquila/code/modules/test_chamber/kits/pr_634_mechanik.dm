/datum/test_chamber_kit/pr_634
	name = "Mechanik: skaner, czytnik schematów, flatpacker"
	pr = "aq33/AquilaStation#634"
	description = "Rozłóż multitoolem paczki z flatpackerem i czytnikiem schematów (połóż je na podłodze, maszyna staje przodem tam, gdzie patrzysz). \
		Zeskanuj skanerem kilka maszyn z komory i stacji, potem kliknij skanerem czytnik: skany idą do kolejki, a po odczycie są w bazie. \
		We flatpackerze wybierz schemat z bazy albo włóż płytkę, wrzuć arkusze i zapakuj. Schemat ulepszonej maszyny wymaga manipulatora tego tieru we flatpackerze: RPED-em włóż jeden nanomanipulator do skanowanej maszyny, a drugi do flatpackera. \
		Pakownicą złóż maszynę z otwartym włazem (śrubokręt) i rozłóż ją gdzie indziej: części mają zostać te same. \
		Zwykły skaner i pakownica nie biorą konsoli kamer ochrony; czerwone wersje z uplinku biorą, a flatpacker robi z niej paczkę dopiero po emagu. \
		Wózek mieści trzy paczki (kliknij paczką, pustą ręką zdejmujesz górną)."
	items = list(
		/obj/item/flatpack/flatpacker = 1,
		/obj/item/flatpack/schematic_reader = 1,
		/obj/structure/flatpack_cart = 1,
		/obj/item/machine_scanner = 1,
		/obj/item/machine_scanner/syndicate = 1,
		/obj/item/machine_packer = 1,
		/obj/item/machine_packer/syndicate = 1,
		/obj/item/multitool = 1,
		/obj/item/screwdriver = 1,
		/obj/item/card/emag = 1,
		/obj/item/stack/sheet/iron/fifty = 2,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/mineral/silver = 10,
		/obj/item/stock_parts/manipulator/nano = 2,
		/obj/item/storage/part_replacer = 1,
		/obj/machinery/computer/security = 1,
		/obj/machinery/modular_fabricator/autolathe = 1,
	)
