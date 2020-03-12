import json
from library.bottle.bottle import route, run, template, post, get, request
from src.BotFramework import BotFramework

framework = BotFramework()

@get("/hello/<name>")
def index(name):
    return template("<b>Hello {{name}}</b>!", name=name)


@get("/api/party")
def party():
    resp = [
        "npc_dota_hero_lina",
        "npc_dota_hero_ursa",
        "npc_dota_hero_mars",
        "npc_dota_hero_sven",
        "npc_dota_hero_pudge",
    ]
    return json.dumps(resp)


@post("/api/register_heroes")
def register_heroes():
    postdata = request.body.read()

    print(postdata)
    return json.dumps("ok")

@post("/api/chat")
def chat():
    postdata = request.body.read()

    print(postdata)
    return json.dumps("ok")


@post("/api/update")
def update():
    post_data = request.body.read()
    world = json.loads(post_data)

    framework.update(world)
    framework.generate_bot_commands()
    commands = framework.receive_bot_commands()

    return json.dumps(commands)


run(host="localhost", port=8080, debug=True, reloader=True)
