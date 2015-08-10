buddyclould-angular-app-dependencies:
  pkg.installed:
    - pkgs:
      - git
      - git-core
      - libicu-dev
      - libexpat-dev
      - build-essential
      - libexpat1-dev
      - libssl-dev
      - build-essential
      - g++
      - npm

buddycloud-angular-app-npm-packages:
  npm.installed:
    - names:
      - bower

buddycloud-angular-app-git-checkout:
  git.latest:
    - name: https://github.com/robotnic/angular-xmpp.git
    - rev: master
    - target: /opt/buddycloud-angular-app
    - force_reset: true
    - force: true

/opt/buddycloud-angular-app:
  file.directory:
    - user: nobody
    - group: nogroup
    - mode: 755
    - recurse:
      - user
      - group

/var/log/buddycloud-angular-app.log:
  file.managed:
    - user: nobody
    - group: nogroup
    - mode: 644

buddycloud-angular-app-bower-install:
  cmd.run:
    - name: bower --allow-root install angular-xmpp
    - cwd: /opt/buddycloud-angular-app
    - runas: nobody
    - env: 
      - HOME: /opt/buddycloud-angular-app
    - require:
      - pkg: buddyclould-angular-app-dependencies

/etc/nginx/sites-enabled/buddycloud.org.conf:
  file.managed:
    - source: salt://buddycloud-angular-app/nginx-vhost.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644

npm:
  pkg.installed

webhook-deployer:
  npm.installed:
    - require:
      - pkg: npm

/etc/init/buddycloud-angular-app-webhook-deployer.conf:
  file.managed:
    - source: salt://buddycloud-angular-app/webhook-upstart-script
    - user: root
    - group: root
    - mode: 0755
  service.running:
    - name: buddycloud-angular-app-webhook-deployer
    - enable: True
    - force_reload: True
    - force_restart: True

/var/log/buddycloud-angular-app-webhook-deployer.log:
  file.managed:
    - user: nobody
    - group: nogroup
    - mode: 644

/opt/buddycloud-angular-app-webhook-deployer/webhook-deployer.conf:
  file.managed:
    - source: salt://buddycloud-angular-app/webhook-deployer.conf
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
  service.running:
    - name: buddycloud-angular-app-webhook-deployer
    - enable: True
    - force_reload: True

webhook-firewall:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 8080
    - proto: tcp
    - save: True