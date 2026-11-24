// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

// Testy regresji poprawek z przeglądu aq33/AquilaStation#655: każdy wywołuje zgłoszony przypadek i sprawdza wynik

/// Akwarianin: rybka nie zostaje w ręce po przełożeniu, narzędzie jej nie zabija, karma nie powiela chemii, pancerz dostaje imię
/datum/unit_test/aquila_pr655_aquarian_fixes

/datum/unit_test/aquila_pr655_aquarian_fixes/Run()
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	helper.combat_mode = FALSE

	// Rozbita rybka w ręce wkładana do nowego klosza: jedna rybka w rękach, nie dwie
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/aquarian)
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(H)
	dome.shatter()
	TEST_ASSERT(helper.put_in_active_hand(dome), "Could not pick up the shattered fish")
	var/obj/item/reagent_containers/glass/aquarian_dome/new_dome = allocate(/obj/item/reagent_containers/glass/aquarian_dome, run_loc_floor_bottom_left)
	new_dome.reagents.add_reagent(/datum/reagent/water, 50)
	dome.restore_dome(new_dome, helper)
	var/held_copies = 0
	for(var/obj/item/held in helper.held_items)
		if(held == dome)
			held_copies++
	TEST_ASSERT_EQUAL(held_copies, 1, "The fish moved into a new dome is held in more than one hand")

	// Wylanie rybki z naczynia trzymanego w ręce: rybka leży na podłodze i nie jest już w ręce
	dome.shatter()
	helper.dropItemToGround(dome)
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, run_loc_floor_bottom_left)
	beaker.reagents.add_reagent(/datum/reagent/water, 60)
	dome.enter_vessel(beaker, helper)
	TEST_ASSERT(dome.vessel == beaker, "The fish did not enter the beaker")
	TEST_ASSERT(helper.put_in_active_hand(dome), "Could not pick up the fish in a beaker")
	dome.attack_self(helper)
	TEST_ASSERT(isturf(dome.loc), "Pouring out the fish did not put it on the floor")
	TEST_ASSERT(!helper.is_holding(dome), "The poured out fish is still listed as held")

	// Narzędzie kliknięte w luźny klosz poza trybem walki nie zabija rybki
	var/mob/living/carbon/human/H2 = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H2.set_species(/datum/species/aquarian)
	H2.fully_replace_character_name(H2.real_name, "Jan Rybak")
	H2.mind_initialize()
	var/obj/item/organ/brain/aquarian/loose = aquarian_dome(H2)
	loose.Remove(H2)
	loose.forceMove(run_loc_floor_bottom_left)
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench)
	loose.attackby(wrench, helper)
	TEST_ASSERT(loose.fish_alive(), "Clicking a loose dome with a wrench killed the fish")

	// Karma z puszki z trucizną: trucizna nie trafia do wody
	var/obj/item/fish_feed/feed = allocate(/obj/item/fish_feed)
	feed.reagents.add_reagent(/datum/reagent/toxin, 3)
	loose.fill_from(feed, helper)
	TEST_ASSERT(!loose.reagents.has_reagent(/datum/reagent/toxin), "Fish food copied poison from the can into the dome")
	TEST_ASSERT(feed.reagents.has_reagent(/datum/reagent/toxin, 3), "Feeding changed the can's contents")

	// Klosz z graczem w pustym pancerzu z fabrykatora: pancerz dostaje imię postaci
	var/mob/living/carbon/human/shell = aquarian_create_shell(run_loc_floor_bottom_left)
	loose.Insert(shell)
	TEST_ASSERT_EQUAL(shell.real_name, "Jan Rybak", "A dome inserted into a fabricated shell left the placeholder name")
	qdel(shell)

/// Grod: mówi w Poh'lan, pająka nie przeciąga inny gracz, korona nie wchodzi w zajęte ciało, kajdanki na nogach są widoczne
/datum/unit_test/aquila_pr655_grod_fixes

