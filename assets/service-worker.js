self.addEventListener('fetch', function (e) {
  console.log('service worker fetch')
})

self.addEventListener('install', function (e) {
  console.log('service worker install')
})

self.addEventListener('activate', function (e) {
  console.log('service worker activate')
})

self.addEventListener("push", (event) => {
  event.waitUntil(
    self.registration.showNotification("Push通知タイトル", {
      body: "Push通知本文"
    })
  )
  console.log(event)
});