#!/usr/bin/env python3
from src.game.BaseNPC import BaseNPC


class Hero(BaseNPC):
    def __init__(self, data):
        super().__init__(data)

    def getDeaths(self):
        return self.data["deaths"]

    def getDenies(self):
        return self.data["denies"]

    def getGold(self):
        return self.data["gold"]

    def getType(self):
        return self.data["type"]

    def getXp(self):
        return self.data["xp"]
