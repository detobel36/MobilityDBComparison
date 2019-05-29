var map = L.map('map').setView([0, -0], 13),
    realtime = L.realtime('https://wanderdrone.appspot.com/', {
        interval: 3 * 1000
    }).addTo(map);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    maxZoom: 18,
    id: 'mapbox.streets',
    accessToken: 'pk.eyJ1IjoiZGV0b2JlbDM2IiwiYSI6ImNqdXNwNzJvZDN6cmM0MW9heWlpOW9objAifQ.1R6UVQPsTY1Ac_TdqTYn3Q'
}).addTo(map);

realtime.on('update', function() {
    map.fitBounds(realtime.getBounds(), {maxZoom: 3});
});