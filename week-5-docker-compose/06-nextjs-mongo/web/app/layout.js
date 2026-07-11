export const metadata = {
  title: 'Next.js + MongoDB',
  description: 'A tiny Next.js app with an integrated server and a database.',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'system-ui, sans-serif', background: '#f9fafb' }}>
        {children}
      </body>
    </html>
  )
}
