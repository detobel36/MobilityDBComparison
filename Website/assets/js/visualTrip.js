Date.prototype.addHours= function(h){
    this.setHours(this.getHours()+h);
    return this;
}

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
        fetch('./getTripData') // https://wanderdrone.appspot.com/
        .then(function(response) { 
            console.log("Reponse")
            console.log(response)
            return response.json(); 
        })
        .then(function(data) {
            console.log("data")
            console.log(data)
            // console.log(data.length)

            var listLine = [];
            for(var i = 0; i < data.length; ++i) {
                strBusTrip = data[i].trip
                indexParenthese = strBusTrip.indexOf('(')
                strBusTrip = strBusTrip.substr(indexParenthese+1, strBusTrip.length-(indexParenthese+2))

                var busTripObj = {
                    type: 'Feature',
                    properties: {
                        id: data[i].vehicle_id,
                        dataInfo: data[i]
                    },
                    geometry: {
                        type: 'LineString',
                        coordinates: formatCoord(strBusTrip.split(','))
                    }
                }
                listLine.push(busTripObj)

            }
            success({
                type: 'FeatureCollection',
                features: listLine
            });
        })
        .catch(error);
    }, {
        interval: 5000,
        removeMissing: true 
    }).addTo(map);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// realtime.on('update', function() {
//     map.fitBounds(realtime.getBounds(), {maxZoom: 3});
// });
