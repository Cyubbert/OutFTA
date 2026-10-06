import { ref, computed } from 'vue'
import { lookupSong, parseYouTubeId } from '@/lib/songLookup'

// Song-field state shared by the diary entry forms. `form` is the form's
// reactive object; it must have song_url/song_title/song_artist/song_cover.
export function useSongForm(form) {
    const songLooking = ref(false)
    const songError = ref('')
    const hasSong = computed(() => !!form.song_url.trim())

    async function fetchSong() {
        songError.value = ''
        if (!parseYouTubeId(form.song_url)) {
            songError.value = "That doesn't look like a YouTube link."
            return
        }
        songLooking.value = true
        try {
            const song = await lookupSong(form.song_url)
            form.song_title = song.title
            form.song_artist = song.artist
            form.song_cover = song.cover
        } catch (e) {
            songError.value = e.message
        } finally {
            songLooking.value = false
        }
    }

    // Auto-fill when a link is pasted into an empty song.
    function onSongUrlChange() {
        if (hasSong.value && !form.song_title && !form.song_artist) fetchSong()
    }

    function clearSong() {
        form.song_url = ''
        form.song_title = ''
        form.song_artist = ''
        form.song_cover = ''
        songError.value = ''
    }

    // Columns to save; all null when there's no song.
    function songPayload() {
        const keep = (v) => hasSong.value ? v.trim() || null : null
        return {
            song_url: form.song_url.trim() || null,
            song_title: keep(form.song_title),
            song_artist: keep(form.song_artist),
            song_cover: keep(form.song_cover)
        }
    }

    return { songLooking, songError, hasSong, fetchSong, onSongUrlChange, clearSong, songPayload }
}

export function songFields(entry) {
    return {
        song_url: entry?.song_url ?? '',
        song_title: entry?.song_title ?? '',
        song_artist: entry?.song_artist ?? '',
        song_cover: entry?.song_cover ?? ''
    }
}
