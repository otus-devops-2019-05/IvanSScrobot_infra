[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/ivan/reddit
Environment=DATABASE_URL=${database_url}
ExecStart=/bin/bash -lc 'puma'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

