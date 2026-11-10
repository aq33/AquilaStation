// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Drużyna o danej nazwie z GLOB.squad_manager
/datum/unit_test/proc/aq_squad(name)
	return GLOB.squad_manager.get_squad(name)

/// Nazwy Alpha-Delta, stare nazwy z zapisanych postaci i kanały pagera
/datum/unit_test/aquila_squad_names

/datum/unit_test/aquila_squad_names/Run()
	for(var/name in list("Alpha", "Bravo", "Charlie", "Delta"))
		var/datum/squad/squad = aq_squad(name)
		TEST_ASSERT(squad, "Brak drużyny [name]")
		TEST_ASSERT(squad.squad_channel, "Drużyna [name] nie ma kanału pagera (typ /datum/component/simple_teamchat/radio_dependent/squad/[name])")
	TEST_ASSERT(aq_squad("Able") == aq_squad("Alpha"), "Stara nazwa Able z zapisu postaci nie prowadzi do drużyny Alpha")
	TEST_ASSERT(aq_squad("Duff") == aq_squad("Delta"), "Stara nazwa Duff z zapisu postaci nie prowadzi do drużyny Delta")

/// Auto-przydział według zawodu: medyk do drużyny medycznej, inżynier do kontroli uszkodzeń, dowództwo nigdzie
/datum/unit_test/aquila_squad_auto_assign

/datum/unit_test/aquila_squad_auto_assign/Run()
	var/datum/job/medic_job = SSjob.GetJobType(/datum/job/medical_doctor)
	var/datum/squad/medic_squad = GLOB.squad_manager.aq_pick_squad(medic_job, null)
	TEST_ASSERT(medic_squad?.role == MEDICAL_SQUAD, "Lekarz trafił do drużyny o roli [medic_squad?.role] zamiast medycznej")
	var/datum/job/engineer_job = SSjob.GetJobType(/datum/job/station_engineer)
	var/datum/squad/engineer_squad = GLOB.squad_manager.aq_pick_squad(engineer_job, null)
	TEST_ASSERT(engineer_squad?.role == DC_SQUAD, "Inżynier trafił do drużyny o roli [engineer_squad?.role] zamiast kontroli uszkodzeń")
	var/datum/job/captain_job = SSjob.GetJobType(/datum/job/captain)
	TEST_ASSERT(!captain_job.aq_squad_auto, "Kapitan trafia do drużyny automatycznie")
	var/datum/job/assistant_job = SSjob.GetJobType(/datum/job/assistant)
	var/datum/squad/preferred = GLOB.squad_manager.aq_pick_squad(assistant_job, "Delta")
	TEST_ASSERT(preferred == aq_squad("Delta"), "Asystent z preferowaną drużyną Delta trafił do [preferred]")

	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	doctor.equip_to_slot_or_del(new /obj/item/storage/backpack(doctor), ITEM_SLOT_BACK)
	medic_job.register_squad(doctor)
	TEST_ASSERT(doctor.squad?.role == MEDICAL_SQUAD, "register_squad() nie dał lekarza do drużyny medycznej")
	TEST_ASSERT(doctor.squad_position == SQUAD_POSITION_MEDIC, "Lekarz w drużynie ma funkcję [doctor.squad_position] zamiast medyka")
	var/obj/item/squad_pager/pager = locate() in doctor.GetAllContents()
	TEST_ASSERT(!pager || pager.squad == doctor.squad, "Pager lekarza jest dostrojony do innej drużyny")

/// Automat wydaje zestaw funkcji w skrzyni, a zwrot skrzyni zamyka wypożyczenie
/datum/unit_test/aquila_squad_vendor_crate

