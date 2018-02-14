{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.config

{%- for user, params in gpg.get('users', {}).iteritems() %}
  {%- if params.import is defined and params.import is mapping %}

    {%- set user_home_dir = salt['user.info'](user).home %}

    {%- for id, key_params in params.import.iteritems() %}

      {%- set key_file = user_home_dir|path_join(id ~ '.gpg') %}

      {%- if key_params.source is defined %}

gpg_key_file_{{user}}_{{id}}:
  file.managed:
    - name: {{ key_file }}
    - source: {{ key_params.source }}
    - skip_verify: True
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

      {%- elif key_params.text is defined %}

gpg_key_file_{{user}}_{{id}}:
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: gpg:users:{{user}}:import:{{id}}:text
    - user: {{ user }}
    - mode: 600
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
      {%- if key_params.gnupghome is defined %}
      - gnupghome: {{ key_params.gnupghome }}
      {%- endif %}
      {%- if key_params.source is defined or key_params.text is defined %}
      - filename: {{ key_file }}
      {%- elif key_params.filename is defined %}
      - filename: {{ key_params.filename }}
      {%- endif %}
    - require_in:
      - module: gpg_trust_key_{{user}}_{{id}}

  {%- if key_params.trust is defined %}
gpg_trust_key_{{user}}_{{id}}:
  module.run:
    - gpg.trust_key:
      - user: {{ user }}
      {%- if key_params.fingerprint is defined %}
      - fingerprint: {{ key_params.fingerprint }}
      {%- else %}
      - keyid: {{ id }}
      {%- endif %}
      - trust_level: {{ key_params.trust }}
  {%- endif %}

gpg_home_dir_{{user}}_{{id}}:
  file.directory:
    {%- if key_params.gnupghome is defined %}
    - name: {{ key_params.gnupghome }}
    {%- else %}
    - name: {{ user_home_dir|path_join(gpg.home_dir) }}
    {%- endif %}
    - user: {{ user }}
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - user
      - mode

    {%- endfor %}
  {%- endif %}
{%- endfor %}
