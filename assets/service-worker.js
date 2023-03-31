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
  var json = event.data.json();
  event.waitUntil(
    self.registration.showNotification(json.title, {
      body: json.body,
      icon: json.icon
    })
  )
  console.log(event)
});