/datum/unit_test/aquila_squad_vendor_crate/Run()
	var/datum/squad/squad = aq_squad("Bravo")
	var/old_clearance = squad.weapons_clearance
	squad.weapons_clearance = FALSE
	var/obj/machinery/squad_vendor/vendor = allocate(/obj/machinery/squad_vendor)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.squad_position = SQUAD_POSITION_MEDIC
	squad.add_member(medic)
	if(squad.leader == medic)
		squad.unset_leader(medic)

	var/datum/squad_loadout/aquila/kit = vendor.aq_loadout_for(medic)
	TEST_ASSERT(kit?.position == SQUAD_POSITION_MEDIC, "Medyk dostał zestaw [kit?.name] zamiast medyka")
	TEST_ASSERT(vendor.aq_vend(medic), "Automat nie wydał zestawu")
	var/obj/item/storage/aq_squad_crate/crate = locate() in medic.held_items
	TEST_ASSERT(crate, "Zestaw nie trafił do ręki w skrzyni")
	TEST_ASSERT(crate.icon_state == "eq-box-closed", "Pełna skrzynia nie jest zamknięta (stan [crate.icon_state])")
	TEST_ASSERT(locate(/obj/item/storage/firstaid/regular) in crate, "W skrzyni medyka nie ma apteczki")
	TEST_ASSERT(locate(/obj/item/clothing/suit/ship/squad/space) in crate, "W skrzyni nie ma skafandra obcisłego (trudne warunki miały być w każdym zestawie)")
	TEST_ASSERT(!(locate(/obj/item/gun) in crate), "Drużyna bez zezwolenia na broń dostała broń")
	var/datum/squad_loan/loan = get_squad_loan(medic)
	TEST_ASSERT(loan && length(loan.outstanding) == length(crate.contents), "Rejestr wydań nie zgadza się z zawartością skrzyni")
	TEST_ASSERT(!vendor.aq_vend(medic), "Automat wydał drugi zestaw przed zwrotem pierwszego")

	// Jedną rzecz wyjmujemy i oddajemy luzem, resztę w skrzyni
	var/obj/item/clothing/suit/ship/squad/armor = locate(/obj/item/clothing/suit/ship/squad) in crate
	armor.forceMove(get_turf(medic))
	TEST_ASSERT(crate.icon_state == "eq-box-open", "Skrzynia bez pancerza nie otworzyła się (stan [crate.icon_state])")
	vendor.return_item(medic, crate, quiet = TRUE)
	TEST_ASSERT(QDELETED(crate), "Pusta skrzynia nie została przyjęta")
	TEST_ASSERT(!QDELETED(loan) && length(loan.outstanding) == 1, "Po zwrocie skrzyni bez pancerza powinna brakować jedna rzecz, brakuje [QDELETED(loan) ? 0 : length(loan.outstanding)]")
	TEST_ASSERT(vendor.return_item(medic, armor, quiet = TRUE), "Automat nie przyjął pancerza luzem")
	TEST_ASSERT(QDELETED(loan) && !get_squad_loan(medic), "Wypożyczenie nie zamknęło się po oddaniu wszystkiego")
	squad.weapons_clearance = old_clearance

/// Śmierć dowódcy: dowodzenie przejmuje żywy członek drużyny
/datum/unit_test/aquila_squad_leader_succession

/datum/unit_test/aquila_squad_leader_succession/Run()
	var/datum/squad/squad = aq_squad("Charlie")
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	squad.add_member(first)
	squad.add_member(second)
	squad.set_leader(first)
	TEST_ASSERT(squad.leader == first, "Nie udało się ustawić dowódcy")
	first.death()
	TEST_ASSERT(squad.aq_leader_succession(first), "Po śmierci dowódcy nikt nie przejął dowodzenia")
	TEST_ASSERT(squad.leader == second, "Dowodzenie przejął [squad.leader] zamiast żywego członka drużyny")

/// Znaczniki rozkazów: jeden na typ, nowy zastępuje stary, można usunąć
/datum/unit_test/aquila_squad_markers

/datum/unit_test/aquila_squad_markers/Run()
	var/datum/squad/squad = aq_squad("Delta")
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human)
	squad.add_member(leader)
	squad.set_leader(leader)
	var/datum/aq_squad_marker/first = squad.aq_place_marker(leader, run_loc_floor_bottom_left, SQUAD_MARKER_ATTACK)
	TEST_ASSERT(first && squad.aq_markers[SQUAD_MARKER_ATTACK] == first, "Znacznik ataku nie został postawiony")
	TEST_ASSERT(!squad.aq_place_marker(leader, run_loc_floor_top_right, SQUAD_MARKER_ATTACK), "Drugi znacznik od razu po pierwszym ominął odstęp")
	leader.aq_next_squad_marker = 0
	var/datum/aq_squad_marker/second = squad.aq_place_marker(leader, run_loc_floor_top_right, SQUAD_MARKER_ATTACK)
	TEST_ASSERT(QDELETED(first) && squad.aq_markers[SQUAD_MARKER_ATTACK] == second, "Nowy znacznik ataku nie zastąpił starego")
	var/list/markers_data = squad.aq_markers_data()
	TEST_ASSERT(length(markers_data) == 1 && markers_data[1]["x"] == run_loc_floor_top_right.x, "Dane znaczników dla mapy są złe")
	TEST_ASSERT(squad.aq_clear_marker(SQUAD_MARKER_ATTACK) && !length(squad.aq_markers), "Znacznik nie dał się usunąć")
	leader.aq_next_squad_marker = 0
	TEST_ASSERT(!squad.aq_place_marker(leader, run_loc_floor_top_right, "nieistniejacy"), "Przyjęto nieznany typ znacznika")

/// Regresja: guziki konsoli (dostęp, broń, przydział) nic nie zmieniały, bo stary ui_act z NSV13 obsługiwał
/// akcję o tej samej nazwie przed naszą i przełącznik zmieniał się dwa razy
/datum/unit_test/aquila_squad_console_toggles

/datum/unit_test/aquila_squad_console_toggles/Run()
	var/datum/squad/squad = aq_squad("Charlie")
	var/obj/machinery/computer/squad_manager/console = allocate(/obj/machinery/computer/squad_manager)
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	usr = officer
	var/list/params = list("squad_id" = REF(squad))
	var/old_access = squad.access_enabled
	var/old_weapons = squad.weapons_clearance
	var/old_hidden = squad.hidden
	// bez dostępu dowództwa konsola niczego nie zmienia (req_one_access nie działał sam w ui_act)
	console.ui_act("aq_toggle_access", params)
	TEST_ASSERT(squad.access_enabled == old_access, "Konsola XO zmieniła dostęp drużyny osobie bez dostępu dowództwa")
	console.req_one_access = null
	console.req_access = null
	console.ui_act("aq_toggle_access", params)
	console.ui_act("aq_toggle_beararms", params)
	console.ui_act("aq_toggle_hidden", params)
	TEST_ASSERT(squad.access_enabled != old_access, "Guzik dostępu w konsoli nie zmienił dostępu drużyny")
	TEST_ASSERT(squad.weapons_clearance != old_weapons, "Guzik broni w konsoli nie zmienił zezwolenia na broń")
	TEST_ASSERT(squad.hidden != old_hidden, "Guzik przydziału w konsoli nie zmienił przydziału")
	squad.access_enabled = old_access
	squad.weapons_clearance = old_weapons
	squad.hidden = old_hidden
	for(var/obj/item/clothing/neck/squad/old_pass in console.loc)
		qdel(old_pass)
	console.ui_act("aq_print_pass", params)
	var/passes = 0
	for(var/obj/item/clothing/neck/squad/pass in console.loc)
		passes++
		qdel(pass)
	TEST_ASSERT(passes == 1, "Guzik Smycz wydrukował [passes] smyczy zamiast jednej")

/// Wskaźnik znacznika przy krawędzi ekranu: przyklejony do krawędzi w stronę celu, z odległością; pokłady liczone po stosie pięter
/datum/unit_test/aquila_squad_marker_pointer

