#!/usr/bin/env python3
from src.game.World import World
from src.BotExample import BotExample


class BotFramework:
    def __init__(self):
        self.agent = BotExample()
        self.world = World()

    def Update(self, data):
        self.world.update(data["world"]["entities"])

    def GenerateBotCommands(self):
        for hero in self.world.get_player_heroes():
            self.agent.actions(hero)

    def ReceiveBotCommands(self):
        commands = {}
        for hero in self.world.get_player_heroes():
            if hero.command:
                commands.update(hero.command)
        return commands
