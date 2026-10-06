// Turns a YouTube link into song metadata (title, artist, album cover).
// YouTube's oEmbed endpoint gives the video title + channel name; those are
// then matched against the iTunes Search API to get the real track name,
// artist, and album artwork. Both endpoints are keyless and CORS-enabled.

export function parseYouTubeId(url) {
    if (!url) return null
    try {
        const u = new URL(url.trim())
        const host = u.hostname.replace(/^www\.|^m\.|^music\./, '')
        if (host === 'youtu.be') return u.pathname.slice(1).split('/')[0] || null
        if (host === 'youtube.com' || host === 'youtube-nocookie.com') {
            if (u.searchParams.get('v')) return u.searchParams.get('v')
            const m = u.pathname.match(/^\/(?:embed|shorts|live|v)\/([\w-]{6,})/)
            if (m) return m[1]
        }
    } catch {
        // not a URL
    }
    return null
}

// Strips the usual YouTube noise: "(Official Video)", "[4K Remaster]", "| Lyrics", etc.
function cleanTitle(title) {
    return title
        .replace(/\s*[([][^)\]]*(official|video|audio|lyric|visuali[sz]er|remaster|hd|4k|mv|live)[^)\]]*[)\]]/gi, '')
        .replace(/\s*\|.*$/, '')
        .replace(/\s+(ft\.?|feat\.?)\s.*$/i, '')
        .trim()
}

function cleanChannel(name) {
    return name.replace(/\s*-\s*Topic$/i, '').replace(/VEVO$/i, '').trim()
}

async function searchItunes(term) {
    const res = await fetch(`https://itunes.apple.com/search?entity=song&limit=1&term=${encodeURIComponent(term)}`)
    if (!res.ok) return null
    const data = await res.json()
    return data.results?.[0] ?? null
}

export async function lookupSong(url) {
    const id = parseYouTubeId(url)
    if (!id) throw new Error("That doesn't look like a YouTube link.")

    const res = await fetch(`https://www.youtube.com/oembed?format=json&url=${encodeURIComponent(`https://www.youtube.com/watch?v=${id}`)}`)
    if (!res.ok) throw new Error("Couldn't find that video — is it private or removed?")
    const video = await res.json()

    // "Artist - Track" is the most common upload format; otherwise fall back
    // to the channel name as the artist.
    const cleaned = cleanTitle(video.title)
    const dash = cleaned.split(/\s+[-–—]\s+/)
    let artist = dash.length > 1 ? dash[0] : cleanChannel(video.author_name)
    let title = dash.length > 1 ? dash.slice(1).join(' - ') : cleaned
    let cover = `https://i.ytimg.com/vi/${id}/hqdefault.jpg`

    try {
        const track = await searchItunes(`${artist} ${title}`)
        if (track) {
            title = track.trackName
            artist = track.artistName
            if (track.artworkUrl100) cover = track.artworkUrl100.replace('100x100bb', '600x600bb')
        }
    } catch {
        // iTunes is a nice-to-have; keep the YouTube-derived values
    }

    return { title, artist, cover }
}
