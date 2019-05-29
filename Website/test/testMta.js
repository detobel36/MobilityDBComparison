// var listPoints = new Map();

// listPoints.set(1, "test");
// has

Date.prototype.addHours= function(h){
    this.setHours(this.getHours()+h);
    return this;
}

var map = L.map('map').setView([40.6976633,-74], 12),
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
                strTrip = data[i].lastpos
                strTrip = strTrip.substr(6, strTrip.length-7)

                var infoObj = {
                    "type": "Feature", 
                    "properties": {
                        id: data[i].vehicle_id,
                        dataInfo: data[i]
                    },
                    "geometry": {
                        "type": "Point", 
                        "coordinates": strTrip.split(' ')
                    } 
                }

                // var infoObj = {
                //     type: 'Feature',
                //     properties: {
                //         id: data[i].vehicle_id,
                //         speed: data[i].speed_avg
                //     },
                //     geometry: {
                //         type: 'LineString',
                //         coordinates: tripCoord
                //     }
                // }
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
        interval: 30000,
        removeMissing: true,
        onEachFeature(f, l) {
            l.bindPopup(function() {
                return '<h3>' + f.properties.id + '</h3>' +
                    '<p>'+
                    'Last update: <strong>' + new Date(f.properties.dataInfo.last_update).addHours(2).toLocaleString('be-BE') + '</strong><br />' +
                    'Route: <strong>' + f.properties.dataInfo.route_id + ' (' + f.properties.dataInfo.direction_id + ')</strong><br />' +
                    'Average Speed: <strong>' + f.properties.dataInfo.speed_avg + '</strong><br />' +
                    'Time spend: <strong>' + f.properties.dataInfo.since_start + '</strong><br />' +
                    'Total Distance: <strong>' + f.properties.dataInfo.distance + '</strong>' +
                    '</p>';
            });
        }
    }).addTo(map);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// realtime.on('update', function() {
//     map.fitBounds(realtime.getBounds(), {maxZoom: 3});
// });