#!/usr/bin/env python3
from src.game.BaseNPC import BaseNPC


class Hero(BaseNPC):
    def __init__(self, name, data, world):
        self.commands = [
            "ATTACK",
            "MOVE",
            "CAST",
            "BUY",
            "SELL",
            "USE_ITEM",
            "LEVELUP",
            "NOOP",
        ]
        self.command = None
        self.data = data
        # self.world = world

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

    ###########
    # Actions #
    ###########
    def attack(self, target):
        self.command = {self.getName(): {"command": "ATTACK", "target": target}}

    def move(self, x, y, z):
        self.command = {self.getName(): {"command": "MOVE", "x": x, "y": y, "z": z}}

    def cast(self, ability):
        self.command = {self.getName(): {"command": "CAST", "ability": ability}}

    def buy(self, item):
        self.command = {self.getName(): {"command": "BUY", "item": item}}

    def sell(self, slot):
        self.command = {self.getName(): {"command": "SELL", "slot": slot}}

    def useItem(self, slot):
        self.command = {self.getName(): {"command": "USE_ITEM", "slot": slot}}

    def levelUp(self, abilityIndex):
        self.command = {
            self.getName(): {"command": "LEVELUP", "abilityIndex": abilityIndex}
        }
