// Węzeł BCI z tg (Brain-Computer Interface): obudowa BCI, komora wszczepiająca i komponenty BCI.
/datum/techweb_node/bci_circuits
	id = "bci_circuits"
	tech_tier = 3
	display_name = "Interfejs mózg-komputer"
	description = "Układy scalone wszczepiane do mózgu. Czasem puszczają reklamy NanoTrasen we śnie."
	prereq_ids = list("adv_shells", "cyber_implants")
	design_ids = list(
		"bci_implanter", "bci_shell", "comp_bar_overlay", "comp_counter_overlay", "comp_install_detector", "comp_object_overlay", "comp_reagent_injector",
		"comp_target_intercept", "comp_thought_listener", "comp_vox")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
