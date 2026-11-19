// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// Wszczepia implant z implantera danego typu na siebie (prawdziwe attack() implantera)
/datum/unit_test/proc/aq_self_implant(mob/living/carbon/human/patient, implanter_type)
	var/obj/item/implanter/implanter = allocate(implanter_type)
	var/obj/item/implant/implant = implanter.imp
	implanter.attack(patient, patient)
	if(!implant || implant.imp_in != patient || !(implant in patient.implants))
		return null
	return implant

/// AQUILA - implanty z wdrożenia robotyki: każdy wchodzi z implantera i daje podstawowy efekt
/datum/unit_test/aquila_robotyka_implants

/datum/unit_test/aquila_robotyka_implants/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human)

	// Rotbusttec: formaldehyd po śmierci
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human)
	TEST_ASSERT(aq_self_implant(corpse, /obj/item/implanter/aq_antirot), "Rotbusttec did not go in")
	corpse.death()
	TEST_ASSERT(corpse.reagents.has_reagent(/datum/reagent/toxin/formaldehyde), "Rotbusttec injected no formaldehyde on death")

	// Tarcza EMP
	var/obj/item/implant/aq_empshield/shield = aq_self_implant(patient, /obj/item/implanter/aq_empshield)
	TEST_ASSERT(shield, "The EMP shield did not go in")
	TEST_ASSERT(patient.emp_act(EMP_HEAVY) & EMP_PROTECT_CONTENTS, "The EMP shield did not stop an EMP")
	for(var/i in 1 to 5)
		patient.emp_act(EMP_HEAVY)
	TEST_ASSERT(shield.disabled, "A burst of EMPs did not overload the shield")
	qdel(shield)

	// Mapa taktyczna: przycisk holomapy
	var/obj/item/implant/aq_tacmap/tacmap = aq_self_implant(patient, /obj/item/implanter/aq_tacmap)
	TEST_ASSERT(tacmap, "The tactical map implant did not go in")
	var/datum/component/holomap/aq_tacmap/holo = tacmap.GetComponent(/datum/component/holomap/aq_tacmap)
	TEST_ASSERT(holo?.holobutton.owner == patient, "The tactical map gave no holomap button")
	qdel(tacmap)

	// Elektroniczny dostęp: drzwi otwierają się bez karty, ładunek schodzi
	var/obj/item/implanter/aq_access/access_implanter = allocate(/obj/item/implanter/aq_access)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MEDICAL)
	access_implanter.attackby(card, patient)
	var/obj/item/implant/aq_access/access = access_implanter.imp
	access_implanter.attack(patient, patient)
	TEST_ASSERT(access?.imp_in == patient, "The access implant did not go in")
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock)
	door.req_access = list(ACCESS_MEDICAL)
	var/uses_before = access.uses
	TEST_ASSERT(door.allowed(patient), "The access implant did not open the door")
	TEST_ASSERT_EQUAL(access.uses, uses_before - 1, "Opening the door used no charge")
	door.req_access = list(ACCESS_ARMORY)
	TEST_ASSERT(!door.allowed(patient), "The access implant opened a door it has no access to")
	qdel(access)

	// Swój-obcy: pocisk sojusznika przelatuje
	TEST_ASSERT(aq_self_implant(patient, /obj/item/implanter/aq_iff), "The IFF implant did not go in")
	TEST_ASSERT(aq_self_implant(other, /obj/item/implanter/aq_iff), "The IFF implant did not go in the shooter")
	var/obj/item/projectile/bullet = allocate(/obj/item/projectile/bullet)
	bullet.firer = other
	TEST_ASSERT(!bullet.can_hit_target(patient, ignore_loc = TRUE), "An allied bullet hit the IFF wearer")
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	TEST_ASSERT(bullet.can_hit_target(stranger, ignore_loc = TRUE), "The IFF implant protects people without it")

	// Zakłócacz augmentów
	var/obj/item/implant/disruptor = aq_self_implant(patient, /obj/item/implanter/aq_anti_augment)
	TEST_ASSERT(disruptor, "The augment disruptor did not go in")
	TEST_ASSERT(patient.aq_augments_disrupted(), "The augment disruptor does not disrupt augments")
	qdel(disruptor)
	TEST_ASSERT(!patient.aq_augments_disrupted(), "Augments stayed disrupted after removal")

	// Uziemienie bluespace: teleport odrzucony i paraliż
	TEST_ASSERT(aq_self_implant(patient, /obj/item/implanter/aq_teleport_blocker), "The grounding implant did not go in")
	var/turf/away = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	TEST_ASSERT(!do_teleport(patient, away, channel = TELEPORT_CHANNEL_BLUESPACE), "A grounded mob teleported")
	TEST_ASSERT(patient.IsParalyzed(), "The denied teleport did not paralyze")
	patient.SetParalyzed(0)

	// Zniewolenie umysłu: sługa osoby, która wszczepiła
	var/mob/living/carbon/human/master = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/slave = allocate(/mob/living/carbon/human)
	master.mind_initialize()
	slave.mind_initialize()
	var/obj/item/implant/aq_mindslave/mindslave = new()
	TEST_ASSERT(!mindslave.implant(master, master), "The mindslave implant enslaved its own user")
	TEST_ASSERT(mindslave.implant(slave, master), "The mindslave implant did not go in")
	TEST_ASSERT(slave.mind.has_antag_datum(/datum/antagonist/brainwashed), "The mindslave implant did not enslave")
	qdel(mindslave)
	TEST_ASSERT(!slave.mind.has_antag_datum(/datum/antagonist/brainwashed), "Removing the implant did not free the slave")

	// Znacznik Syndykatu
	var/obj/item/implant/syndie_tag = aq_self_implant(patient, /obj/item/implanter/aq_syndicate_iff)
	TEST_ASSERT(FACTION_SYNDICATE in patient.faction, "The Syndicate tag gave no faction")
	qdel(syndie_tag)
	TEST_ASSERT(!(FACTION_SYNDICATE in patient.faction), "The Syndicate faction stayed after removal")

	// Implant mocy: błyskawica męczy cel poza trybem walki
	var/obj/item/implant/aq_shock/shock = aq_self_implant(patient, /obj/item/implanter/aq_shock)
	TEST_ASSERT(shock, "The power implant did not go in")
	shock.activate()
	TEST_ASSERT(shock.enabled, "The power implant did not turn on")
	patient.set_combat_mode(FALSE)
	shock.zap(patient, other)
	TEST_ASSERT(other.getStaminaLoss() > 0, "The lightning did not tire the target")
	qdel(shock)

	// Zemsta: wyładowanie po śmierci i implant znika
	var/mob/living/carbon/human/avenger = allocate(/mob/living/carbon/human)
	var/obj/item/implant/revenge = aq_self_implant(avenger, /obj/item/implanter/aq_revenge)
	TEST_ASSERT(revenge, "The revenge implant did not go in")
	avenger.death()
	TEST_ASSERT(QDELETED(revenge), "The revenge implant did not fire on death")

	// Przejęcie: maszyny w przejętym obszarze jak dla SI
	var/obj/item/implant/aq_hijack/hijack = aq_self_implant(patient, /obj/item/implanter/aq_hijack)
	TEST_ASSERT(hijack, "The hijack implant did not go in")
	var/obj/machinery/machine = allocate(/obj/machinery/door/airlock)
	TEST_ASSERT(!patient.has_remote_machine_access(machine), "Remote access without a hijacked area")
	hijack.activate()
	hijack.hijacked_area = get_area(machine)
	TEST_ASSERT(patient.has_remote_machine_access(machine), "The hijacked area gave no remote access")
	hijack.emp_act(EMP_HEAVY)
	TEST_ASSERT(!patient.has_remote_machine_access(machine), "EMP did not break the hijack")
	qdel(hijack)

	// Szpiegowski: zgłoszenie zalicza cel
	var/obj/item/implant/aq_spying/bug = new()
	TEST_ASSERT(bug.implant(slave, master), "The spying implant did not go in")
	TEST_ASSERT(bug.spy == master.mind, "The spying implant did not remember the spy")
	var/datum/objective/aq_spy_implant/contract = new()
	contract.owner = master.mind
	contract.target = slave.mind
	TEST_ASSERT(!contract.check_completion(), "The contract completed before the report")
	bug.report()
	TEST_ASSERT(contract.check_completion(), "The report did not complete the contract")
	qdel(contract)

	// Cofnięcie: powrót na pozycję sprzed 10 s
	var/obj/item/implant/aq_warp/warp = aq_self_implant(other, /obj/item/implanter/aq_warp)
	TEST_ASSERT(warp, "The warp implant did not go in")
	var/turf/start = get_turf(other)
	warp.positions = list(list(start, world.time - 11 SECONDS))
	other.forceMove(away)
	warp.activate()
	TEST_ASSERT(get_turf(other) == start, "The warp implant did not rewind the position")
	qdel(warp)

	// Implant adrenaliny działa też na IPC: zdejmuje ogłuszenie, łata obudowę i przyspiesza
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	var/obj/item/implant/adrenalin/adrenalin = aq_self_implant(ipc, /obj/item/implanter/adrenalin)
	TEST_ASSERT(adrenalin, "The adrenalin implant did not go into an IPC")
	ipc.Paralyze(10 SECONDS)
	ipc.take_overall_damage(20, 20)
	var/damage_before = ipc.getBruteLoss() + ipc.getFireLoss()
	adrenalin.activate()
	TEST_ASSERT(!ipc.IsParalyzed(), "The adrenalin implant did not clear the stun of an IPC")
	TEST_ASSERT(ipc.getBruteLoss() + ipc.getFireLoss() < damage_before, "The adrenalin implant did not patch up an IPC")
	TEST_ASSERT(ipc.has_movespeed_modifier("aq_adrenalin_ipc"), "The adrenalin implant did not speed up an IPC")
	TEST_ASSERT_EQUAL(adrenalin.uses, 2, "The adrenalin implant used no charge")

	// Taktyczne wyparcie się: bez utraty przytomności
	var/obj/item/implant/deniability = aq_self_implant(other, /obj/item/implanter/aq_deniability)
	TEST_ASSERT(deniability, "The deniability implant did not go in")
	TEST_ASSERT(HAS_TRAIT(other, TRAIT_NOSOFTCRIT) && HAS_TRAIT(other, TRAIT_NOHARDCRIT), "The deniability implant did not stop crit")
	qdel(deniability)

	// Fałszywa ochrona umysłu
	var/obj/item/implant/aq_fake_mindshield/fake = aq_self_implant(patient, /obj/item/implanter/aq_fake_mindshield)
	TEST_ASSERT(fake && HAS_TRAIT(patient, TRAIT_FAKE_MINDSHIELD), "The fake mindshield shows nothing")
	fake.activate()
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_FAKE_MINDSHIELD), "The fake mindshield did not switch off")
	qdel(fake)

	// Implant agonalny: wybrany kanał radia, wchodzi też do cyborga
	var/mob/living/silicon/robot/borg = allocate(/mob/living/silicon/robot)
	var/obj/item/implant/deathrattle/aq_medical/rattle = new()
	TEST_ASSERT(rattle.implant(borg), "The deathrattle implant did not go into a cyborg")
	TEST_ASSERT(rattle in borg.implants, "The cyborg does not carry the deathrattle implant")
	TEST_ASSERT(findtext(rattle.aq_death_message(borg), borg.real_name), "The deathrattle message does not name the dead")
	borg.death()
	TEST_ASSERT(rattle.aq_alert_radio, "The deathrattle implant did not report the cyborg's death on the radio")
	var/obj/item/implant/deathrattle/plain = new()
	TEST_ASSERT(!plain.aq_radio_channel, "A plain deathrattle implant broadcasts by default")
	qdel(plain)

	// Ostre skrzydła: tylko ćmoludzie, rani sąsiadów
	TEST_ASSERT(!aq_self_implant(patient, /obj/item/implanter/aq_razorwing), "Razor wings went into a human")
	var/mob/living/carbon/human/moth = allocate(/mob/living/carbon/human)
	moth.set_species(/datum/species/moth)
	var/obj/item/implant/aq_razorwing/wings = aq_self_implant(moth, /obj/item/implanter/aq_razorwing)
	TEST_ASSERT(wings, "Razor wings did not go into a moth")
	var/mob/living/carbon/human/neighbour = allocate(/mob/living/carbon/human)
	wings.activate()
	TEST_ASSERT(neighbour.getBruteLoss() > 0, "Razor wings hurt nobody")

	// Sponsorski: reklama płaci
	var/obj/item/implant/aq_sponsorship/sponsor = aq_self_implant(patient, /obj/item/implanter/aq_sponsorship)
	TEST_ASSERT(sponsor, "The sponsorship implant did not go in")
	sponsor.say_ad()

