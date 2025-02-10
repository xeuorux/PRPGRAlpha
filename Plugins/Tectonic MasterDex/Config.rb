# Pokemon are assumed to be at this level for calculating EHP
EHP_LEVEL = 50

SEARCHES_STACK = true

MAPS_AVAILABLE_BY_CAP = {
	15 =>
		[
			136,138,30,	# Casaba Villa, Scenic Trail, Windy Way
			51,38,26,	# Foreclosed Tunnel, Bluepoint Beach, Bluepoint Grotto
			35,27,49,	# Impromptu Lab, Casaba Mart, Tourist's House
		], 
	20 =>
		[
			60,56,66,123,		# Shipping Lane, Novo Town, Novo Apartments Attic, Novo College
			142,140,141, 		# Starters Store Maps
			3,25,55,6,326,	 	# Kilna Turf, Grouz, Lingering Delta, LuxTech Campus, Carnation Graves
			301,37,7,8,53, 		# County Park, Svait, Repora Forest, The Shelf
			117,36,40, 			# Ice Cave, Grouz Mine, Gigalith's Guts
			11,122,120, 		# Eleig River Crossing, LuxTech Sewers, Hollowed Layer
			121,130,129,59, 	# Kilna Ascent, Canal Desert, Barren Crater, Feebas' Fin
			96,98,126, 			# Luxtech Cold Storage, LuxTech Cold Storage Basement, Carnation Stockpile
			4,86,       		# Scientist's House, Zigzagoon Nest
			323,87,103,92,    	# HQ Station Backroom, LuxTech Rec Center, Velenz Mart, Svait Lodge
			32,71,74,			# Novo Apartments, Novo Apartments Room 103, Novo Apartments Room 203
			91,65,85,			# Reading Ribombee Cafe, Nemeth Mart, Worried Man's House
			213,214,219,		# Velenz Menagerie, Team Chasm HQ, Stone Nest
			217,49,243,			# Sweetrock Harbor, Tourist's House, Chasm Base Mess Hall
			251,305,321,	    # Samorn's House, Feebas' Fin Warehouse, Crater Station Backroom
		],
	25 =>
		[
			335,185			# Svait Sauna Underground, Eleig Stretch
		],
	40 =>
		[
			155,29,47,		# Prizca West, Full Blast Records F2, Grand Hotal
			34,183,180,		# Battle Fair, Circuit Cave, Priza West Mart
			185,186,239,	# Eleig Stretch, Farm Placeholder, Ocean Fishing Zone
			187,189,202,	# Prizca East, The Catacombs, Mountaineer's House
			193,196,203,	# Lapras Shore, Boiling Cave, Skeevee Eevee Pub
			211,212,216,	# Split Peaks, Ocean Fishing, Highland Lake
			218,230,232,	# Abyssal Chamber, Galarian Fan's House, Biologist's House
			234,220,228,	# Ranger Recruitment, Prizca Sewers East, Hidden Laboratory
			223,250,288,	# Prizca Sewers West, Chasm Base Lab, Underground River
		],
	60 =>
		[
			217,316,	# Sweetrock Harbor, Sandtone Estuary
			257,258,	# Cave of Hatching, Whitebloom Town
			215,		# Sky Walk
		],
  }
  
ITEMS_AVAILABLE_BY_CAP = {
	15 => [],
	20 => [],
	25 => [],
	30 => [],
	35 => [],
	40 => [:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:DAWNSTONE,
			:DUSKSTONE,:SUNSTONE,:SHINYSTONE,:ICESTONE,:MOONSTONE,
			:NINJASCARF,:KNIGHTHELMET,:DIAMONDTIARA,:ALOLANWREATH,:GALARICAWREATH
			
			]
}

SURFING_LEVEL = 35

def hidden_map_encounter_switch_hash
	return {
		193 => VOLCANIC_SHORE_VISITED_SWITCH, # Volcanic Shore
		196 => VOLCANIC_SHORE_VISITED_SWITCH, # Boiling Cave
		288 => UNDERGROUND_RIVER_VISITED_SWITCH, # Underground River
		218 => UNDERGROUND_RIVER_VISITED_SWITCH, # Absysal Cavern
		215 => TEMPEST_REALM_VISITED_SWITCH, # Tempest Realm
		377 => GUARDIAN_ISLAND_VISITED_SWITCH, # Guardian Island
		413 => EVENTIDE_ISLE_VISITED_SWITCH, # Eventide Isle
		414 => EVENTIDE_ISLE_VISITED_SWITCH, # Eventide Peak
		411 => TRI_ISLAND_VISITED_SWITCH, # Tri Island
		415 => TRI_ISLAND_VISITED_SWITCH, # Tri Island -- Articuno
		416 => TRI_ISLAND_VISITED_SWITCH, # Tri Island -- Moltres
		417 => TRI_ISLAND_VISITED_SWITCH, # Tri Island -- Zapos
		357 => BATTLE_MONUMENT_VISITED_SWITCH, # Battle Monument
		182 => SPIRIT_ATOLL_VISITED_SWITCH, # Spirit Atoll
		180 => BLUSTERY_BOSK_VISITED_SWITCH, # Blustery Bosk
		264 => STORM_SOUND_VISITED_SWITCH, # Storm Sound
		192 => FIELD_OF_SPIRES_VISITED_SWITCH, # Field of Spires
		425 => SHIMMER_HAVEN_VISITED_SWITCH, # Blustery Bosk
	}
end