/datum/unit_test/aquila_squad_marker_pointer/Run()
	var/atom/movable/screen/aq_marker_pointer/pointer = allocate(/atom/movable/screen/aq_marker_pointer, null, SQUAD_MARKER_ATTACK, "#ff0000")
	// cel 40 kratek na wschód przy widoku 15x15: wskaźnik przy prawej krawędzi (5,8 kratki), na wysokości środka
	pointer.aim_at(40, 0, 7, 7)
	TEST_ASSERT(pointer.screen_loc == "CENTER:[round(5.8 * world.icon_size)],CENTER:0", "Wskaźnik nie stoi przy prawej krawędzi ekranu: [pointer.screen_loc]")
	TEST_ASSERT(findtext(pointer.maptext, "40"), "Wskaźnik nie pokazuje odległości do znacznika")
	// cel na skos: przycięty do bliższej krawędzi (tu górnej), proporcje kierunku zachowane
	pointer.aim_at(10, 20, 7, 7)
	TEST_ASSERT(pointer.screen_loc == "CENTER:[round(10 * 5.8 / 20 * world.icon_size)],CENTER:[round(5.8 * world.icon_size)]", "Wskaźnik na skos nie trzyma kierunku do celu: [pointer.screen_loc]")
	TEST_ASSERT(aq_deck_offset(run_loc_floor_bottom_left.z, run_loc_floor_bottom_left.z) == 0, "Ten sam poziom nie daje różnicy pokładów 0")
	TEST_ASSERT(isnull(aq_deck_offset(run_loc_floor_bottom_left.z, world.maxz + 1)), "Poziom spoza stosu pięter liczy się jako pokład okrętu")

/// Pager schowany w PDA: dalej odbiera łączność noszącego, PDA daje przycisk pagera, Alt-klik go wyjmuje
/datum/unit_test/aquila_squad_pager_in_pda

/datum/unit_test/aquila_squad_pager_in_pda/Run()
	var/datum/squad/squad = aq_squad("Bravo")
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human)
	squad.add_member(member)
	var/obj/item/modular_computer/tablet/pda/pda = allocate(/obj/item/modular_computer/tablet/pda)
	var/obj/item/squad_pager/pager = allocate(/obj/item/squad_pager, null, squad)
	pager.attack_self(member) // tworzy kanał drużyny
	member.put_in_hands(pda)
	member.put_in_hands(pager)
	pda.attackby(pager, member)
	TEST_ASSERT(pda.aq_squad_pager == pager && pager.loc == pda, "Pager nie trafił do PDA")
	TEST_ASSERT(pda.aq_squad_pager_action?.owner == member, "PDA z pagerem nie dało przycisku pagera")
	TEST_ASSERT(pager.squad_channel?.get_user() == member, "Pager w PDA nie odbiera łączności noszącego")
	TEST_ASSERT(member.aq_has_squad_pager(), "Pager w PDA nie liczy się do komunikatów na ekranie")
	pda.AltClick(member)
	TEST_ASSERT(!pda.aq_squad_pager && pager.loc == member, "Alt-klik nie wyjął pagera z PDA")
	TEST_ASSERT(!pda.aq_squad_pager_action, "Przycisk pagera został po wyjęciu pagera")

/// Plan poziomu dla mapy taktycznej: pole na każdy kafelek wycinka, podłoga i ściana rozpoznane, sektory „C2”
/datum/unit_test/aquila_squad_map_layout

