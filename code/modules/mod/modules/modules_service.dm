//Service modules for MODsuits

///Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	desc = "Montowana na ramieniu ciężka artyleria dźwiękowa; ten moduł używa najlepszej technologii femtomanipulatorów, by \
		precyzyjnie zadać niemal śmiertelny ucisk... trąbce rowerowej, wydając wyjątkowo zapadający w pamięć dźwięk."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/on_use()
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_power_cost)

///Microwave Beam - Microwaves items instantly.
/obj/item/mod/module/microwave_beam
	name = "moduł wiązki mikrofalowej MOD"
	desc = "Dziwnie domowe urządzenie; ten moduł montuje się w dłoni użytkownika, \
		a połączony ze skanerami kulinarnymi w hełmie razi jedzenie precyzyjnym promieniowaniem mikrofalowym, \
		pozwalając bez najmniejszego trudu gotować z odległości. Niezalecany do użytku na winogronach."
	icon_state = "microwave_beam"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/microwave_beam, /obj/item/mod/module/organ_thrower)
	cooldown_time = 4 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/microwave_beam/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!istype(target, /obj/item))
		return
	if(!isturf(target.loc))
		balloon_alert(mod.wearer, "nie ma tego w schowku!")
		return
	var/obj/item/microwave_target = target
	var/datum/effect_system/spark_spread/spark_effect = new()
	spark_effect.set_up(2, 1, mod.wearer)
	spark_effect.start()
	mod.wearer.Beam(target,icon_state="lightning[rand(1,12)]", time = 5)
	if(microwave_target.microwave_act())
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
	else
		balloon_alert(mod.wearer, "nie da się tego podgrzać!")
	var/datum/effect_system/spark_spread/spark_effect_two = new()
	spark_effect_two.set_up(2, 1, microwave_target)
	spark_effect_two.start()
	drain_power(use_power_cost)

//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "moduł kaczego chodu MOD"
	desc = "Jedna z najprymitywniejszych technologii używanych przez HonkCo. Ten moduł działa na automatycznym systemie intencji \
		i dzięki wrażliwości na często ograniczone fale mózgowe pilota bezpośrednio odczytuje jego następny krok, \
		wpływając na buty, w których go zamontowano. Za pomocą bliźniaczego napędu grawitonowego tworzy \
		pod stopami użytkownika miniaturowe eteryczne wybuchy czasoprzestrzeni, co pozwala mu... \
		kolebać się, podskakując w tę i z powrotem z wigorem w kroku."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/waddle/on_part_activation()
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes)
		shoes.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50)
	mod.wearer.AddComponent(/datum/component/waddling)
	if((mod.wearer.mind?.assigned_role == JOB_NAME_CLOWN))
		SEND_SIGNAL(mod.wearer, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/mod/module/waddle/on_part_deactivation(deleting = FALSE)
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes && !deleting)
		qdel(shoes.GetComponent(/datum/component/squeak))
	qdel(mod.wearer.GetComponent(/datum/component/waddling))
	if((mod.wearer.mind?.assigned_role == JOB_NAME_CLOWN))
		SEND_SIGNAL(mod.wearer, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")
