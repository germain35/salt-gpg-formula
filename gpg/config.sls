{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install

{%- for user, config in gpg.get('config', {}).iteritems() %}
  
  {%- set user_home_dir = salt['user.info'](user).home %}

gpg_conf_dir_{{user}}:
  file.managed:
    - name: {{ user_home_dir|path_join(gpg.conf_dir) }}
    - user: {{ user }}
    - mode: 700
    - makedirs: True

gpg_conf_file_{{user}}:
  file.managed:
    - name: {{ user_home_dir|path_join(gpg.conf_file) }}
    - user: {{ user }}
    - mode: 600
    - contents: {{ config }}
    - require:
      - file: gpg_conf_dir_{{user}}

{%- endfor %}