/datum/unit_test/aquila_squad_map_layout/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/list/layout = aq_build_squad_map_layout(floor.z)
	var/width = layout["width"]
	var/height = layout["height"]
	TEST_ASSERT(length(layout["tiles"]) == width * height, "Plan ma [length(layout["tiles"])] pól zamiast [width * height]")
	TEST_ASSERT(length(layout["area_grid"]) == width * height * layout["area_width"], "Siatka obszarów nie pokrywa planu")
	var/column = floor.x - layout["origin_x"]
	var/row = layout["origin_y"] + height - 1 - floor.y
	var/tile_char = copytext(layout["tiles"], row * width + column + 1, row * width + column + 2)
	TEST_ASSERT(tile_char == "f" || tile_char == "c", "Podłoga pod testem jest na planie jako „[tile_char]”")
	var/turf/wall = locate(/turf/closed) in block(locate(layout["origin_x"], layout["origin_y"], floor.z), locate(layout["origin_x"] + width - 1, layout["origin_y"] + height - 1, floor.z))
	if(wall)
		TEST_ASSERT(aq_squad_map_tile(wall) == "w", "Ściana nie jest na planie ścianą")
	GLOB.squad_map_bounds["[floor.z]"] = list(layout["origin_x"], layout["origin_y"], width, height)
	var/turf/top_left = locate(layout["origin_x"], layout["origin_y"] + height - 1, floor.z)
	TEST_ASSERT(aq_squad_sector(top_left) == "A1", "Lewy górny róg planu to sektor [aq_squad_sector(top_left)] zamiast A1")
	var/turf/next = locate(min(world.maxx, layout["origin_x"] + 25), layout["origin_y"] + height - 12, floor.z)
	if(next.x == layout["origin_x"] + 25)
		TEST_ASSERT(aq_squad_sector(next) == "C2", "Pole 25 w prawo i 11 w dół to sektor [aq_squad_sector(next)] zamiast C2")
	GLOB.squad_map_bounds -= "[floor.z]"

/// Drużyny XO: nowa drużyna z kanałem pagera, zmiana nazwy (stara preferencja dalej prowadzi do drużyny) i koloru
/datum/unit_test/aquila_squad_custom

/datum/unit_test/aquila_squad_custom/Run()
	for(var/datum/squad/squad as anything in GLOB.squad_manager.squads)
		TEST_ASSERT(squad.type != /datum/squad/aq_custom || squad.name != "Echo", "Wzorzec drużyny Echo z subtypesof() został na liście drużyn")
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	var/datum/squad/created = GLOB.squad_manager.aq_create_squad("Foxtrot", "#123456")
	TEST_ASSERT(created && (created in GLOB.squad_manager.squads), "Nie powstała nowa drużyna")
	TEST_ASSERT(created.squad_channel?.squad == created && created.squad_channel.key == created.aq_channel_key, "Nowa drużyna nie ma własnego kanału pagera")
	TEST_ASSERT(!GLOB.squad_manager.aq_create_squad("foxtrot", "#654321"), "Powstała druga drużyna o tej samej nazwie")
	var/datum/squad/alpha = aq_squad("Alpha")
	var/old_key = alpha.squad_channel.key
	TEST_ASSERT(alpha.aq_rename("Wilki", officer), "Nie udało się zmienić nazwy drużyny")
	TEST_ASSERT(aq_squad("Wilki") == alpha && aq_squad("Alpha") == alpha && aq_squad("Able") == alpha, "Po zmianie nazwy drużyna nie jest do znalezienia po nowej, pierwotnej i starej nazwie")
	TEST_ASSERT(alpha.squad_channel.key == old_key, "Zmiana nazwy przestawiła kanał pagera")
	TEST_ASSERT(findtext(alpha.squad_channel.style_message("Jan", "test"), "(Wilki)"), "Wiadomość pagera nie pokazuje nowej nazwy")
	TEST_ASSERT(!alpha.aq_rename("Bravo", officer), "Udało się nazwać drużynę jak inną")
	var/old_colour = alpha.colour
	TEST_ASSERT(alpha.aq_recolour("#00ff00", officer) && alpha.colour == "#00ff00", "Nie udało się zmienić koloru drużyny")
	alpha.aq_rename("Alpha", officer)
	alpha.aq_recolour(old_colour, officer)
	GLOB.squad_manager.squads -= created
	qdel(created)

/// Niezwrócony sprzęt: XO zgłasza go z konsoli, wykroczenie trafia do akt ochrony, drugi raz się nie da
/datum/unit_test/aquila_squad_gear_crime

