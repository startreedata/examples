from opensky_api import OpenSkyApi

api = OpenSkyApi()
states = api.get_states()
for s in states.states:
    print("(%r, %r, %r, %r)" % (s.longitude, s.latitude, s.baro_altitude, s.velocity))

