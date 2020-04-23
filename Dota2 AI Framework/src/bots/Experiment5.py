#!/usr/bin/env python3
import os

class Experiment5:
    def __init__(self, world):
        self.party = [
            "npc_dota_hero_brewmaster",
            "npc_dota_hero_pudge",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_lina",
            "npc_dota_hero_chen",
        ]
        self.hero_items = {
            "npc_dota_hero_brewmaster": "item_clarity",
            "npc_dota_hero_pudge": "item_faerie_fire",
            "npc_dota_hero_abyssal_underlord": "item_smoke_of_deceit",
            "npc_dota_hero_lina": "item_clarity",
            "npc_dota_hero_chen": "item_dust"
        }
        self.world = world

    def initialize(self, heroes):
        pass

    def actions(self, hero):
        if not hero.isAlive():
            return
        print("gameticks: {}".format(self.world.gameticks))
        if self.world.gameticks == 10:
            self.buy_items(hero)

        if self.world.gameticks == 20:
            self.assert_items_in_inventory()

    def buy_items(self, hero):
        item = self.hero_items[hero.getName()]
        hero.buy(item)

    def assert_items_in_inventory(self):
        print("Asserting items in inventory")

        heroes = self.world._get_player_heroes()
        total_tests = 5
        passed = 0
        for hero in heroes:
            items = hero.get_items()
            item = self.hero_items[hero.getName()]
            item_names = [n["name"] for n in items.values() if n]
            print("------")
            if item in item_names:
                print("PASSED: {0} is in {1}'s inventory".format(
                    item, hero.getName()))
                passed = passed + 1
            else:
                print("FAILED: {0} is not in {1}'s inventory".format(
                    item, hero.getName()))
            print("------")

        print("------")
        print("{0}/{1} tests passed".format(passed, total_tests))
        print("------")
        os._exit(1)
