{%- from "gpg/map.jinja" import gpg with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- set user   = salt['pillar.get']('gpg_user') %}
{%- set email  = salt['pillar.get']('gpg_email') %}
{%- set params = gpg.users.get(user).create.get(email, {}) %}

include:
  - gpg.install
  - gpg.config

gpg_create_{{email}}:
  module.run:
    - gpg.create_key:
      - name_email: {{email}}
      {%- if params.name is defined %}
      - name_real: {{params.name}}
      {%- endif %}
      {%- if params.comment is defined %}
      - name_comment: {{params.comment}}
      {%- endif %}
      {%- if params.user is defined %}
      - user: {{user}}
      {%- endif %}
      {%- if params.gnupghome is defined %}
      - gnupghome: {{params.gnupghome}}
      {%- endif %} 
      {%- if params.key_type is defined %}
      - key_type: {{params.key_type}}
      {%- endif %}
      {%- if params.key_length is defined %}
      - key_length: {{params.key_length}}
      {%- endif %}
      {%- if params.subkey_type is defined %}
      - subkey_type: {{params.subkey_type}}
      {%- endif %}
      {%- if params.subkey_length is defined %}
      - subkey_length: {{params.subkey_length}}
      {%- endif %}
      {%- if params.expire_date is defined %}
      - expire_date: {{params.expire_date}}
      {%- endif %}
      {%- if params.passphrase is defined %}
      - use_passphrase: {{params.passphrase}} 
      {%- endif %}
