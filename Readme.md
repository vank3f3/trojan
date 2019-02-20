# trojan docker

An unidentifiable mechanism that helps you bypass GFW

# Usage
docker run -d --restart=unless-stopped -p 443:443 -v /path/to/conf:/app/conf --name trojan vank3f3/trojan:docker