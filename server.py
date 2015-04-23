


class FakePool(object):
    def __init__(self, poolname, status=False):
        self.poolname = poolname
        self.status = status
    @property
    def json(self):
        return json.dumps({'poolname': self.poolname, 'status': self.status})

    def flip_state(self):
        self.status = not self.status

    def __str__(self):
        return '{}: {}'.format(self.poolname, self.status)

    def __repr__(self):
        return str(self)
    
from bottle import default_app, get, template, run
from bottle.ext.websocket import GeventWebSocketServer
from bottle.ext.websocket import websocket
import simplejson as json
users = set()

POOLS = {'something': FakePool('something', True),
         'something else': FakePool('something else'),
         'another pool': FakePool('another pool')}
@get('/')
def index():
    return template('index')

@get('/websocket', apply=[websocket])
def status(ws):
    users.add(ws)
    ws.send(json.dumps([pool.json for pool in POOLS.values()]))
    while True:
        pool_name = ws.receive()      
        if pool_name is not None:
            POOLS[pool_name].flip_state()
            if POOLS[pool_name].status:
                print 'Turned ' + pool_name + ' ON'
            else:
                print 'Turned ' + pool_name + ' OFF'
            for u in users:
                u.send(json.dumps([pool.json for pool in POOLS.values()]))
        else: break
    users.remove(ws)

application = default_app()
run(host='127.0.0.1', port=9000, server=GeventWebSocketServer, debug=True)
