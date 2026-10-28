// The YouTube IFrame API is a global script; load it once and share the promise.
let ytApiPromise = null

export function loadYouTubeApi() {
    if (window.YT?.Player) return Promise.resolve(window.YT)
    if (!ytApiPromise) {
        ytApiPromise = new Promise((resolve) => {
            const prev = window.onYouTubeIframeAPIReady
            window.onYouTubeIframeAPIReady = () => {
                prev?.()
                resolve(window.YT)
            }
            const s = document.createElement('script')
            s.src = 'https://www.youtube.com/iframe_api'
            document.head.appendChild(s)
        })
    }
    return ytApiPromise
}
