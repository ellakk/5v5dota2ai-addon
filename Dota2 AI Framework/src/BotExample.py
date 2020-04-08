#!/usr/bin/env python3


class BotExample:
    def __init__(self, world):
        self.party = [
            "npc_dota_hero_brewmaster",
            "npc_dota_hero_pudge",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_lina",
            "npc_dota_hero_chen",
        ]
        self.world = world

    def actions(self, hero):
        if not hero.isAlive():
            return

        if hero.getName() == "npc_dota_hero_brewmaster":
            self.actions_brewmaster(hero)

        if hero.getName() == "npc_dota_hero_pudge":
            self.actions_pudge(hero)

        if hero.getName() == "npc_dota_hero_abyssal_underlord":
            self.actions_abyssal_underlord(hero)

        if hero.getName() == "npc_dota_hero_lina":
            self.actions_lina(hero)

        if hero.getName() == "npc_dota_hero_chen":
            self.actions_chen(hero)

    def actions_brewmaster(self, hero):
        tower = self.world.find_entity_by_name("dota_goodguys_tower1_mid")
        hero.move(*tower.getOrigin())

    def actions_pudge(self, hero):
        tower = self.world.find_entity_by_name("dota_goodguys_tower1_bot")
        hero.move(*tower.getOrigin())

    def actions_abyssal_underlord(self, hero):
        tower = self.world.find_entity_by_name("dota_goodguys_tower1_top")
        hero.move(*tower.getOrigin())

    def actions_lina(self, hero):
        pudge = self.world.find_entity_by_name("npc_dota_hero_pudge")
        hero.move(*pudge.getOrigin())

    def actions_chen(self, hero):
        abyssal_underlord = self.world.find_entity_by_name(
            "npc_dota_hero_abyssal_underlord"
        )
        hero.move(*abyssal_underlord.getOrigin())
