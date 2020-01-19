{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.config

{%- for user, params in gpg.get('users', {}).items() %}
  {%- if params.import is defined and params.import is mapping %}

    {%- set user_home_dir = (salt['user.info'](user)).get('home', '/') %}

    {%- for id, key_params in params.get('import', {}).items() %}

      {%- set key_file     = user_home_dir|path_join(id ~ '.gpg') %}
      {%- set gpg_home_dir = key_params.get('gnupghome', params.get('gnupghome', user_home_dir|path_join(gpg.home_dir))) %}

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
      - cmd: gpg_import_key_{{user}}_{{id}}

gpg_clean_key_file_{{user}}_{{id}}:
  file.absent:
    - name: {{ key_file }}
    - require:
      - cmd: gpg_import_key_{{user}}_{{id}}

      {%- elif key_params.text is defined %}

gpg_key_file_{{user}}_{{id}}:
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: gpg:users:{{user}}:import:{{id}}:text
    - user: {{ user }}
    - mode: 600
    - require_in:
      - cmd: gpg_import_key_{{user}}_{{id}}

gpg_clean_key_file_{{user}}_{{id}}:
  file.absent:
    - name: {{ key_file }}
    - require:
      - cmd: gpg_import_key_{{user}}_{{id}}

      {%- endif %}

gpg_home_dir_{{user}}_{{id}}:
  file.directory:
    - name: {{gpg_home_dir}}
    - user: {{ user }}
    - makedirs: True
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - user
      - mode

gpg_import_key_{{user}}_{{id}}:
  cmd.run:
    - name: gpg --homedir {{gpg_home_dir}} --batch --import {{key_params.get('filename', key_file)}}
    - runas: {{ user }}
    - require:
      - file: gpg_home_dir_{{user}}_{{id}}
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

    {%- endfor %}
  {%- endif %}
{%- endfor %}
