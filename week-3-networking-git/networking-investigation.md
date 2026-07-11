# Networking investigation lab (Week 3)

Practice the networking tools from the Networking sessions on your own machine.
No setup needed — just run the commands and read the output.

## DNS — names to IPs
```bash
nslookup github.com          # resolve a domain to its IP
dig +short github.com        # just the A record(s)
dig +short www.google.com    # note the CNAME chain
```

## Reachability & path
```bash
ping -c 3 github.com         # is it up? round-trip latency
traceroute github.com        # every hop between you and the host
```

## HTTP with curl
```bash
curl -I https://github.com               # headers + status code only
curl -s https://api.github.com | head    # a JSON API response
curl -s -o /dev/null -w "%{http_code}\n" https://github.com   # just the status
```

## Ports & connections
```bash
ss -tulpn                    # what is listening, and which process owns it
ss -tan | head               # active TCP connections
```

## Challenges
1. Resolve three websites and note their IPs. Do any share an IP (shared hosting/CDN)?
2. Run `curl -I` on a site — what status code and `server:` header come back?
3. Start something on a port (`python3 -m http.server 8000`) and find it with `ss -tulpn`.
4. Write the CIDR ranges for a VPC `10.0.0.0/16` split into two `/24` subnets.

## Reference — where these fit
- `nslookup` / `dig` → DNS (name → IP)
- `ping` / `traceroute` → reachability and routing
- `curl` → HTTP/HTTPS requests and status codes
- `ss` → ports and which service listens on them
