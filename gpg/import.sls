{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  {%- if gpg.config is defined %}
  - gpg.config
  {%- endif %}

{%- for id, params in gpg.get('present', {}).iteritems() %}

  {%- if params.source is defined %}
    {%- set user_home_dir = salt['user.info'](params.user|default(gpg.user)).home %}
    {%- set key_file      = user_home_dir|path_join(id ~ '.gpg') %}

gpg_key_file_{{id}}:
  file.managed:
    - name: {{ key_file }}
    - source: {{ params.source }}
    - user: {{ params.user|default(gpg.user) }}
    - mode: 600
    - makedirs: True
    - require_in:
      - module: gpg_import_key_{{id}}

gpg_clean_key_file_{{id}}:
  file.absent:
    - name: {{ key_file }}
    - require:
      - module: gpg_import_key_{{id}}

  {%- endif %}

gpg_import_key_{{id}}:
  module.run:
    - gpg.import_key:
      - user: {{ params.user|default(gpg.user) }}
      {%- if params.gnuphome is defined %}
      - gnupghome: {{ params.gnupghome }}
      {%- endif %}
      {%- if params.text is defined %}
      - text: {{ params.text }}
      {%- elif params.filename is defined %}
      - filename: {{ params.filename }}
      {%- elif params.source is defined %}
      - filename: {{ key_file }}
      {%- endif %}

  {%- if params.trust_level is defined and (params.keyid is defined or params.fingerprint is defined) %}
gpg_trust_key_{{id}}:
  module.run:
    - gpg.trust_key:
      - user: {{ params.user|default(gpg.user) }}
      {%- if params.keyid is defined %}
      - keyid: {{ id }}
      {%- elif params.fingerprint is defined %}
      - fingerprint: {{ params.fingerprint }}
      {%- endif %}
      - trust_level: {{ params.trust_level }}
  {%- endif %}

{%- endfor %}
