{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  {%- if gpg.config is defined %}
  - gpg.config
  {%- endif %}

{%- for id, params in gpg.get('absent', {}).iteritems() %}

gpg_delete_key_{{id}}:
  module.run:
    - gpg.delete_key:
      - user: {{ params.user|default(gpg.user) }}
      {%- if params.gnuphome is defined %}
      - gnupghome: {{ params.gnupghome }}
      {%- endif %}
      {%- if params.keyid is defined %}
      - keyid: {{ params.keyid }}
      {%- elif params.fingerprint is defined %}
      - fingerprint: {{ params.fingerprint }}
      {%- endif %}
      {%- if params.delete_secret id defined %}
      - delete_secret: {{ params.delete_secret }}
      {%- endif %}

{%- endfor %}
