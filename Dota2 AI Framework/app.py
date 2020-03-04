import json
from library.bottle.bottle import route, run, template, post, get, request

resp = {
    "npc_dota_hero_lina": {
        "command": "MOVE",
        "x": -5549.1870117188,
        "y": 5351.6669921875,
        "z": 256,
    },
    "npc_dota_hero_ursa": {
        "command": "MOVE",
        "x": -5549.1870117188,
        "y": 5351.6669921875,
        "z": 256,
    },
    "npc_dota_hero_mars": {
        "command": "LEVELUP",
        "abilityIndex": 0,
    }
}
count = 1

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
def registerHeroes():
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
    world = request.body.read()
    global count
    if count == 1:
        f = open("demofile2.txt", "w")
        f.write(world.decode("utf-8"))
        f.close()
        count = count + 1
    return json.dumps(resp)


run(host="localhost", port=8080, debug=True, reloader=True)
