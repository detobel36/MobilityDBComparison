function formatCoord(coord) {
    for (var i = 0; i < coord.length; ++i) {
        coord[i] = coord[i].split(' ')
    };
    return coord;
}

function getColor(d) {
    return d > 0.9 ? '#800026' :
           d > 0.8  ? '#BD0026' :
           d > 0.7  ? '#E31A1C' :
           d > 0.6  ? '#FC4E2A' :
           d > 0.5   ? '#FD8D3C' :
           d > 0.4   ? '#FEB24C' :
           d > 0.3   ? '#FED976' :
           d > 0.2   ? '#FFEDA0' :
           d > 0.1   ? '#fff4c3' :
                      '#f4eed3';
}

function highlightFeature(e) {
    var layer = e.target;

    layer.setStyle({
        weight: 5,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.7
    });

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        layer.bringToFront();
    }
    info.update(layer.feature.properties)
}

function resetHighlight(e) {
    e.target.setStyle({
        weight: 2,
        color: 'white',
        dashArray: '3'
    });
    info.update()
}

function zoomToFeature(e) {
    map.fitBounds(e.target.getBounds());
}

function defineStyle(feature) {
    return {
        fillColor: getColor(feature.properties.ratio),
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7
    };
}


var map = L.map('map').setView([40.6976633,-74], 12),
    realtime = L.realtime(function(success, error) {
        fetch('./getCountyData') // https://wanderdrone.appspot.com/
        .then(function(response) { 
            console.log("Reponse")
            console.log(response)
            return response.json(); 
        })
        .then(function(data) {
            console.log("data")

            var maxTimeSpent = 0;
            var listCounty = [];
            for(var i = 0; i < data.length; ++i) {
                var json = JSON.parse(data[i].geom);
                
                var timespent = parseInt(data[i].timespend);
                if(timespent > maxTimeSpent) {
                    maxTimeSpent = timespent;
                }

                var countyObj = {
                    "type": "Feature", 
                    "properties": {
                        id: data[i].gid,
                        description: "State: " + data[i].name_0 + "<br />County: " + data[i].name_1 + "<br />Time spent: " + (parseInt(timespent)/60000).toFixed(1) + " min",
                        "timespent": timespent,
                        ratio: 0
                    },
                    "geometry": {
                        "type": "MultiPolygon", 
                        "coordinates": json.coordinates
                    } 
                }
                // console.log(countyObj)
                listCounty.push(countyObj)
            }

            for(var i = 0; i < listCounty.length; ++i) {
                listCounty[i].properties.ratio = parseInt(listCounty[i].properties.timespent)/maxTimeSpent;
            }

            success({
                type: 'FeatureCollection',
                features: listCounty
            });
        })
        .catch(error);
    }, {
        interval: 30000,
        removeMissing: true,
        style: defineStyle,
        onEachFeature(f, l) {
            l.bindPopup(function() {
                return '<h3>' + f.properties.id + '</h3>' +
                    '<p>' + f.properties.description + '</p>';
            });
            l.on({
                mouseover: highlightFeature,
                mouseout: resetHighlight,
                click: zoomToFeature
            });
        }
    }).addTo(map);

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

var info = L.control();

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info'); // create a div with a class "info"
    this.update();
    return this._div;
};

// method that we will use to update the control based on feature properties passed
info.update = function (props) {
    this._div.innerHTML = '<h4>Time spent by county</h4>' + 
                                (props ? props.description : 'Hover over a state');
};

info.addTo(map);

// realtime.on('update', function() {
//     map.fitBounds(realtime.getBounds(), {maxZoom: 3});
// });
