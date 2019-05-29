function formatCoord(coord) {
    for (var i = 0; i < coord.length; ++i) {
        coord[i] = coord[i].split(' ')
    };
    return coord;
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
        fetch('./getDeviationData') // https://wanderdrone.appspot.com/
        .then(function(response) { 
            console.log("Reponse")
            console.log(response)
            return response.json(); 
        })
        .then(function(data) {
            console.log("data")
            console.log(data.length)


            var listPoints = [];
            for(var i = 0; i < data.length; ++i) {
                strTrip = data[i].busposition
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
                listPoints.push(infoObj)
            }


            // var listLine = [];
            // for(var i = 0; i < data.length; ++i) {
            //     strLineTrip = data[i].lineroad
            //     indexParenthese = strLineTrip.indexOf('(')
            //     strLineTrip = strLineTrip.substr(indexParenthese+1, strLineTrip.length-(indexParenthese+2))

            //     strBusTrip = data[i].busroad
            //     indexParenthese = strBusTrip.indexOf('(')
            //     strBusTrip = strBusTrip.substr(indexParenthese+1, strBusTrip.length-(indexParenthese+2))

            //     var busTripObj = {
            //         type: 'Feature',
            //         properties: {
            //             id: data[i].vehicle_id,
            //             description: data[i].route_id + " (" + data[i].direction_id + ")<br />" + data[i].shape_id,
            //             dataInfo: data[i]
            //         },
            //         geometry: {
            //             type: 'LineString',
            //             coordinates: formatCoord(strBusTrip.split(','))
            //         }
            //     }
            //     listLine.push(busTripObj)

            //     var lineTripObj = {
            //         type: 'Feature',
            //         properties: {
            //             id: data[i].shape_id,
            //             description: data[i].route_id + " (" + data[i].direction_id + ")",
            //             color: '#ff000c'
            //         },
            //         geometry: {
            //             type: 'LineString',
            //             coordinates: formatCoord(strLineTrip.split(','))
            //         }
            //     }
            //     listLine.push(lineTripObj)

            // }

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
        style(geoJsonFeature) {
            if(geoJsonFeature.properties.color !== undefined) {
                return {color: geoJsonFeature.properties.color};
            } else {
                return {}
            }
        },
        onEachFeature(f, l) {
            l.bindPopup(function() {
                return '<h3>' + f.properties.id + '</h3>' +
                    '<p>' + f.properties.description + '</p>';
            });
        }
    }).addTo(map);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// realtime.on('update', function() {
//     map.fitBounds(realtime.getBounds(), {maxZoom: 3});
// });
