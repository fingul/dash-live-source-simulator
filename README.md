# 성능

    개당 0.01 초 정도 걸린다고 가정할때, worker 갯수만 늘리면 무난하게 200 connection 가능 예상

# gunicorn

    - 개발
        
        gunicorn  -w 1 dashlivesim.mod_wsgi.mod_dashlivesim:application --reload --log-level debug
  
    - deploy
  
        gunicorn  -w 4 dashlivesim.mod_wsgi.mod_dashlivesim:application 

# mpeg-dash live download

    아직 확실이 동작하는 코드는 못찾음
    
    - youtube-dl => 안됨

    https://github.com/ping/instagram_private_api_extensions/blob/master/instagram_private_api_extensions/live.py

# availabilityStartTime 설정 (AST)

    UTCEPOCH = STARTTIME

    [HOST]/livesim/start_[UTCEPOCH]/MPD_URL

    1504191600 = 2017-09-01-00-00 ( https://www.epochconverter.com/ )

    http://qxqx.iptime.org/livesim/start_1504191600/10sec_1s/manifest.mpd
    => 샘플 타임코드 10초 파일 반복 (HEVC/3840x2160/AAC)

    http://qxqx.iptime.org/livesim/start_1504191600/out_1s/manifest.mpd
    => 샘플 4K 영상 10초 반복 (HEVC/3840x2160/AAC)

    http://qxqx.iptime.org/livesim/start_1504191600/4k_1s/manifest.mpd
    => 샘플 4K 영상 93초 반복 (HEVC/3840x2160/AAC)

    http://qxqx.iptime.org/livesim/start_1504191600/testpic_2s/Manifest.mpd
    => 샘플 640x360 영상 1시간 반복 (H264/640x360/AAC)
    
    http://0.0.0.0:8000/livesim/start_1504191600/4k_1s/manifest.mpd




# TEST LAB

    cat ~/.gpac/GPAC.cfg
    
        [Downloader]
        CleanCache=no
        DisableCache=yes
        
        [DASH]
        KeepFiles=yes
        #no 이면, 로컬 파일 저장
        MemoryStorage=yes   


    MP4Client -lf 0.log -logs all@debug http://qxqx.iptime.org/livesim/out_1s/manifest.mpd 
    MP4Client -lf 0.log -logs dash:network@info http://qxqx.iptime.org/livesim/out_1s/manifest.mpd
    
    tail -f 0.log | grep HTTP
    
    killall -9 MP4Client 

# MAC INSTALL - VLC3

    brew install caskroom/versions/vlc-nightly

# 한방에 가기!

    MP4Client -lf log.txt -logs dash:network@info http://vm2.dashif.org/livesim/testpic_2s/Manifest.mpd


    mkdir -p htdocs/dash/vod
    mkdir -p htdocs/livesim_vod_configs
    
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
    http://0.0.0.0:8059/livesim/10sec_1s/manifest.mpd
    http://0.0.0.0:8059/livesim/4k_1s/manifest.mpd
    http://0.0.0.0:8059/livesim/testpic_2s/Manifest.mpd
    
    
    wget http://0.0.0.0:8059/livesim/out_1s/video-hev1/1502369966.m4s
    


    
    http://qxqx.iptime.org/livesim/10sec_1s/manifest.mpd
    => 샘플 타임코드 10초 파일 반복 (HEVC/3840x2160/AAC)

    http://qxqx.iptime.org/livesim/out_1s/manifest.mpd
    => 샘플 4K 영상 10초 반복 (HEVC/3840x2160/AAC)
    
    http://qxqx.iptime.org/livesim/4k_1s/manifest.mpd
    => 샘플 4K 영상 93초 반복 (HEVC/3840x2160/AAC)
    
    http://qxqx.iptime.org/livesim/testpic_2s/Manifest.mpd
    => 샘플 640x360 영상 1시간 반복 (H264/640x360/AAC)
    

    
    
    http://qxqx.iptime.org:8059/livesim/4k_1s/manifest.mpd

    rsync -avh --iconv=utf-8-mac,utf-8 --delete --progress ~/dash-live-source-simulator q:
    
    web.py


# 배포

rsync -avh --iconv=utf-8-mac,utf-8 --delete --progress ~/dash-live-source-simulator q:

# 서비스 등록

sudo cp ~/dash-live-source-simulator/dashlive.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dashlive.service
sudo systemctl start dashlive.service
sudo systemctl status dashlive.service

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
