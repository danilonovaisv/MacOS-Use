// extract-video-url.js
const { fetch } = require('node-fetch'); // Instale: npm install node-fetch

(async () => {
    const url = process.argv[2];
    if (!url) {
        console.error("Usage: node extract-video-url.js <URL>");
        process.exit(1);
    }

    try {
        const res = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const html = await res.text();

        // Regex robusto para <source src="..."> dentro de <video>
        const sourceRegex = /<video[^>]*>[\s\S]*?<source\s+src\s*=\s*["']([^"']+)["'][^>]*>/i;
        const videoSrcRegex = /<video\s+src\s*=\s*["']([^"']+)["'][^>]*>/i;

        let match = sourceRegex.exec(html) || videoSrcRegex.exec(html);
        if (match) {
            const rawUrl = match[1];
            // Resolve URL relativa
            const absoluteUrl = new URL(rawUrl, url).href;
            console.log(absoluteUrl); // Saída limpa para o Shortcuts capturar
        } else {
            console.error("Nenhuma URL de vídeo encontrada.");
            process.exit(2);
        }
    } catch (e) {
        console.error("Erro:", e.message);
        process.exit(1);
    }
})();