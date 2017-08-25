import re
import shlex

import subprocess

import os

_f = '\"default sample duration\"\:(\d+)'
__f = re.compile(_f)

TEST_MAYBE = '''
[
{
  "name":"moof",
  "header_size":8,
  "size":468,
  "children":[
  {
    "name":"mfhd",
    "header_size":12,
    "size":16,
    "sequence number":2
  },
  {
    "name":"traf",
    "header_size":8,
    "size":444,
    "children":[
    {
      "name":"tfhd",
      "header_size":12,
      "size":20,
      "track ID":2,
      "default sample duration":1024
    },
    {
      "name":"tfdt",
      "header_size":12,
      "size":20,
      "base media decode time":0
    },
    {
      "name":"trun",
      "header_size":12,
      "size":396,
      "sample count":94,
      "data offset":476
    }]
  }]
},
{
  "name":"mdat",
  "header_size":8,
  "size":13195
}
]
'''


def find_default_sample_duration(s):
    try:
        return int(__f.findall(s)[0])
    except:
        return 0


def get_maybe_duration(filename):
    # mp4dump out/audio/und/mp4a/seg-1.m4s --format json
    cmds = "/usr/local/bin/mp4dump {filename} --format json".format(filename=filename)
    l_cmd = shlex.split(cmds)

    s = subprocess.check_output(l_cmd)
    #print(s)
    return find_default_sample_duration(s)


if __name__ == '__main__':
    find_default_sample_duration(TEST_MAYBE)

    filename = os.path.abspath(os.path.join(os.path.dirname(__file__), '../tests/testpic/A1/1.m4s'))

    print("filename={filename}".format(filename=filename))
    maybe_duration = get_maybe_duration(filename=filename)
    print("maybe_duration={maybe_duration}".format(maybe_duration=maybe_duration))