/datum/unit_test/aquila_pr655_grod_fixes/Run()
	var/mob/living/carbon/human/G = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	G.set_species(/datum/species/grod)
	TEST_ASSERT(G.can_speak_language(/datum/language/pohlan), "A grod cannot speak Poh'lan")
	var/obj/item/organ/brain/grod/crown = G.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT_EQUAL(crown.name, "korona Groda", "The crown inside a grod is named like a plain brain")

	// Kajdanki na nogi rysują się istniejącym stanem ikony
	var/obj/item/restraints/legcuffs/cuffs = new(G)
	G.legcuffed = cuffs
	G.update_inv_legcuffed()
	var/mutable_appearance/cuff_overlay = G.overlays_standing[LEGCUFF_LAYER]
	TEST_ASSERT(istype(cuff_overlay) && icon_exists(cuff_overlay.icon, cuff_overlay.icon_state), "Legcuffs on a grod have no sprite")
	G.legcuffed = null
	qdel(cuffs)
	G.update_inv_legcuffed()

	// Pająk przeciągnięty przez innego gracza nie wgryza się w ciało
	var/mob/living/simple_animal/hostile/grod_crown/spider = grod_leave_body(G)
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/organ/brain/host_brain = host.getorganslot(ORGAN_SLOT_BRAIN)
	host_brain.Remove(host, TRUE, TRUE)
	qdel(host_brain)
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	usr = other
	spider.MouseDrop(host)
	usr = null
	TEST_ASSERT(!host.getorganslot(ORGAN_SLOT_BRAIN) && !QDELETED(spider), "Another player's drag made the crown spider take a body")

	// Ciało bez mózgu, ale z czyjąś świadomością (zmiennokształtny) jest zajęte
	host.mind_initialize()
	TEST_ASSERT(spider.try_infest(host), "The spider did not react to an occupied body")
	TEST_ASSERT(!host.getorganslot(ORGAN_SLOT_BRAIN) && !QDELETED(spider), "The crown spider took a body that still had a mind")
	qdel(spider)

/// Quirki: organy rasy zostają, choroba łapie plazmaluda, wymuszony deathgasp nie usypia, picie uczula, poster wygasa
/datum/unit_test/aquila_pr655_quirk_fixes

/datum/unit_test/aquila_pr655_quirk_fixes/Run()
	var/mob/living/carbon/human/plasma = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	plasma.set_species(/datum/species/plasmaman)
	new /datum/quirk/tin_man(plasma, TRUE)
	TEST_ASSERT(istype(plasma.getorganslot(ORGAN_SLOT_LUNGS), /obj/item/organ/lungs/plasmaman), "Tin Man replaced a plasmaman's plasma lungs with oxygen lungs")
	new /datum/quirk/chronic_illness(plasma, TRUE)
	TEST_ASSERT(locate(/datum/disease/aq_chronic_illness) in plasma.diseases, "A plasmaman with chronic illness has no illness")

	var/mob/living/carbon/human/ethereal = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	ethereal.set_species(/datum/species/ethereal)
	new /datum/quirk/tin_man(ethereal, TRUE)
	TEST_ASSERT(istype(ethereal.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery/ethereal), "Tin Man replaced an ethereal's battery stomach")

	// Deathgasp wymuszony (śmierć, Głos Boga) nie usypia posiadacza Udawania śmierci
	var/mob/living/carbon/human/actor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	new /datum/quirk/death_mimicry(actor, TRUE)
	actor.emote("deathgasp")
	TEST_ASSERT(!HAS_TRAIT(actor, TRAIT_FAKEDEATH), "A forced deathgasp triggered Death Mimicry")

	// Alergia pokarmowa reaguje też na picie
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/quirk/food_allergic/allergy = new(drinker, TRUE)
	allergy.target_foodtypes = ALCOHOL
	var/obj/item/reagent_containers/food/drinks/beer/beer = allocate(/obj/item/reagent_containers/food/drinks/beer)
	beer.checkLiked(1, drinker)
	TEST_ASSERT(drinker.reagents.has_reagent(/datum/reagent/toxin/histamine), "Drinking alcohol did not trigger an alcohol allergy")

	// Wykluczenia i nastrój z plakatu
	var/excluded = FALSE
	for(var/list/pair in SSquirks.quirk_blacklist)
		if(("Okaleczone Oko" in pair) && ("Krótkowzroczny" in pair))
			excluded = TRUE
	TEST_ASSERT(excluded, "Scarred Eye can still be taken together with Nearsighted")
	var/datum/mood_event/poster_mood/poster = /datum/mood_event/poster_mood
	TEST_ASSERT(initial(poster.timeout) > 0, "The homemade poster mood never expires")

/// Rasy i okno postaci: mops, Psyfoza, żaba, IPC, Mięsoczłowiek, markingi i nazwy opcji
/datum/unit_test/aquila_pr655_species_fixes

