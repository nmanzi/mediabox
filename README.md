# Shared Media Server Stack

This Docker Compose file sets up a stack of software for managing a shared media server. The stack includes the following services:

- SABnzbd: A Usenet downloader
- Radarr: A movie collection manager
- Sonarr: A TV show collection manager
- Prowlarr: An indexer manager
- Transmission-OpenVPN: A [BitTorrent client with OpenVPN](https://haugene.github.io/docker-transmission-openvpn/)
- Overseerr: A request management and media discovery tool
- Nginx Proxy Manager: A reverse proxy and SSL termination service
- Tautulli: A Plex media server monitoring and analytics tool

## Prerequisites

- Docker and Docker Compose installed on your system
- A NordVPN account with a valid username and password
- Plex media server installed on a separate host (optional)

## Installation

1. Clone or download this repository.
2. Update the volume paths in the `docker-compose.yml` file to match your desired directory structure.
3. Update the `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` environment variables in the `transmission` service with your NordVPN credentials. Alternatively [adjust the config](https://haugene.github.io/docker-transmission-openvpn/supported-providers/) for your VPN service as desired.
4. Run `docker-compose up -d` to start the stack.

## Configuration

Each service has its own configuration directory mounted as a volume. You can access the web interface of each service using the following ports:

- SABnzbd: `http://localhost:8080`
- Radarr: `http://localhost:7878`
- Sonarr: `http://localhost:8989`
- Prowlarr: `http://localhost:9696`
- Transmission: `http://localhost:9091`
- Overseerr: `http://localhost:5055`
- Nginx Proxy Manager: `http://localhost:81`
- Tautulli: `http://localhost:8181`

You can configure each service using its respective web interface.

## Usage

To download and manage your media, you can use the following workflow:

1. Add your Usenet or BitTorrent indexers to Prowlarr.
2. Configure Radarr and Sonarr to use Prowlarr as their indexer.
3. Add your movies and TV shows to Radarr and Sonarr, respectively.
4. Radarr and Sonarr will automatically search for and download your media using SABnzbd or Transmission.
5. Use Overseerr to manage user requests and discover new media.
6. Use Tautulli to monitor and analyze your Plex media server usage.
7. Use Nginx Proxy Manager to expose Overseerr and Tautulli if desired.

## Notes

- This stack does not include Plex, which can be installed on a separate host if desired. You can share your media library with Plex using NFS or a similar protocol.
- The Transmission service is configured to use NordVPN for secure and private downloading. Make sure to update the `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` environment variables with your own credentials.
- The Nginx Proxy Manager service is included for easy reverse proxying and SSL termination. You can use it to access your services securely over HTTPS.