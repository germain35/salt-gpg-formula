{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.config

{%- for user, params in gpg.get('users', {}).iteritems() %}
  {%- if params.import is defined and params.import is mapping %}
    {%- for id, key_params in params.import.iteritems() %}

  {%- if params.source is defined %}

    {%- set user_home_dir = salt['user.info'](params.user|default(gpg.user)).home %}
    {%- set key_file      = user_home_dir|path_join(id ~ '.gpg') %}

gpg_key_file_{{user}}_{{id}}:
  file.managed:
    - name: {{ key_file }}
    - source: {{ key_params.source }}
    - user: {{ user }}
    - mode: 600
    - makedirs: True
    - require_in:
      - module: gpg_import_key_{{user}}_{{id}}

gpg_clean_key_file_{{user}}_{{id}}:
  file.absent:
    - name: {{ key_file }}
    - require:
      - module: gpg_import_key_{{user}}_{{id}}

  {%- endif %}

gpg_import_key_{{user}}_{{id}}:
  module.run:
    - gpg.import_key:
      - user: {{ user }}
      {%- if key_params.gnuphome is defined %}
      - gnupghome: {{ key_params.gnupghome }}
      {%- endif %}
      {%- if key_params.text is defined %}
      - text: {{ key_params.text }}
      {%- elif key_params.filename is defined %}
      - filename: {{ key_params.filename }}
      {%- elif key_params.source is defined %}
      - filename: {{ key_file }}
      {%- endif %}
    - require_in:
      - module: gpg_trust_key_{{user}}_{{id}}

  {%- if key_params.trust is defined %}
gpg_trust_key_{{user}}_{{id}}:
  module.run:
    - gpg.trust_key:
      - user: {{ user }}
      - keyid: {{ id }}
      {%- if key_params.fingerprint is defined %}
      - fingerprint: {{ key_params.fingerprint }}
      {%- endif %}
      - trust_level: {{ key_params.trust }}
  {%- endif %}

    {%- endfor %}
  {%- endif %}
{%- endfor %}
