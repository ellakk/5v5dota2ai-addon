#!/usr/bin/env python3

import random
from src.game.Building import Building


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

    def initialize(self, heroes):
        pass

    def actions(self, hero):
        if not hero.isAlive():
            return

        if hero.getAbilityPoints() > 0:
            hero.level_up(random.randint(0, 3))
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

    def attack_if_in_range(self, hero):
        enemies = self.world.get_enemies_in_attack_range(hero)
        if enemies:
            target = random.choice(enemies)
            hero.attack(self.world.get_id(target))
            return True
        return False

    def attack_unit_if_in_range(self, hero):
        enemies = self.world.get_enemies_in_attack_range(hero)
        enemies = [e for e in enemies if not isinstance(e, Building)]
        if enemies:
            target = random.choice(enemies)
            hero.attack(self.world.get_id(target))
            return True
        return False

    def push_lane(self, hero, friendly_tower, enemy_buildings):
        if not hasattr(hero, "target"):
            hero.target = ""

        if not hero.target:
            hero.target = self.world.find_entity_by_name(friendly_tower)
        elif self.world.get_distance(hero, hero.target) > 300:
            hero.move(*hero.target.getOrigin())
        elif (
            self.world.get_distance(hero, hero.target) < 300
        ) and hero.target.getTeam() == hero.getTeam():
            hero.target = self.world.find_entity_by_name(enemy_buildings[0])
        elif (
            self.world.get_distance(hero, hero.target) < 300
        ) and hero.target.isAlive():
            hero.attack(self.world.get_id(hero.target))
        elif self.world.get_distance(hero, hero.target) < 300:
            i = enemy_buildings.index(hero.target)
            hero.target = self.world.find_entity_by_name(enemy_buildings[i + 1])

    def creeps_in_range(self, hero, tower):
        creeps = self.world.get_friendly_creeps(hero)

        for c in creeps:
            if tower.getAttackRange() < self.world.get_distance(c, tower):
                return True
        return False

    # Brew goes mid
    def actions_brewmaster(self, hero):
        if self.attack_unit_if_in_range(hero):
            return

        self.push_lane(
            hero,
            "dota_goodguys_tower1_mid",
            [
                "dota_badguys_tower1_mid",
                "dota_badguys_tower2_mid",
                "dota_badguys_tower3_mid",
                "dota_badguys_tower4_mid",
            ],
        )

    # Pudge and lina boes bot
    def actions_pudge(self, hero):
        if self.attack_unit_if_in_range(hero):
            return

        self.push_lane(
            hero,
            "dota_goodguys_tower1_bot",
            [
                "dota_badguys_tower1_bot",
                "dota_badguys_tower2_bot",
                "dota_badguys_tower3_bot",
                "dota_badguys_tower4_bot",
            ],
        )

    def actions_lina(self, hero):
        pudge = self.world.find_entity_by_name("npc_dota_hero_pudge")

        if not pudge:
            hero.move(-6870, -6436, 256)
            return

        if self.attack_if_in_range(hero):
            return

        hero.move(*pudge.getOrigin())

    # Underload and chen goes top
    def actions_abyssal_underlord(self, hero):
        if self.attack_unit_if_in_range(hero):
            return

        self.push_lane(
            hero,
            "dota_goodguys_tower1_top",
            [
                "dota_badguys_tower1_top",
                "dota_badguys_tower2_top",
                "dota_badguys_tower3_top",
                "dota_badguys_tower4_top",
            ],
        )

    def actions_chen(self, hero):
        abyssal_underlord = self.world.find_entity_by_name(
            "npc_dota_hero_abyssal_underlord"
        )

        if not abyssal_underlord:
            hero.move(-6870, -6436, 256)
            return

        if self.attack_if_in_range(hero):
            return

        hero.move(*abyssal_underlord.getOrigin())
