# 한방에 가기!
    
    ffmpeg -y  -f lavfi -i 'testsrc=size=160x120[out0];aevalsrc=sin(440*2*PI*t)*0.01[out1]' -t 10 -r 29.970 -force_key_frames 'expr:eq(mod(n,30),0)' -c:v libx264 -preset ultrafast -b:v 1000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p -ac 2 -f mp4 0.mp4
    ffmpeg -y  -f lavfi -i 'testsrc=size=3840x2160[out0];aevalsrc=sin(440*2*PI*t)*0.01[out1]' -t 10 -r 29.970 -force_key_frames 'expr:eq(mod(n,30),0)' -c:v libx265 -preset ultrafast -b:v 1000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p -ac 2 -f mp4 0.mp4
    
    
    # https://github.com/axiomatic-systems/Bento4/blob/master/Source/Python/utils/mp4-dash-encode.py#L192
    ffmpeg -y  -i ~/Downloads/The_World_in_HDR_in_4K_HDR10.mkv  -t 10 -r 29.970 -force_key_frames 'expr:eq(mod(n,30),0)' -c:v libx265 -preset ultrafast -b:v 20000k -bufsize 20000k -maxrate 30000k -c:a aac -b:a 128k -ar 48000 -pix_fmt yuv420p -ac 2 -f mp4 0.mp4
    
    
    #docker run -v `pwd`:/mnt -it --rm alfg/bento4 mp4fragment /mnt/0.mp4 /mnt/1.mp4  --fragment-duration 1000
    docker run -v `pwd`:/mnt -it --rm alfg/bento4 mp4fragment /mnt/0.mp4 /mnt/1.mp4 --fragment-duration 1000
    rr htdocs/dash/vod/out_1s;docker run -v `pwd`:/mnt -v `pwd`/mp4-dash.py:/opt/bento4/utils/mp4-dash.py -it --rm alfg/bento4 utils/mp4-dash.py --force /mnt/1.mp4 -o /mnt/htdocs/dash/vod/out_1s --mpd-name=manifest.mpd ;find htdocs/dash/vod/out_1s;cat htdocs/dash/vod/out_1s/manifest.mpd
    ./tools/run_vodanalyzer.sh  /Users/m/dash-live-source-simulator/htdocs/dash/vod/out_1s/manifest.mpd 
    \mv out_1s.cfg htdocs/livesim_vod_configs/
    \mv out_1s_video.dat htdocs/livesim_vod_configs/
    \mv out_1s_audio.dat htdocs/livesim_vod_configs/
    sed -i -e 's/default_tsbd_secs = 300/default_tsbd_secs = 3000000000/g' htdocs/livesim_vod_configs/out_1s.cfg
    
    http://0.0.0.0:8059/livesim/out_1s/manifest.mpd
    
    web.py


# DASH-IF DASH Live Source Simulator

This software is intended as a reference that can be customized to provide a reference
for several use cases for live DASH distribution.

It uses VoD content in live profile as a start, and modifies the MPD and the media
segments to provide a live source. All modifications are made on the fly, which allows
for many different options as well as accurate timing testing.

The tool is written in Python and runs as an Apache mod_python plugin or using mod_wsgi.

The Dockerfile can be used to build a docker container that has Apache with the mod_python
plugin.

    docker build -t dash-live .
    
It exposes the Apache server on port 80 of the container. You need to map this to a port
on the host running the container. For example to use host port 8123:

    docker run -p 8123:80 -t dash-live


-----------------------


http://0.0.0.0:8123/livesim/testpic_2s/Manifest.mpd

docker run --name dlive -it -p 8123:80 -v `pwd`/htdocs:/var/www/localhost/htdocs dash-live
docker exec -it dlive sh


docker run -it -p 8123:80 -v `pwd`/htdocs:/var/www/localhost/htdocs dash-live




docker run -it -p 8123:80 -v `pwd`:/t dash-live sh


# 제한 사항

- 폴더명

    [파일명]_[세그먼트명]으로 되어 있어야 함
    
    htdocs/dash/vod/xxx => 안됨
    htdocs/dash/vod/xxx_1s => 됨

# LOCAL TEST

python -m dashlivesim.mod_wsgi.mod_dashlivesim -d htdocs/livesim_vod_configs -c htdocs/dash/vod

http://0.0.0.0:8059/livesim/testpic_2s/Manifest.mpd
http://0.0.0.0:8059/livesim/xxx_1s/stream.mpd

http://0.0.0.0:8059/livesim/xxx/video/avc1/init.mp4


127.0.0.1 - - [26/Aug/2017 02:26:38] "GET /livesim/testpic_2s/Manifest.mpd HTTP/1.1" 206 1922
127.0.0.1 - - [26/Aug/2017 02:26:39] "GET /livesim/testpic_2s/Manifest.mpd HTTP/1.1" 200 1917
127.0.0.1 - - [26/Aug/2017 02:26:44] "GET /livesim/testpic_2s/A48/init.mp4 HTTP/1.1" 200 651

127.0.0.1 - - [26/Aug/2017 02:28:48] "GET /livesim/xxx/stream.mpd HTTP/1.1" 206 1472
127.0.0.1 - - [26/Aug/2017 02:28:49] "GET /livesim/xxx/stream.mpd HTTP/1.1" 200 1467
127.0.0.1 - - [26/Aug/2017 02:28:49] "GET /livesim/xxx/video/avc1/init.mp4 HTTP/1.1" 404 60


http://0.0.0.0:8059/livesim/testpic_2s/Manifest.mpd
http://0.0.0.0:8059/livesim/xxx/stream.mpd
http://0.0.0.0:8059/livesim/xxx/video/avc1/init.mp4

 
# 오류 처리

error_response=Request for 1502191817.m4s was 1501955.3s too late => default_tsbd_secs를 크게 잡는다 = 30000000000000000