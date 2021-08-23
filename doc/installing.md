# Enable audio (loads snd_bcm2835)
dtparam=audio=on


Install Rapsberry Pi OS Lite (32-bit)

Run `sudo raspi-config`
  5: Localisation Options
    Change 
  5: Localisation Options
    L4: WLAN Country
      Pick your country
  Finish and reboot

sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
  Add this to the bottom:
    network={
        ssid="your-wifi-ssid"
        psk="your-wifi-password"
    }

Install Mopidy:
  wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
  sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list
  sudo apt update
  sudo apt install mopidy mopidy-spotify git ruby postgresql libpq-dev python3-pip autossh redis ruby-dev libsqlite3-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
  sudo python3 -m pip install Mopidy-Iris
  sudo adduser --disabled-password spinner
  sudo adduser --disabled-password --shell /bin/false autossh
  sudo -u autossh ssh-keygen
  # Copy your SSH key to the target host.
  sudo nano /etc/ssh/sshd_config
    Add the following lines:
      GatewayPorts yes
      ListenAddress 0.0.0.0
      PasswordAuthentication no
  sudo service ssh reload
  sudo nano /etc/default/autossh # Add the following contents:
    AUTOSSH_DEBUG=no
    SSH_OPTIONS="-N -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' -R 2223:127.0.0.1:22 -R 8081:127.0.0.1:8080 -R 6681:127.0.0.1:6680 chikitchen@chikitchen.aschmitz.org -i /home/autossh/.ssh/id_rsa"
  sudo nano /lib/systemd/system/autossh.service
    [Unit]
    Description=autossh
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=autossh
    EnvironmentFile=/etc/default/autossh
    ExecStart=/usr/bin/autossh $SSH_OPTIONS
    Restart=always
    RestartSec=60

    [Install]
    WantedBy=multi-user.target
  sudo ln -s /lib/systemd/system/autossh.service /etc/systemd/system/autossh.service
  sudo systemctl daemon-reload
  sudo systemctl enable autossh
  sudo systemctl enable ssh
  sudo nano /usr/share/alsa/alsa.conf
    Change "defaults.ctl.card" and "defaults.pcm.card" to "1"
  sudo nano /etc/mopidy/mopidy.conf
    Add Spotify creds from https://mopidy.com/ext/spotify/
      Add `username` and `password` values to the `[spotify]` section.
        This is *required* for some reason, and is in the docs as required.
    Add:
      [file]
      enabled = true
      media_dirs = /var/lib/mopidy/music
  sudo systemctl enable mopidy
  sudo mkdir -p /var/www/spinner/shared/config
  sudo mkdir -p /var/www/spinner/shared/tmp/pids
  sudo -u postgres psql
    CREATE USER pi;
    ALTER USER pi CREATEDB;
    GRANT ALL PRIVILEGES ON DATABASE pi to pi;
    ALTER DATABASE pi OWNER TO pi;
  sudo nano /var/www/spinner/shared/config/cable.yml
    production:
      adapter: redis
      url: redis://localhost:6379/1
      channel_prefix: spinner_production
  sudo nano /var/www/spinner/shared/config/database.yml
    production:
      &common-config
      adapter: postgresql
      database: pi
      pool: 5

    development: *common-config
    test: *common-config
  sudo nano /var/www/spinner/shared/config/secrets.yml
    production:
      secret_key_base: `head -c 1000 /dev/urandom | sha512sum`
      mopidy:
        uri: http://127.0.0.1:6680/mopidy/rpc
        periodic_timer: 5
  sudo touch /var/www/spinner/shared/config/storage.yml
  sudo chown -R pi:pi /var/www/spinner
  sudo reboot

cap production systemd:spinner_mopidy:setup
cap production puma:systemd:config puma:systemd:enable
cap production deploy

sudo -u spinner -i
  git checkout https://github.com/aschmitz/spinner
  exit
cd ~spinner/spinner/
sudo gem install bundler
bundle install
