# noTarget
# mirana Leap #
# Slardar Slithereen #
# Clinkz Skeleton walk #
# Brewmaster Thunder clap #
# Alchemist  # Unstable concoction


class Experiment41:
    def __init__(self, world):
        self.party = [
            "npc_dota_hero_mirana",
            "npc_dota_hero_slardar",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_brewmaster",
            "npc_dota_hero_alchemist"
        ]

        self.hero_no_targets_abilities = {
            "npc_dota_hero_mirana": 2,      # Leap
            "npc_dota_hero_slardar": 1,     # Slithereen
            "npc_dota_hero_clinkz": 2,      # Skeleton walk
            "npc_dota_hero_brewmaster": 0,  # Thunder clap
            "npc_dota_hero_alchemist": 1    # Unstable concoction
        }
        self.world = world

    def initialize(self, heroes):
        print("Starting Experiment 41:")

    def actions(self, hero):
        if self.world.gameticks > 10:
            self.maybe_use_no_target(hero)

    def maybe_use_no_target(self, hero):
        ability_index = self.hero_no_targets_abilities[hero.getName()]
        hero.cast(ability_index)
