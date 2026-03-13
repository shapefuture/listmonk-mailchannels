export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const authHeader = request.headers.get('Authorization');
    const API_SECRET = env.API_SECRET || 'your-super-secret-key-123';
    
    if (!authHeader || authHeader !== `Bearer ${API_SECRET}`) {
      return new Response('Unauthorized', { status: 401 });
    }

    try {
      const emailData = await request.json();

      const mailChannelsBody = {
        personalizations: [
          {
            to: [{ 
              email: emailData.to, 
              name: emailData.toName || '' 
            }],
          },
        ],
        from: { 
          email: emailData.from, 
          name: emailData.fromName || 'Listmonk' 
        },
        subject: emailData.subject,
        content: [
          {
            type: 'text/plain',
            value: emailData.text,
          },
          {
            type: 'text/html',
            value: emailData.html || emailData.text,
          },
        ],
      };

      const response = await fetch('https://api.mailchannels.net/tx/v1/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(mailChannelsBody),
      });

      const result = await response.text();
      return new Response(result, {
        status: response.status,
        headers: { 'Content-Type': 'text/plain' },
      });
    } catch (err) {
      return new Response(`Error: ${err.message}`, { status: 500 });
    }
  },
};
