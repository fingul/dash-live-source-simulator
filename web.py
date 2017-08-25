import dashlivesim
import sys

sys.argv.extend('-d htdocs/livesim_vod_configs -c htdocs/dash/vod'.split())

print(sys.argv)

from dashlivesim.mod_wsgi import mod_dashlivesim

mod_dashlivesim.main()