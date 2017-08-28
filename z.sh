#!/usr/bin/env bash

#ffmpeg -y  -f lavfi -i 'testsrc=size=3840x2160[out0];aevalsrc=sin(440*2*PI*t)*0.01[out1]' -t 10 -r 29.970 -force_key_frames 'expr:eq(mod(n,30),0)' -c:v libx265 -preset ultrafast -b:v 1000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p -ac 2 -f mp4 0.mp4


# https://github.com/axiomatic-systems/Bento4/blob/master/Source/Python/utils/mp4-dash-encode.py#L192
# -t 10
#ffmpeg -y  -i ~/Downloads/The_World_in_HDR_in_4K_HDR10.mkv   -r 29.970 -force_key_frames 'expr:eq(mod(n,30),0)' -c:v libx265 -preset ultrafast -b:v 20000k -bufsize 20000k -maxrate 30000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p -ac 2 -f mp4 0.mp4
#docker run -v `pwd`:/mnt -it --rm alfg/bento4 mp4fragment /mnt/0.mp4 /mnt/1.mp4  --fragment-duration 1000
docker run -v `pwd`:/mnt -it --rm alfg/bento4 mp4fragment /mnt/0.mp4 /mnt/1.mp4 --fragment-duration 1000
rm -rf htdocs/dash/vod/mini_1s;docker run -v `pwd`:/mnt -v `pwd`/mp4-dash.py:/opt/bento4/utils/mp4-dash.py -it --rm alfg/bento4 utils/mp4-dash.py --force /mnt/1.mp4 -o /mnt/htdocs/dash/vod/mini_1s --mpd-name=manifest.mpd ;find htdocs/dash/vod/mini_1s;cat htdocs/dash/vod/mini_1s/manifest.mpd
./tools/run_vodanalyzer.sh  htdocs/dash/vod/mini_1s/manifest.mpd
\mv mini_1s.cfg htdocs/livesim_vod_configs/
\mv mini_1s_video.dat htdocs/livesim_vod_configs/
\mv mini_1s_audio.dat htdocs/livesim_vod_configs/
sed -i -e 's/default_tsbd_secs = 300/default_tsbd_secs = 3000000000/g' htdocs/livesim_vod_configs/mini_1s.cfg
