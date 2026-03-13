const SMTPServer = require('smtp-server').SMTPServer; 
const simpleParser = require('mailparser').simpleParser; 
 
const WORKER_URL = process.env.WORKER_URL || 'https://mail-relay.wmobilas.workers.dev'; 
const API_SECRET = process.env.API_SECRET || 'your-super-secret-key-123'; 
 
const server = new SMTPServer({ 
  disableReverseLookup: true, 
  allowInsecureAuth: true, 
  auth: { 
    // No auth required, accept any credentials 
    verify: (session, username, password, callback) => { 
      callback(null, true); 
    } 
  }, 
  onConnect: (session, callback) => { 
    console.log(`[SMTP] Connection from ${session.remoteAddress}`); 
    callback(); 
  }, 
  onMailFrom: (address, session, callback) => { 
    console.log(`[SMTP] Mail from: ${address.address}`); 
    callback(); 
  }, 
  onRcptTo: (address, session, callback) => { 
    console.log(`[SMTP] Rcpt to: ${address.address}`); 
    callback(); 
  }, 
  onData: async (stream, session, callback) => { 
    try { 
      console.log('[SMTP] Processing email...'); 
       
      const parsed = await simpleParser(stream); 
       
      const emailData = { 
        to: parsed.to.text.split('@')[0] ? parsed.to.text : parsed.to.text, 
        toName: parsed.to.text.match(/"([^"]+)"/)?.[1] || '', 
        from: parsed.from.text.match(/<(.+?)>/)?.[1] || parsed.from.text, 
        fromName: parsed.from.text.match(/^(.+?)</)?.[1]?.trim() || 'Listmonk', 
        subject: parsed.subject || '(no subject)', 
        text: parsed.text || '', 
        html: parsed.html || parsed.text || '' 
      }; 
 
      console.log(`[RELAY] Sending to ${emailData.to}`); 
 
      const response = await fetch(WORKER_URL, { 
        method: 'POST', 
        headers: { 
          'Content-Type': 'application/json', 
          'Authorization': `Bearer ${API_SECRET}` 
        }, 
        body: JSON.stringify(emailData) 
      }); 
 
      const result = await response.text(); 
       
      if (response.ok) { 
        console.log(`[RELAY] ✓ Email sent successfully`); 
        callback(); 
      } else { 
        console.error(`[RELAY] ✗ Failed: ${result}`); 
        callback(new Error(`Worker error: ${result}`)); 
      } 
    } catch (err) { 
      console.error('[SMTP] Error processing email:', err); 
      callback(err); 
    } 
  } 
}); 
 
server.listen(2525, '127.0.0.1', () => { 
  console.log('[SMTP] Bridge listening on localhost:2525'); 
  console.log(`[CONFIG] Worker URL: ${WORKER_URL}`); 
  console.log('[READY] Waiting for Listmonk connections...'); 
}); 
 
server.on('error', (err) => { 
  console.error('[SMTP] Server error:', err); 
}); 