/datum/unit_test/aquila_squad_gear_crime/Run()
	var/mob/living/carbon/human/soldier = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	soldier.real_name = "Szeregowy Testowy"
	var/datum/data/record/record = new
	record.fields["id"] = "aq_test_gear"
	record.fields["name"] = soldier.real_name
	record.fields["crim"] = list()
	record.fields["citation"] = list()
	GLOB.data_core.security += record
	var/datum/squad_loadout/aquila/kit = new /datum/squad_loadout/aquila/nt/soldier
	var/datum/squad_loan/loan = new(soldier, kit, list(/obj/item/clothing/suit/ship/squad))
	TEST_ASSERT(loan.aq_report(officer), "Zgłoszenie niezwróconego sprzętu się nie udało")
	var/list/crimes = record.fields["crim"]
	var/datum/data/crime/crime = length(crimes) ? crimes[1] : null
	TEST_ASSERT(crime?.crimeName == "Przywłaszczenie sprzętu drużyny", "W aktach nie ma wykroczenia za sprzęt")
	TEST_ASSERT(!loan.aq_report(officer), "To samo wypożyczenie zgłoszono drugi raz")
	GLOB.data_core.security -= record
	qdel(record)
	qdel(loan)
	qdel(kit)

/// Rozwiązanie drużyny (członkowie bez drużyny, pager bez kanału) i limit 10 drużyn
/datum/unit_test/aquila_squad_delete_limit

/datum/unit_test/aquila_squad_delete_limit/Run()
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human)
	var/datum/squad/doomed = GLOB.squad_manager.aq_create_squad("Golf", "#aa00aa")
	TEST_ASSERT(doomed, "Nie powstała drużyna do rozwiązania")
	doomed.add_member(member)
	var/obj/item/squad_pager/pager = allocate(/obj/item/squad_pager, null, doomed)
	TEST_ASSERT(GLOB.squad_manager.aq_delete_squad(doomed, officer), "Nie udało się rozwiązać drużyny")
	TEST_ASSERT(!(doomed in GLOB.squad_manager.squads), "Rozwiązana drużyna została na liście")
	TEST_ASSERT(!member.squad && !(member in doomed.members), "Członek rozwiązanej drużyny dalej w niej jest")
	TEST_ASSERT(!pager.squad && !pager.squad_channel, "Pager rozwiązanej drużyny dalej jest na jej kanale")
	var/list/created = list()
	for(var/i in 1 to 12)
		var/datum/squad/extra = GLOB.squad_manager.aq_create_squad("Limit[i]", "#101010")
		if(extra)
			created += extra
	TEST_ASSERT(length(GLOB.squad_manager.squads) == 10, "Drużyn jest [length(GLOB.squad_manager.squads)] zamiast limitu 10")
	for(var/datum/squad/extra as anything in created)
		GLOB.squad_manager.aq_delete_squad(extra, officer)

/// XO ustawia ciężki pancerz: automat wydaje go zamiast lekkiego, skrzynia i zwrot go przyjmują
/datum/unit_test/aquila_squad_heavy_armor

/datum/unit_test/aquila_squad_heavy_armor/Run()
	var/datum/squad/squad = aq_squad("Charlie")
	var/obj/machinery/squad_vendor/vendor = allocate(/obj/machinery/squad_vendor)
	var/datum/squad_loadout/aquila/kit = new /datum/squad_loadout/aquila/nt/soldier
	squad.aq_heavy_armor = TRUE
	var/list/issued = vendor.aq_issued_items(kit, squad)
	TEST_ASSERT((/obj/item/clothing/suit/ship/squad/aq_heavy in issued) && !(/obj/item/clothing/suit/ship/squad in issued), "Drużyna z ciężkim pancerzem dostaje lekki")
	squad.aq_heavy_armor = FALSE
	issued = vendor.aq_issued_items(kit, squad)
	TEST_ASSERT((/obj/item/clothing/suit/ship/squad in issued) && !(/obj/item/clothing/suit/ship/squad/aq_heavy in issued), "Drużyna z lekkim pancerzem dostaje ciężki")
	var/obj/item/storage/aq_squad_crate/crate = allocate(/obj/item/storage/aq_squad_crate)
	var/obj/item/clothing/suit/ship/squad/aq_heavy/heavy = allocate(/obj/item/clothing/suit/ship/squad/aq_heavy)
	var/datum/component/storage/storage = crate.GetComponent(/datum/component/storage)
	TEST_ASSERT(is_type_in_typecache(heavy, storage.can_hold), "Skrzynia nie przyjmuje ciężkiego pancerza")
	qdel(kit)

