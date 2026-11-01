/obj/effect/proc_holder/spell/targeted/infinite_guns
	name = "Pomniejsze przywołanie broni palnej"
	desc = "Po co przeładowywać, skoro masz nieskończenie wiele broni? Przywołuje niekończący się strumień karabinów powtarzalnych, które zadają małe obrażenia, ale powalają cele. Wymaga obu wolnych rąk. Po nauczeniu się tego zaklęcia nie możesz nauczyć się Tajemnej nawały."
	invocation_type = "none"
	include_user = TRUE
	range = -1

	school = "conjuration"
	charge_max = 750
	clothes_req = TRUE
	cooldown_min = 10 //Gun wizard
	action_icon_state = "bolt_action"
	var/summon_path = /obj/item/gun/ballistic/rifle/boltaction/enchanted

/obj/effect/proc_holder/spell/targeted/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_all_held_items()
		var/GUN = new summon_path
		C.put_in_hands(GUN)

/obj/effect/proc_holder/spell/targeted/infinite_guns/gun

/obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage
	name = "Tajemna nawała"
	desc = "Tym (potężnym) zaklęciem zalewasz wrogów potokiem tajemnej energii. Zadaje znacznie więcej obrażeń niż Pomniejsze przywołanie broni palnej, ale nie powala celów. Wymaga obu wolnych rąk. Po nauczeniu się tego zaklęcia nie możesz nauczyć się Pomniejszego przywołania broni palnej."
	action_icon_state = "arcane_barrage"
	summon_path = /obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage
