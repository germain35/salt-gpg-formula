{%- from "gpg/map.jinja" import gpg with context %}

{%- for id, params in gpg.get('present', {}).iteritems() %}

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
      {%- endif %}

  {%- if params.trust_level is defined and params.fingerprint is defined %}
gpg_trust_key_{{id}}:
  module.run:
    - gpg.trust_key:
      - user: {{ params.user|default(gpg.user) }}
      - keyid: {{ id }}
      - fingerprint: {{ params.fingerprint }}
      - trust_level: {{ params.trust_level }}
  {%- endif %}

{%- endfor %}