/datum/unit_test/aquila_pr655_species_fixes/Run()
	// Emotka mopsa wpisana przez nie-człowieka nie sypie runtime'ami
	var/mob/living/simple_animal/hostile/grod_crown/critter = allocate(/mob/living/simple_animal/hostile/grod_crown, run_loc_floor_bottom_left)
	var/datum/emote/living/carbon/human/pug/woof/woof = new
	TEST_ASSERT(!woof.run_emote(critter, null, null, TRUE), "A non-human could woof")
	qdel(woof)

	// Nieprzytomna Psyfoza nic nie widzi i nie wysyła impulsów
	var/mob/living/carbon/human/psy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	psy.set_species(/datum/species/psyphoza)
	var/obj/item/organ/eyes/psyphoza/psy_eyes = psy.getorganslot(ORGAN_SLOT_EYES)
	TEST_ASSERT(istype(psy_eyes), "A psyphoza has no psychic eyes")
	psy.Unconscious(10 SECONDS)
	psy.update_stat()
	psy_eyes.on_life()
	var/atom/movable/screen/fullscreen/blind_screen = psy.screens["blind"]
	TEST_ASSERT(istype(blind_screen, /atom/movable/screen/fullscreen/blind) && !istype(blind_screen, /atom/movable/screen/fullscreen/blind/psychic), "An unconscious psyphoza still sees through the psychic screen")
	TEST_ASSERT(!psy_eyes.psychic_pulse(), "An unconscious psyphoza sent a psychic pulse")

	// Język żaby: przedmiot trafia do ręki, nie rani żaby rzutem
	var/mob/living/carbon/human/frog = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	frog.set_species(/datum/species/amphibian)
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/tongue = locate() in frog.actions
	TEST_ASSERT(tongue, "A frog has no sticky tongue")
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox, get_step(run_loc_floor_bottom_left, EAST))
	tongue.Activate(toolbox)
	TEST_ASSERT(frog.is_holding(toolbox), "The tongue did not bring the toolbox to the frog's hand")
	TEST_ASSERT_EQUAL(frog.getBruteLoss(), 0, "The pulled toolbox hurt the frog")

	// Maszyny brzmią po swojemu także w trybie głosów z Goona
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	ipc.set_species(/datum/species/ipc)
	TEST_ASSERT(isnull(ipc.get_goon_voice()), "An IPC got a human Goon voice")

	// Zmiana tożsamości na mięsoczłowieka bierze kolor mięsa z nowych cech
	var/mob/living/carbon/human/beef_source = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/beef_target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/list/colors = GLOB.beefman_colors
	beef_source.dna.features["beef_color"] = colors[1]
	beef_target.dna.features["beef_color"] = colors[length(colors)]
	beef_source.set_species(/datum/species/beefman)
	beef_target.set_species(/datum/species/beefman)
	beef_source.dna.transfer_identity(beef_target)
	TEST_ASSERT_EQUAL(beef_target.dna.species.fixed_mut_color, colors[colors[1]], "Transfer identity left the old beef colour")

	// Marking na ręce i ten sam na dłoni to różne ikony w pamięci podręcznej
	var/mob/living/carbon/human/marked = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/bodypart/l_arm/arm = marked.get_bodypart(BODY_ZONE_L_ARM)
	arm.aq_markings = list(list("bands", "#FFFFFF", BODY_ZONE_L_ARM))
	var/arm_key = marked.generate_icon_key(arm)
	arm.aq_markings = list(list("bands", "#FFFFFF", BODY_ZONE_PRECISE_L_HAND))
	TEST_ASSERT(arm_key != marked.generate_icon_key(arm), "A marking on the arm and on the hand share one icon cache key")
	arm.aq_markings = null

	// Opcja z częścią polskich nazw ma nazwę dla każdej wartości (inaczej okno postaci się wywraca)
	var/datum/preference/choiced/ai_display = GLOB.preference_entries_by_key["preferred_ai_core_display"]
	var/list/names = ai_display.get_display_names_with_polish()
	if(length(names))
		for(var/choice in ai_display.get_choices())
			var/value = ai_display.serialize(choice)
			TEST_ASSERT(!istext(value) || names[value], "The AI display option [value] has no display name")

/// Głosy ras (Grod, Mięsoczłowiek, Borowik, Akwarianin) mają nagrania, a satchele Groda jego sprite'y
/datum/unit_test/aquila_pr655_race_voices

/datum/unit_test/aquila_pr655_race_voices/Run()
	for(var/species_type in list(/datum/species/grod, /datum/species/beefman, /datum/species/psyphoza, /datum/species/aquarian, /datum/species/pug, /datum/species/amphibian))
		var/datum/species/species = new species_type
		var/list/recordings = GLOB.goon_speech_voices[species.goon_voice]
		TEST_ASSERT(length(recordings), "[species_type] has no species voice")
		for(var/kind in list("say", "ask", "exclaim"))
			TEST_ASSERT(isfile(recordings[kind]), "[species_type] voice has no [kind] recording")
		qdel(species)
	var/datum/species/grod/grod = new
	for(var/obj/item/storage/backpack/satchel/satchel_type as anything in typesof(/obj/item/storage/backpack/satchel))
		var/obj/item/satchel = new satchel_type
		TEST_ASSERT(grod_worn_sprite(satchel, "back", grod), "[satchel_type] has no grod sprite")
		qdel(satchel)
	qdel(grod)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