/// Regresje z przeglądu: ikona HUD bez obrotu, znacznik tylko na poziomach mapy, zwrot tylko wydanych rzeczy,
/// rozwiązanie drużyny bez przekazywania dowództwa
/datum/unit_test/aquila_squad_review_fixes

/datum/unit_test/aquila_squad_review_fixes/Run()
	var/datum/squad/squad = aq_squad("Delta")
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human)
	squad.add_member(leader)
	squad.set_leader(leader)
	var/image/holder = leader.hud_list?[SQUAD_HUD]
	TEST_ASSERT(holder && (holder.appearance_flags & RESET_TRANSFORM), "Ikona funkcji w HUD-zie obraca się i skaluje z postacią")
	var/list/centcom = SSmapping.levels_by_trait(ZTRAIT_CENTCOM)
	if(length(centcom) && !(centcom[1] in squad.aq_active_levels()) && !(centcom[1] in SSmapping.levels_by_trait(ZTRAIT_STATION)) && centcom[1] != leader.z)
		leader.aq_next_squad_marker = 0
		TEST_ASSERT(!squad.aq_place_marker_from_map(leader, list("x" = 10, "y" = 10, "z" = centcom[1], "marker" = SQUAD_MARKER_ATTACK)), "Znacznik z mapy stanął na poziomie CentCom")
	// zwrot: prywatna apteczka tego samego typu zostaje, dołożona pigułka nie znika
	var/obj/machinery/squad_vendor/vendor = allocate(/obj/machinery/squad_vendor)
	leader.squad_position = SQUAD_POSITION_MEDIC
	squad.unset_leader(leader)
	TEST_ASSERT(vendor.aq_vend(leader), "Automat nie wydał zestawu medyka")
	var/obj/item/storage/aq_squad_crate/crate = locate() in leader.held_items
	var/obj/item/storage/firstaid/regular/issued_kit = locate() in crate
	var/obj/item/storage/firstaid/regular/private_kit = allocate(/obj/item/storage/firstaid/regular)
	var/obj/item/reagent_containers/pill/patch/styptic/extra = allocate(/obj/item/reagent_containers/pill/patch/styptic)
	extra.forceMove(issued_kit)
	TEST_ASSERT(!vendor.return_item(leader, private_kit, quiet = TRUE) && !QDELETED(private_kit), "Automat przyjął prywatną apteczkę jako zwrot")
	vendor.return_item(leader, crate, quiet = TRUE)
	TEST_ASSERT(!QDELETED(extra) && extra.loc == vendor.drop_location(), "Rzecz dołożona do wydanej apteczki zniknęła przy zwrocie")
	qdel(extra)
	var/datum/squad_loan/loan = get_squad_loan(leader)
	if(loan)
		qdel(loan)
	// rozwiązanie: nikt nie przejmuje dowodzenia po drodze i nie zostają mu akcje dowódcy
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	var/datum/squad/doomed = GLOB.squad_manager.aq_create_squad("Hotel", "#336699")
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	doomed.add_member(first)
	doomed.add_member(second)
	doomed.set_leader(first)
	TEST_ASSERT(GLOB.squad_manager.aq_delete_squad(doomed, officer), "Nie udało się rozwiązać drużyny")
	TEST_ASSERT(!(doomed.aq_order_action?.owner) && !(doomed.aq_marker_action?.owner), "Po rozwiązaniu drużyny komuś zostały akcje dowódcy")
	TEST_ASSERT(!doomed.leader, "Rozwiązana drużyna ma dowódcę")

#undef TEST_ASSERT
