class PokemonPokedexInfoScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dexlist,index,region,linksEnabled=false)
    @scene.pbStartScene(dexlist,index,region,false,linksEnabled)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   #  Last species viewed in dexlist
  end

  def pbStartSceneSingle(species,battle=false)   # For use from a Pokémon's summary screen
		region = -1
		if Settings::USE_CURRENT_REGION_DEX
		  region = pbGetCurrentRegion
		  region = -1 if region >= $Trainer.pokedex.dexes_count - 1
		else
		  region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
		end
    dexlist = []
    species_data = GameData::Species.get(species)

    mainSpeciesIndex = 0

    # Find all evolution tree members of the pokemon
    allSpecies = []
    getPrevolutionsRecursive(species_data).each do |key, value|
      value.each do |evo|
        allSpecies.push(evo[0])
      end
    end
    mainSpeciesIndex = allSpecies.length
    allSpecies.push(species)
    getEvolutionsRecursive(species_data).each do |key, value|
      value.each do |evo|
        allSpecies.push(evo[0])
      end
    end
    allSpecies.uniq!
    allSpecies.compact!

    # Create a dexlist with all the evo members
    allSpecies.each do |sp|
      dexnum = pbGetRegionalNumber(region,sp)
      dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
      dexListEntry =
			{
				:species => sp,
				:data => GameData::Species.get(sp),
				:index => dexnum,
				:shift => dexnumshift,
			}
      dexlist.push(dexListEntry)
    end

    # Start the scene
		@scene.pbStartScene(dexlist,mainSpeciesIndex,region,battle,true)
		ret = @scene.pbScene
		@scene.pbEndScene
    return ret   # Last species viewed in dexlist
	end

  def pbStartSceneParty(index,battle=false) # For use from a Pokémon's summary screen
    region = -1
		if Settings::USE_CURRENT_REGION_DEX
		  region = pbGetCurrentRegion
		  region = -1 if region >= $Trainer.pokedex.dexes_count - 1
		else
		  region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
		end
    dexlist = []

    # Create a dexlist with all the evo members
    $Trainer.party.each do |party_member|
      dexnum = pbGetRegionalNumber(region,party_member.species)
      dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
      dexListEntry =
			{
				:species => party_member.species,
				:data => party_member.species_data,
				:index => dexnum,
				:shift => dexnumshift,
			}
      dexlist.push(dexListEntry)
    end

    # Start the scene
		@scene.pbStartScene(dexlist,index,region,battle,true)
		ret = @scene.pbScene
		@scene.pbEndScene
    return ret   # Last species viewed in dexlist
  end
end