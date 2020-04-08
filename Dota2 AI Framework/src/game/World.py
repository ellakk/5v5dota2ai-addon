#!/usr/bin/env python3
from src.game.BaseNPC import BaseNPC
from src.game.Tower import Tower
from src.game.Building import Building
from src.game.Hero import Hero
from src.game.PlayerHero import PlayerHero


class World:
    def __init__(self):
        self.entities = {}

    def _update(self, world):
        new_entities = {}
        for eid, data in world.items():
            entity = None
            if eid in self.entities:
                entity = self.entities[eid]
                entity.setData(data)
            else:
                entity = self._create_entity_from_data(data)
            new_entities[eid] = entity
        self.entities = new_entities

    def _create_entity_from_data(self, data):
        if data["type"] == "Hero" and data["team"] == 2:
            return PlayerHero(data)
        elif data["type"] == "Hero":
            return Hero(data)
        elif data["type"] == "Tower":
            return Tower(data)
        elif data["type"] == "Building":
            return Building(data)
        elif data["type"] == "BaseNPC":
            return BaseNPC(data)

    def _get_player_heroes(self):
        heroes = []
        for entity in self.entities.values():
            if isinstance(entity, PlayerHero):
                heroes.append(entity)
        return heroes

    def find_entity_by_name(self, name):
        for entity in self.entities.values():
            if entity.getName() == name:
                return entity
