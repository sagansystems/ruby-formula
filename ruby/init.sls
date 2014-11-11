
rvm:
  cmd:
    - run
    - name: curl -s -L get.rvm.io | bash -s stable --quiet-curl
    - user: {{ pillar['ruby']['user'] }}
    - unless: test -s "$HOME/.rvm/scripts/rvm"
    - require:
      - pkg: curl
      - cmd: rvm_gpg

# RVM is now signed and requires you to accept the gpg key first
rvm_gpg:
  cmd:
    - run
    - name: command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    - user: {{ pillar['ruby']['user'] }}
    - unless: gpg2 -k | grep 'RVM signing'

rvm_bashrc:
  cmd:
    - run
    - name: echo "[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc
    - user: {{ pillar['ruby']['user'] }}
    - unless: grep ".rvm/scripts/rvm" ~/.bashrc
    - require:
      - cmd: rvm

{% for ruby_version in pillar['ruby']['versions'] %}
{{ ruby_version }}:
  rvm.installed:
    {% if pillar['ruby']['default'] is defined and pillar['ruby']['default'] == ruby_version %}
    - default: True
    {% endif %}
    - user: {{ pillar['ruby']['user'] }}
    - require:
      - pkg: development
{% endfor %}
