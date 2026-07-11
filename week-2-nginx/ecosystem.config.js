// PM2 process file for the NGINX demo.
// Start everything:   pm2 start ecosystem.config.js
// See them:           pm2 list        |   pm2 logs
// Stop & remove:      pm2 delete all
//
// - backend (3000)            -> reverse-proxy demo
// - web-1/2/3 (3001-3003)     -> load-balancing demo (each a different colour)
// - api (4000)                -> "location /api/" routing demo

module.exports = {
  apps: [
    { name: 'backend', script: 'app.js', env: { PORT: 3000, NAME: 'Backend', COLOR: '#2563eb' } },
    { name: 'web-1', script: 'app.js', env: { PORT: 3001, NAME: 'Server 1', COLOR: '#16a34a' } },
    { name: 'web-2', script: 'app.js', env: { PORT: 3002, NAME: 'Server 2', COLOR: '#9333ea' } },
    { name: 'web-3', script: 'app.js', env: { PORT: 3003, NAME: 'Server 3', COLOR: '#ea580c' } },
    { name: 'api', script: 'api.js', env: { PORT: 4000 } },
  ],
}
