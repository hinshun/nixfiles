// priority: 0
ServerEvents.recipes(event => {
	// stairs
	function stair(inputItem, resultItem) {
		event.shaped(Item.of(resultItem,3), ['A ', 'AA'], {A: inputItem})
	}
	stair('twigs:bamboo_thatch','kubejs:bamboo_thatch_stairs')
	stair('kubejs:straw_thatch','kubejs:straw_thatch_stairs')
	stair('kubejs:flax_thatch','kubejs:flax_thatch_stairs')
	stair('kubejs:deepslate_gravel_bricks','kubejs:deepslate_gravel_brick_stairs')
	stair('kubejs:blackstone_gravel_bricks','kubejs:blackstone_gravel_brick_stairs')
	stair('kubejs:cobbled_blackstone','kubejs:cobbled_blackstone_stairs')
	stair('kubejs:lachryte','kubejs:lachryte_stairs')
	stair('kubejs:polished_lachryte','kubejs:polished_lachryte_stairs')
	stair('kubejs:lachryte_bricks','kubejs:lachryte_brick_stairs')
	stair('emerald_block','kubejs:lapis_stairs')
	stair('spelunkery:rough_lazurite_block','kubejs:lazurite_stairs')
	stair('oreganized:polished_glance','oreganized:polished_glance_stairs')
	stair('smooth_stone','kubejs:smooth_stone_stairs')
	stair('kubejs:exolite','architects_palette:myonite_stairs')
	stair('kubejs:cobbled_exolite','architects_palette:myonite_brick_stairs')
	
	// slabs
	function slab(inputItem, resultItem) {
		event.shaped(Item.of(resultItem,4), ['AA'], {A: inputItem})
		event.shaped(Item.of(inputItem), ['A', 'A'], {A: resultItem})
	}
	slab('kubejs:straw_thatch','kubejs:straw_thatch_slab')
	slab('kubejs:flax_thatch','kubejs:flax_thatch_slab')
	slab('kubejs:lachryte','kubejs:lachryte_slab')
	slab('kubejs:polished_lachryte','kubejs:polished_lachryte_slab')
	slab('kubejs:lachryte_bricks','kubejs:lachryte_brick_slab')
	slab('kubejs:deepslate_gravel_bricks','kubejs:deepslate_gravel_brick_slab')
	slab('kubejs:blackstone_gravel_bricks','kubejs:blackstone_gravel_brick_slab')
	slab('kubejs:cobbled_blackstone','kubejs:cobbled_blackstone_slab')
	slab('emerald_block','kubejs:lapis_slab')
	slab('spelunkery:rough_lazurite_block','kubejs:lazurite_slab')
	slab('oreganized:polished_glance','oreganized:polished_glance_slab')
	slab('kubejs:exolite','architects_palette:myonite_slab')
	slab('kubejs:cobbled_exolite','architects_palette:myonite_brick_slab')
	
	// walls
	function wall(inputItem, resultItem) {
		event.shaped(Item.of(resultItem,6), ['AAA'], {A: inputItem})
		event.shaped(Item.of(inputItem), ['A', 'A'], {A: resultItem})
	}
	wall('kubejs:lachryte','kubejs:lachryte_wall')
	wall('kubejs:polished_lachryte','kubejs:polished_lachryte_wall')
	wall('kubejs:lachryte_bricks','kubejs:lachryte_brick_wall')
	wall('kubejs:deepslate_gravel_bricks','kubejs:deepslate_gravel_brick_wall')
	wall('kubejs:blackstone_gravel_bricks','kubejs:blackstone_gravel_brick_wall')
	wall('kubejs:cobbled_blackstone','kubejs:cobbled_blackstone_wall')
	wall('emerald_block','kubejs:lapis_wall')
	wall('spelunkery:rough_lazurite_block','kubejs:lazurite_wall')
	wall('smooth_stone','kubejs:smooth_stone_wall')
	wall('kubejs:exolite','architects_palette:myonite_wall')
	wall('kubejs:cobbled_exolite','architects_palette:myonite_brick_wall')
	
	// pillars
	function pillar(inputItem, resultItem) {
		event.shaped(Item.of(resultItem,2), ['A', 'A'], {A: inputItem})
	}
	pillar('purpur_block','purpur_pillar')
	pillar('quark:midori_block','quark:midori_pillar')
	pillar('quark:iron_plate','quark:iron_pillar')
	pillar('polished_granite','quark:granite_pillar')
	pillar('polished_diorite','quark:diorite_pillar')
	pillar('polished_andesite','quark:andesite_pillar')
	pillar('quark:polished_dripstone','quark:dripstone_pillar')
	pillar('quark:polished_calcite','quark:calcite_pillar')
	pillar('quark:polished_tuff','quark:tuff_pillar')
	pillar('oreganized:polished_glance','kubejs:glance_pillar')
	pillar('smooth_basalt','basalt')
	pillar('paletteblocks:polished_basalt','polished_basalt')
	
	// bookshelves
	function bookshelf(inputItem, resultItem) {
		event.shaped(Item.of(resultItem,3), ['AAA', 'BBB', 'AAA'], {A: inputItem, B: 'book'})
	}
	bookshelf('quark:bamboo_planks','quark:bamboo_bookshelf')
	bookshelf('mynethersdelight:powdery_planks','everycomp:q/mynethersdelight/powdery_bookshelf')
	bookshelf('architects_palette:twisted_planks','everycomp:q/architects_palette/twisted_bookshelf')
	bookshelf('ecologics:azalea_planks','everycomp:q/ecologics/azalea_bookshelf')
	bookshelf('ecologics:coconut_planks','everycomp:q/ecologics/coconut_bookshelf')
	
	// deploy waxing
	function deployWaxing(inputItem, resultItem) {
		event.recipes.create.deploying(resultItem, [inputItem, 'honeycomb_block']).keepHeldItem()
	}
	deployWaxing('kubejs:copper_pillar', 'kubejs:waxed_copper_pillar')
	deployWaxing('kubejs:exposed_copper_pillar', 'kubejs:waxed_exposed_copper_pillar')
	deployWaxing('kubejs:weathered_copper_pillar', 'kubejs:waxed_weathered_copper_pillar')
	deployWaxing('kubejs:oxidized_copper_pillar', 'kubejs:waxed_oxidized_copper_pillar')
	deployWaxing('copperandtuffbackport:chiseled_copper', 'copperandtuffbackport:waxed_chiseled_copper')
	deployWaxing('copperandtuffbackport:exposed_chiseled_copper', 'copperandtuffbackport:waxed_exposed_chiseled_copper')
	deployWaxing('copperandtuffbackport:weathered_chiseled_copper', 'copperandtuffbackport:waxed_weathered_chiseled_copper')
	deployWaxing('copperandtuffbackport:oxidized_chiseled_copper', 'copperandtuffbackport:waxed_oxidized_chiseled_copper')
	deployWaxing('copperandtuffbackport:copper_door', 'copperandtuffbackport:waxed_copper_door')
	deployWaxing('copperandtuffbackport:exposed_copper_door', 'copperandtuffbackport:waxed_exposed_copper_door')
	deployWaxing('copperandtuffbackport:weathered_copper_door', 'copperandtuffbackport:waxed_weathered_copper_door')
	deployWaxing('copperandtuffbackport:oxidized_copper_door', 'copperandtuffbackport:waxed_oxidized_copper_door')
	deployWaxing('copperandtuffbackport:copper_trapdoor', 'copperandtuffbackport:waxed_copper_trapdoor')
	deployWaxing('copperandtuffbackport:exposed_copper_trapdoor', 'copperandtuffbackport:waxed_exposed_copper_trapdoor')
	deployWaxing('copperandtuffbackport:weathered_copper_trapdoor', 'copperandtuffbackport:waxed_weathered_copper_trapdoor')
	deployWaxing('copperandtuffbackport:oxidized_copper_trapdoor', 'copperandtuffbackport:waxed_oxidized_copper_trapdoor')
	deployWaxing('copperandtuffbackport:copper_grate', 'copperandtuffbackport:waxed_copper_grate')
	deployWaxing('copperandtuffbackport:exposed_copper_grate', 'copperandtuffbackport:waxed_exposed_copper_grate')
	deployWaxing('copperandtuffbackport:weathered_copper_grate', 'copperandtuffbackport:waxed_weathered_copper_grate')
	deployWaxing('copperandtuffbackport:oxidized_copper_grate', 'copperandtuffbackport:waxed_oxidized_copper_grate')
	deployWaxing('copperandtuffbackport:copper_bulb', 'copperandtuffbackport:waxed_copper_bulb')
	deployWaxing('copperandtuffbackport:exposed_copper_bulb', 'copperandtuffbackport:waxed_exposed_copper_bulb')
	deployWaxing('copperandtuffbackport:weathered_copper_bulb', 'copperandtuffbackport:waxed_weathered_copper_bulb')
	deployWaxing('copperandtuffbackport:oxidized_copper_bulb', 'copperandtuffbackport:waxed_oxidized_copper_bulb')
	deployWaxing('copperized:medium_weighted_pressure_plate', 'copperized:waxed_medium_weighted_pressure_plate')
	deployWaxing('copperized:exposed_medium_weighted_pressure_plate', 'copperized:waxed_exposed_medium_weighted_pressure_plate')
	deployWaxing('copperized:weathered_medium_weighted_pressure_plate', 'copperized:waxed_weathered_medium_weighted_pressure_plate')
	deployWaxing('copperized:oxidized_medium_weighted_pressure_plate', 'copperized:waxed_oxidized_medium_weighted_pressure_plate')
	deployWaxing('caverns_and_chasms:floodlight', 'caverns_and_chasms:waxed_floodlight')
	deployWaxing('caverns_and_chasms:exposed_floodlight', 'caverns_and_chasms:waxed_exposed_floodlight')
	deployWaxing('caverns_and_chasms:weathered_floodlight', 'caverns_and_chasms:waxed_weathered_floodlight')
	deployWaxing('caverns_and_chasms:oxidized_floodlight', 'caverns_and_chasms:waxed_oxidized_floodlight')
	deployWaxing('caverns_and_chasms:copper_bars', 'caverns_and_chasms:waxed_copper_bars')
	deployWaxing('caverns_and_chasms:exposed_copper_bars', 'caverns_and_chasms:waxed_exposed_copper_bars')
	deployWaxing('caverns_and_chasms:weathered_copper_bars', 'caverns_and_chasms:waxed_weathered_copper_bars')
	deployWaxing('caverns_and_chasms:oxidized_copper_bars', 'caverns_and_chasms:waxed_oxidized_copper_bars')
	deployWaxing('caverns_and_chasms:copper_button', 'caverns_and_chasms:waxed_copper_button')
	deployWaxing('caverns_and_chasms:exposed_copper_button', 'caverns_and_chasms:waxed_exposed_copper_button')
	deployWaxing('caverns_and_chasms:weathered_copper_button', 'caverns_and_chasms:waxed_weathered_copper_button')
	deployWaxing('caverns_and_chasms:oxidized_copper_button', 'caverns_and_chasms:waxed_oxidized_copper_button')
	deployWaxing('lightning_rod', 'caverns_and_chasms:waxed_lightning_rod')
	deployWaxing('caverns_and_chasms:exposed_lightning_rod', 'caverns_and_chasms:waxed_exposed_lightning_rod')
	deployWaxing('caverns_and_chasms:weathered_lightning_rod', 'caverns_and_chasms:waxed_weathered_lightning_rod')
	deployWaxing('caverns_and_chasms:oxidized_lightning_rod', 'caverns_and_chasms:waxed_oxidized_lightning_rod')
	deployWaxing('mynethersdelight:hoglin_trophy', 'mynethersdelight:waxed_hoglin_trophy')
	
	// panels, pillars, boards n stuff
	function panel(woodType, pillarItem, panelItem, boardItem) {
		// crafting slabs into panels
		if (woodType == 'quark:bamboo') {
			event.shaped(Item.of(panelItem + 's',3), ['AAA', 'AAA'], {A: woodType + '_planks_slab'})
		} else {
			event.shaped(Item.of(panelItem + 's',3), ['AAA', 'AAA'], {A: woodType + '_slab'})
		}
		// crafting panels into pillars
		event.shaped(Item.of(pillarItem,2), ['A', 'A'], {A: panelItem + 's'})
		// sawing planks into panels and back
		event.stonecutting(panelItem + 's', woodType + '_planks')
		event.stonecutting(woodType + '_planks', panelItem + 's')
		// sawing planks into pillars and back
		event.stonecutting(pillarItem, woodType + '_planks')
		event.stonecutting(woodType + '_planks', pillarItem)
		// sawing panels into pillars and back
		event.stonecutting(pillarItem, panelItem + 's')
		event.stonecutting(panelItem + 's', pillarItem)
		// sawing logs into panels and pillars
		event.stonecutting('4x ' + panelItem + 's', '#' + woodType + '_logs')
		event.stonecutting('4x ' + pillarItem, '#' + woodType + '_logs')
		// sawing panels into slabs walls and stairs
		event.stonecutting('2x ' + panelItem + '_slab', panelItem + 's')
		event.stonecutting('2x ' + panelItem + '_wall', panelItem + 's')
		event.stonecutting(panelItem + '_stairs', panelItem + 's')
		// sawing boards back into planks
		event.stonecutting(woodType + '_planks', boardItem + 's')
	}
	panel('minecraft:oak','modestmining:oak_pillar','modestmining:oak_board','woodworks:oak_board')
	panel('minecraft:spruce','modestmining:spruce_pillar','modestmining:spruce_board','woodworks:spruce_board')
	panel('minecraft:birch','modestmining:birch_pillar','modestmining:birch_board','woodworks:birch_board')
	panel('minecraft:jungle','modestmining:jungle_pillar','modestmining:jungle_board','woodworks:jungle_board')
	panel('minecraft:acacia','modestmining:acacia_pillar','modestmining:acacia_board','woodworks:acacia_board')
	panel('minecraft:dark_oak','modestmining:dark_oak_pillar','modestmining:dark_oak_board','woodworks:dark_oak_board')
	panel('minecraft:mangrove','modestmining:mangrove_pillar','modestmining:mangrove_board','woodworks:mangrove_board')
	panel('minecraft:crimson','modestmining:crimson_pillar','modestmining:crimson_board','woodworks:crimson_board')
	panel('minecraft:warped','modestmining:warped_pillar','modestmining:warped_board','woodworks:warped_board')
	panel('quark:bamboo','everycomp:mm/quark/bamboo_pillar','everycomp:mm/quark/bamboo_board','everycomp:abnww/quark/bamboo_board')
	panel('mynethersdelight:powdery','everycomp:mm/mynethersdelight/powdery_pillar','everycomp:mm/mynethersdelight/powdery_board','everycomp:abnww/mynethersdelight/powdery_board')
	panel('ecologics:azalea','everycomp:mm/ecologics/azalea_pillar','everycomp:mm/ecologics/azalea_board','everycomp:abnww/ecologics/azalea_board')
	panel('ecologics:coconut','everycomp:mm/ecologics/coconut_pillar','everycomp:mm/ecologics/coconut_board','everycomp:abnww/ecologics/coconut_board')
	panel('atmospheric:rosewood','everycomp:mm/atmospheric/rosewood_pillar','everycomp:mm/atmospheric/rosewood_board','atmospheric:rosewood_board')
	panel('atmospheric:yucca','everycomp:mm/atmospheric/yucca_pillar','everycomp:mm/atmospheric/yucca_board','atmospheric:yucca_board')
	panel('atmospheric:morado','everycomp:mm/atmospheric/morado_pillar','everycomp:mm/atmospheric/morado_board','atmospheric:morado_board')
	panel('environmental:cherry','everycomp:mm/environmental/cherry_pillar','everycomp:mm/environmental/cherry_board','environmental:cherry_board')
	panel('environmental:willow','everycomp:mm/environmental/willow_pillar','everycomp:mm/environmental/willow_board','environmental:willow_board')
	panel('environmental:wisteria','everycomp:mm/environmental/wisteria_pillar','everycomp:mm/environmental/wisteria_board','environmental:wisteria_board')
	panel('architects_palette:twisted','everycomp:mm/architects_palette/twisted_pillar','everycomp:mm/upgrade_aquatic/river_board','everycomp:abnww/architects_palette/twisted_board')
	panel('upgrade_aquatic:driftwood','everycomp:mm/upgrade_aquatic/driftwood_pillar','everycomp:mm/upgrade_aquatic/driftwood_board','upgrade_aquatic:driftwood_board')
	panel('autumnity:maple','everycomp:mm/autumnity/maple_pillar','everycomp:mm/autumnity/maple_board','autumnity:maple_board')
	panel('windswept:chestnut','everycomp:mm/windswept/chestnut_pillar','everycomp:mm/windswept/chestnut_board','windswept:chestnut_board')
})