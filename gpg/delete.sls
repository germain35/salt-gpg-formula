{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  - gpg.config

{%- for user, params in gpg.get('users', {}).iteritems() %}
  {%- if params.absent is defined and params.absent is mapping %}
    {%- for id, key_params in params.absent.iteritems() %}
gpg_delete_key_{{user}}_{{id}}:
  module.run:
    - gpg.delete_key:
      - user: {{ user }}
      {%- if key_params.gnuphome is defined %}
      - gnupghome: {{ key_params.gnupghome }}
      {%- endif %}
      {%- if key_params.keyid is defined %}
      - keyid: {{ key_params.keyid }}
      {%- elif key_params.fingerprint is defined %}
      - fingerprint: {{ key_params.fingerprint }}
      {%- endif %}
      {%- if key_params.delete_secret is defined %}
      - delete_secret: {{ key_params.delete_secret }}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
