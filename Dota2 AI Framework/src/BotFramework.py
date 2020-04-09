#!/usr/bin/env python3
from src.game.World import World
from src.BotExample import BotExample


class BotFramework:
    def __init__(self):
        self.world = World()
        self.agent = BotExample(self.world)
        self.initialized = False

    def get_party(self):
        return self.agent.party

    def update(self, data):
        self.world._update(data["world"]["entities"])

    def generate_bot_commands(self):
        if self.initialized:
            for hero in self.world._get_player_heroes():
                self.agent.actions(hero)
        else:
            self.agent.initialize(self.world._get_player_heroes())
            self.initialized = True

    def receive_bot_commands(self):
        commands = {}
        for hero in self.world._get_player_heroes():
            command = hero.get_command()
            if command:
                commands.update(command)
                hero.clear_and_archive_command()
        return commands