/// AQUILA - augmenty z wdrożenia robotyki: wchodzą operacją albo autochirurgiem i działają
/datum/unit_test/aquila_robotyka_augments

/datum/unit_test/aquila_robotyka_augments/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/surgery_operation/limb/organ_manipulation/internal/manip = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/organ_manipulation/internal]

	// Każdy augment da się wszczepić operacją na narządach i siedzi w swoim slocie
	var/list/augment_types = list(
		/obj/item/organ/cyberimp/brain/aq_wire_interface,
		/obj/item/organ/cyberimp/brain/anti_stun,
		/obj/item/organ/cyberimp/brain/aq_emotional_manipulator,
		/obj/item/organ/cyberimp/eyes/aq_map,
		/obj/item/organ/cyberimp/aq_gustatorial,
		/obj/item/organ/cyberimp/aq_service_jack,
		/obj/item/organ/cyberimp/chest/aq_platelets,
		/obj/item/organ/cyberimp/chest/aq_air_sac,
		/obj/item/organ/cyberimp/chest/aq_optical_camo,
	)
	var/list/inserted = list()
	// narządy w klatce wymagają przepiłowanej kości (jak przy operacji)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_BONE_SAWED)
	for(var/augment_type in augment_types)
		var/obj/item/organ/augment = new augment_type()
		var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(augment.zone))
		TEST_ASSERT(manip.is_insert_available(limb, augment, augment.zone), "Organ manipulation cannot insert [augment_type]")
		augment.Insert(patient)
		TEST_ASSERT(patient.getorganslot(augment.slot) == augment, "[augment_type] did not take its slot")
		inserted[augment_type] = augment
	for(var/augment_type in augment_types)
		var/obj/item/organ/augment = inserted[augment_type]
		TEST_ASSERT(augment.aq_cyberpsychosis_cost in list(0, 5, 10, 18), "[augment_type] has a cyberpsychosis cost outside the 0/5/10/18 scale")

	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_AQ_WIRE_INTERFACE), "The wire interface shows no wires")
	// implant restartu OUN (core) budzi z utraty przytomności, raz na minutę
	var/obj/item/organ/cyberimp/brain/anti_stun/rebooter = inserted[/obj/item/organ/cyberimp/brain/anti_stun]
	patient.Unconscious(10 SECONDS)
	rebooter.on_life()
	TEST_ASSERT(!patient.IsUnconscious(), "The CNS rebooter did not wake the host")
	patient.Unconscious(10 SECONDS)
	rebooter.on_life()
	TEST_ASSERT(patient.IsUnconscious(), "The CNS rebooter woke the host again during its cooldown")
	patient.SetUnconscious(0)
	var/obj/item/organ/cyberimp/brain/aq_emotional_manipulator/emotions = inserted[/obj/item/organ/cyberimp/brain/aq_emotional_manipulator]
	emotions.mode = "happy"
	emotions.on_life()
	var/obj/item/organ/cyberimp/eyes/aq_map/map = inserted[/obj/item/organ/cyberimp/eyes/aq_map]
	TEST_ASSERT(map.GetComponent(/datum/component/holomap), "The map implant gave no holomap")
	var/obj/item/organ/cyberimp/aq_gustatorial/taster = inserted[/obj/item/organ/cyberimp/aq_gustatorial]
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/water, 10)
	taster.report_reagents(beaker.reagents)
	var/obj/item/organ/cyberimp/aq_service_jack/jack = inserted[/obj/item/organ/cyberimp/aq_service_jack]
	jack.diagnose(patient)
	TEST_ASSERT(patient.physiology.bleed_mod < 1, "The platelet factories did not lower bleeding")

	// Worek powietrza: oddychanie przez maskę
	var/obj/item/organ/cyberimp/chest/aq_air_sac/air = inserted[/obj/item/organ/cyberimp/chest/aq_air_sac]
	TEST_ASSERT(air.sac?.loc == patient, "The air sac is not inside the body")
	patient.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(patient), ITEM_SLOT_MASK)
	air.ui_action_click()
	TEST_ASSERT(patient.internal == air.sac, "The air sac did not become internals")
	air.ui_action_click()
	TEST_ASSERT(!patient.internal, "The air sac did not switch off")

	// Kamuflaż optyczny i zakłócacz augmentów
	var/obj/item/organ/cyberimp/chest/aq_optical_camo/camo = inserted[/obj/item/organ/cyberimp/chest/aq_optical_camo]
	camo.ui_action_click()
	TEST_ASSERT(camo.active, "The optical camo did not turn on")
	camo.emp_act(EMP_HEAVY)
	TEST_ASSERT(!camo.active, "EMP did not turn off the optical camo")
	ADD_TRAIT(patient, TRAIT_AQ_AUGMENTS_DISRUPTED, "test")
	camo.ui_action_click()
	TEST_ASSERT(!camo.active, "The optical camo worked while disrupted")
	REMOVE_TRAIT(patient, TRAIT_AQ_AUGMENTS_DISRUPTED, "test")

	// Analizator cyborgów: zwykły przedmiot
	var/obj/item/aq_robot_analyzer/analyzer = allocate(/obj/item/aq_robot_analyzer)
	analyzer.scan(patient, patient)

	// Kręgosłup przez autochirurga: Sandevistan, potem podkręcacz (jeden slot)
	var/obj/item/autosurgeon/surgeon = allocate(/obj/item/autosurgeon)
	var/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/sandy = new(surgeon)
	surgeon.storedorgan = list(sandy)
	surgeon.attack_self(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_SPINAL) == sandy, "The autosurgeon did not implant Sandevistan")
	var/old_move = patient.next_move_modifier
	sandy.ui_action_click()
	TEST_ASSERT(sandy.active && patient.next_move_modifier < old_move, "Sandevistan did not speed up the host")
	sandy.ui_action_click()
	TEST_ASSERT(!sandy.active && patient.next_move_modifier == old_move, "Sandevistan did not switch off cleanly")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_HEART) > 0, "Sandevistan cost the heart nothing")
	sandy.Remove(patient)

	var/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/overclocker = allocate(/obj/item/organ/cyberimp/chest/spinal/aq_overclocker)
	overclocker.Insert(patient)
	overclocker.ui_action_click()
	overclocker.on_life()
	TEST_ASSERT(overclocker.active && overclocker.overheat == 1, "The overclocker did not heat up while on")
	overclocker.Remove(patient)
	TEST_ASSERT(!overclocker.active && patient.next_move_modifier == old_move, "The overclocker stayed on after removal")

	// Oczy (narządy): monitor, laser
	var/obj/item/organ/eyes/robotic/aq_monitor/monitor = allocate(/obj/item/organ/eyes/robotic/aq_monitor)
	monitor.Insert(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_EYES) == monitor, "The monitor eye did not go in")
	monitor.ui_action_click()
	TEST_ASSERT(monitor.monitor, "The monitor eye has no camera console")
	monitor.Remove(patient)
	var/obj/item/organ/eyes/robotic/aq_laser/laser = allocate(/obj/item/organ/eyes/robotic/aq_laser)
	laser.Insert(patient)
	laser.ui_action_click()
	TEST_ASSERT(laser.armed, "The laser eyes did not arm")
	laser.on_click(patient, locate(patient.x + 2, patient.y, patient.z), list())
	TEST_ASSERT(!COOLDOWN_FINISHED(laser, shot_cooldown), "The laser eyes did not fire")
	laser.Remove(patient)

	// Wbudowany przedmiot
	var/obj/item/organ/cyberimp/arm/aq_embedded/embedded = allocate(/obj/item/organ/cyberimp/arm/aq_embedded)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	patient.put_in_active_hand(pen)
	embedded.attackby(pen, patient)
	TEST_ASSERT(embedded.get_stored() == pen, "The embedded module did not take the item")
	embedded.Insert(patient)
	embedded.ui_action_click()
	TEST_ASSERT(pen.loc == patient, "The embedded item did not extend")
	embedded.Retract()
	embedded.Remove(patient)

	// Hak i wyrzutnia nabojów: narzędzia w ręce
	var/obj/item/organ/cyberimp/arm/aq_climbing_hook/hook = allocate(/obj/item/organ/cyberimp/arm/aq_climbing_hook)
	hook.Insert(patient)
	hook.ui_action_click()
	TEST_ASSERT(istype(patient.get_item_for_held_index(2), /obj/item/aq_climbing_hook), "The climbing hook did not extend")
	hook.Remove(patient)
	var/obj/item/organ/cyberimp/arm/aq_shell_launcher/launcher_arm = allocate(/obj/item/organ/cyberimp/arm/aq_shell_launcher)
	launcher_arm.Insert(patient)
	launcher_arm.ui_action_click()
	var/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher/launcher = patient.get_item_for_held_index(2)
	TEST_ASSERT(istype(launcher) && launcher.chambered, "The shell launcher did not extend loaded")
	launcher_arm.Remove(patient)

	// Ramię ze sprzężeniem wirowym: obudowa + rdzeń anomalii wiru
	var/obj/item/aq_v1_arm_shell/shell = allocate(/obj/item/aq_v1_arm_shell)
	var/obj/item/assembly/signaler/anomaly/vortex/core = new(get_turf(patient))
	shell.attackby(core, patient)
	var/obj/item/organ/cyberimp/arm/aq_v1_arm/v1 = locate() in patient.held_items
	if(!v1)
		v1 = locate() in get_turf(patient)
	TEST_ASSERT(v1, "The vortex core did not finish the arm")
	v1.Insert(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_LEFT_ARM_AUG) == v1, "The vortex arm did not go in")
	v1.Remove(patient)
	qdel(v1)

	// Magnetyczne stopy: jeden implant wystarczy, drugi w drugiej nodze nic nie dodaje
	var/obj/item/organ/cyberimp/leg/aq_magboot/magboot = allocate(/obj/item/organ/cyberimp/leg/aq_magboot)
	magboot.Insert(patient)
	var/datum/action/innate/aq_maglock/maglock = magboot.maglock
	TEST_ASSERT(maglock?.owner == patient, "One magboot implant gave no toggle")
	var/obj/item/organ/cyberimp/leg/aq_magboot/spare = allocate(/obj/item/organ/cyberimp/leg/aq_magboot)
	spare.zone = BODY_ZONE_L_LEG
	spare.SetSlotFromZone()
	spare.Insert(patient)
	TEST_ASSERT(!spare.maglock, "A second magboot implant gave a second toggle")
	spare.Remove(patient)
	maglock.Trigger()
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_NEGATES_GRAVITY), "The magboot implant did not lock")
	magboot.Remove(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_NEGATES_GRAVITY), "The magnets stayed on after removal")

	// Mózg z łączem SI: zastępuje mózg, ciało żyje bez świadomości
	var/mob/living/carbon/human/shell_body = allocate(/mob/living/carbon/human)
	var/obj/item/organ/brain/aq_ai_uplink/uplink_brain = new()
	var/obj/item/organ/brain/old_brain = shell_body.getorganslot(ORGAN_SLOT_BRAIN)
	old_brain?.Remove(shell_body, TRUE)
	qdel(old_brain)
	uplink_brain.Insert(shell_body)
	TEST_ASSERT(shell_body.getorganslot(ORGAN_SLOT_BRAIN) == uplink_brain, "The AI uplink brain did not go in")
	TEST_ASSERT(shell_body.stat != DEAD, "The body died with the AI uplink brain")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
