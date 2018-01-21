{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install

{%- for user, params in gpg.get('users', {}).iteritems() %}

  {%- set user_home_dir = salt['user.info'](user).home %}

  {%- if params.gnupghome is defined %}
    {%- set gnupghome = params.gnupghome %}
  {%- else %}
    {%- set gnupghome = user_home_dir|path_join(gpg.home_dir) %}
  {%- endif %}

gpg_conf_dir_{{user}}:
  file.directory:
    - name: {{ gnupghome }}
    - user: {{ user }}
    - mode: 700
    - clean: {{ params.purge_gnupghome|default(gpg.purge_gnupghome) }}
    - makedirs: True

  {%- if params.config is defined %}

gpg_conf_file_{{user}}:
  file.managed:
    - name: {{ gnupghome|path_join(gpg.conf_file) }}
    - user: {{ user }}
    - mode: 600
    - contents: {{ params.config }}
    - require:
      - file: gpg_conf_dir_{{user}}

  {%- endif %}
{%- endfor %}