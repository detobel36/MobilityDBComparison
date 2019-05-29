// var listPoints = new Map();

// listPoints.set(1, "test");
// has

var map = L.map('map').setView([0, -0], 1),
    trail = {
        type: 'Feature',
        properties: {
            id: 1
        },
        geometry: {
            type: 'LineString',
            coordinates: []
        }
    },
    realtime = L.realtime(function(success, error) {
        fetch('./getData.php') // https://wanderdrone.appspot.com/
        .then(function(response) { 
            console.log("Reponse")
            console.log(response)
            return response.json(); 
        })
        .then(function(data) {
            console.log("data")
            // console.log(data.length)

            var listPoints = [];
            for(var i = 0; i < data.length; ++i) {
                strTrip = data[i].traj_trip
                startParenthese = strTrip.indexOf('(')
                tripCoord = strTrip.substr(startParenthese+1, strTrip.lastIndexOf(')')-startParenthese-1)
                tripCoord = tripCoord.split(',')

                for(var j = 0; j < tripCoord.length; ++j) {
                    tripCoord[j] = tripCoord[j].split(' ')
                }

                var infoObj = {
                    type: 'Feature',
                    properties: {
                        id: data[i].vehicle_id,
                        speed: data[i].speed_avg
                    },
                    geometry: {
                        type: 'LineString',
                        coordinates: tripCoord
                    }
                }
                listPoints.push(infoObj)

            }

            // var trailCoords = trail.geometry.coordinates;
            // trailCoords.push(data.geometry.coordinates);
            // trailCoords.splice(0, Math.max(0, trailCoords.length - 5));
            // console.log("Tail actuel:")
            // console.log(trail)
            // console.log("")
            // trail.properties.id = (trail.properties.id+1)

            success({
                type: 'FeatureCollection',
                features: listPoints
            });
        })
        .catch(error);
    }, {
        interval: 30000
    }).addTo(map);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// realtime.on('update', function() {
//     map.fitBounds(realtime.getBounds(), {maxZoom: 3});
// });