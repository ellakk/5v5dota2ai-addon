#!/usr/bin/env python3


class BotExample:
    def __init__(self):
        self.party = [
            "npc_dota_hero_lina",
            "npc_dota_hero_ursa",
            "npc_dota_hero_mars",
            "npc_dota_hero_sven",
            "npc_dota_hero_pudge",
        ]

    def actions(self, hero):
        if hero.getName() == "npc_dota_hero_lina":
            hero.move(-5549.1870117188, 5351.6669921875, 256)

        if hero.getName() == "npc_dota_hero_ursa":
            hero.move(-5549.1870117188, 5351.6669921875, 256)

        if hero.getName() == "npc_dota_hero_sven":
            hero.move(-5549.1870117188, 5351.6669921875, 256)

        if hero.getName() == "npc_dota_hero_pudge":
            hero.move(-5549.1870117188, 5351.6669921875, 256)

        if hero.getName() == "npc_dota_hero_mars":
            hero.move(-5549.1870117188, 5351.6669921875, 256)
