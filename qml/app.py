from random import randrange
from sqlite3 import connect

from flask import Flask, g, request

app = Flask(__name__)
DATABASE = "itemprices.sqlite"


def get_db():
    db = getattr(g, "_database", None)
    if db is None:
        db = g._database = connect(DATABASE)
    return db


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, "_database", None)
    if db is not None:
        db.close()


def query_db(query, args=(), one=False):
    cur = get_db().execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/itemprice")
def itemprice():
    itemname = request.args.get("itemname")
    try:
        price = query_db(
            "SELECT price from Pricelist where name = ?", [itemname], one=True
        )[0]
    except TypeError:
        price = 0
    return {"name": itemname, "price": price}
