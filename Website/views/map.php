<?php
// view
?>

<div class="album py-5 bg-light">
    <div class="container">
        <h1>Carte</h1>
        <hr>
        <br>
        <h4>Affichage des bus sur la carte</h4>
        <p>
            Position des bus (en fonction des données présente dans la base de donnée).  
            <!--Rendez-vous <a href="<?php // echo base_url('position'); ?>">ici</a> pour mettre à jour les positions.-->
        </p>

        <?php
        // foreach ($busTrip as $busInfo) {
        //     $first = TRUE;
        //     echo 'var feature = new OpenLayers.Feature.Vector(';
        //     echo 'new OpenLayers.Geometry.LineString([';
        //     foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
        //         if(count($coord) >= 2) {
        //             if(!$first) {
        //                 echo ",\n";
        //             }
        //             $first = FALSE;
        //             echo 'new OpenLayers.Geometry.Point(' . $coord[0] . ', ' . $coord[1] . ').transform(epsg4326, projectTo)';
        //         }
        //     }
        //     echo '])';
        //     echo ",\n{description: '" . $busInfo['vehicle_id'] . " (" . $busInfo['trip_id'] . ")'}";
        //     echo ');';
        //     echo 'vectorLayer.addFeatures(feature);';
        // }
        ?>

        <center>
            <div class="btn btn-primary text-center" onClick="map.setCenter(lonLat, zoom);">Centrer la carte</div><br />
            <br />
        </center>

        <div id="mapdiv" style="width: 100%; height: 600px;"></div>

    </div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/openlayers/2.11/lib/OpenLayers.js"></script> 
<script>
    map = new OpenLayers.Map("mapdiv");
    map.addLayer(new OpenLayers.Layer.OSM("CartoDB positron (no labels)",                                                   
                                           ["http://a.basemaps.cartocdn.com/light_nolabels/${z}/${x}/${y}.png",
                                            "http://b.basemaps.cartocdn.com/light_nolabels/${z}/${x}/${y}.png",
                                            "http://c.basemaps.cartocdn.com/light_nolabels/${z}/${x}/${y}.png",
                                            "http://d.basemaps.cartocdn.com/light_nolabels/${z}/${x}/${y}.png"],
                                            {attribution: "&copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors, &copy; <a href='http://cartodb.com/attributions'>CartoDB</a>" })
        );
    map.addLayer(new OpenLayers.Layer.OSM());

    epsg4326 =  new OpenLayers.Projection("EPSG:4326"); //WGS 1984 projection
    projectTo = map.getProjectionObject(); //The map projection (Spherical Mercator)

    var lonLat = new OpenLayers.LonLat(-73.98, 40.75).transform(epsg4326, projectTo);
    
    // Exemple https://harrywood.co.uk/maps/examples/
    var zoom=12;
    map.setCenter(lonLat, zoom);


    var style = new OpenLayers.StyleMap({
        'strokeColor':"#808080",
        'strokeWidth': 1.5
    });

    var styleTrip = new OpenLayers.StyleMap({
        'strokeColor':"#4d5bff",
        'strokeWidth': 1.5
    });

    var styleFix = new OpenLayers.StyleMap({
        'fillColor':"#ff0000",
        'strokeColor':"#ff0000",
        'strokeOpacity': .8,
        'strokeWidth': 1,
        'fillOpacity': .3,
        'pointRadius': 6
    });

    var styleFix5 = new OpenLayers.StyleMap({
        'fillColor':"#008000",
        'strokeColor':"#008000",
        'strokeOpacity': .8,
        'strokeWidth': 1,
        'fillOpacity': .3,
        'pointRadius': 6
    });

    var styleFix10 = new OpenLayers.StyleMap({
        'fillColor':"#ff00eb",
        'strokeColor':"#ff00eb",
        'strokeOpacity': .8,
        'strokeWidth': 1,
        'fillOpacity': .3,
        'pointRadius': 6
    });

    var styleFix15 = new OpenLayers.StyleMap({
        'fillColor':"#0095fe",
        'strokeColor':"#0095fe",
        'strokeOpacity': .8,
        'strokeWidth': 1,
        'fillOpacity': .3,
        'pointRadius': 6
    });

    function addHover(map, vectorName) {
        var controls = {
                selector: new OpenLayers.Control.SelectFeature(vectorName, { onSelect: createPopup, onUnselect: destroyPopup })
            };
        map.addControl(controls['selector']);
        controls['selector'].activate();
    }


    <?php 

    if(isset($busPosition)){
        echo 'var vectorLayer = new OpenLayers.Layer.Vector("Bus position");';
        echo 'var vectorLayerFix = new OpenLayers.Layer.Vector("Bus position fixed", {styleMap: styleFix});';

        foreach ($busPosition as $busInfo) {
            echo 'var feature = new OpenLayers.Feature.Vector(';
                echo 'new OpenLayers.Geometry.Point('. $busInfo['longitude'] . ', ' . $busInfo['latitude'] . ').transform(epsg4326, projectTo), ';
                echo '{description: \'Date: ' . $busInfo['moment'] . '<br />VehicleID' . $busInfo['vehicle_id'] .'\'}';
            echo ');';
            echo 'vectorLayer.addFeatures(feature);';

            echo 'var featureFix = new OpenLayers.Feature.Vector(';
                echo 'new OpenLayers.Geometry.Point('. $busInfo['fix_position_longitude'] . ', ' . $busInfo['fix_position_latitude'] . ').transform(epsg4326, projectTo), ';
                echo '{description: \'Date: ' . $busInfo['moment'] . '<br />VehicleID' . $busInfo['vehicle_id'] .'\'}';
            echo ');';
            echo 'vectorLayerFix.addFeatures(featureFix);';
        }

        echo 'map.addLayer(vectorLayer);';
        echo 'map.addLayer(vectorLayerFix);';
    }

    if(isset($busTrip)){

        foreach ($busTrip as $busInfo) {
            echo 'var vectorLayer = new OpenLayers.Layer.Vector("' . $busInfo['vehicle_id'] . ' (' . $busInfo['trip_id'] . ')",';
            echo ' {styleMap: styleTrip});';
            $first = TRUE;
            echo 'var feature = new OpenLayers.Feature.Vector(';
            echo 'new OpenLayers.Geometry.LineString([';
            foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
                if(count($coord) >= 2) {
                    if(!$first) {
                        echo ",\n";
                    }
                    $first = FALSE;
                    echo 'new OpenLayers.Geometry.Point(' . $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo)';
                }
            }
            echo '])';
            echo ",\n{description: '" . $busInfo['vehicle_id'] . " (" . $busInfo['trip_id'] . ")'}";
            echo ');';
            echo 'vectorLayer.addFeatures(feature);';
            echo 'map.addLayer(vectorLayer);';
        }

        echo 'var vectorLayer = new OpenLayers.Layer.Vector("All Bus position");';
        foreach ($busTrip as $busInfo) {
            foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
                if(count($coord) >= 2) {
                    echo 'var featureFix = new OpenLayers.Feature.Vector(';
                                echo 'new OpenLayers.Geometry.Point('. $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo), ';
                                echo '{description: \'<b>Position</b><br />Date: ' . $busInfo['start_date'] . '<br />VehicleID: ' . $busInfo['vehicle_id'] .'\'}';
                            echo ');';
                    echo 'vectorLayer.addFeatures(featureFix);';
                }
            }
        }
        echo 'map.addLayer(vectorLayer);';
        echo "addHover(map, vectorLayer);";


        echo 'var vectorLayerFix = new OpenLayers.Layer.Vector("Bus position Clean 5m", {styleMap: styleFix5});';
        foreach ($busTripClean5 as $busInfo) {
            foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
                if(count($coord) >= 2) {
                    echo 'var featureFix = new OpenLayers.Feature.Vector(';
                                echo 'new OpenLayers.Geometry.Point('. $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo), ';
                                echo '{description: \'<b>5m</b><br />Date: ' . $busInfo['start_date'] . '<br />VehicleID: ' . $busInfo['vehicle_id'] .'\'}';
                            echo ');';
                    echo 'vectorLayerFix.addFeatures(featureFix);';
                }
            }
        }
        echo 'map.addLayer(vectorLayerFix);';
        echo "addHover(map, vectorLayerFix);";


        echo 'var vectorLayerFix = new OpenLayers.Layer.Vector("Bus position Clean 10m", {styleMap: styleFix10});';
        foreach ($busTripClean10 as $busInfo) {
            foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
                if(count($coord) >= 2) {
                    echo 'var featureFix = new OpenLayers.Feature.Vector(';
                                echo 'new OpenLayers.Geometry.Point('. $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo), ';
                                echo '{description: \'<b>10m</b><br />Date: ' . $busInfo['start_date'] . '<br />VehicleID: ' . $busInfo['vehicle_id'] .'\'}';
                            echo ');';
                    echo 'vectorLayerFix.addFeatures(featureFix);';
                }
            }
        }
        echo 'map.addLayer(vectorLayerFix);';
        echo "addHover(map, vectorLayerFix);";


        echo 'var vectorLayerFix = new OpenLayers.Layer.Vector("Bus position Clean 15m", {styleMap: styleFix15});';
        foreach ($busTripClean15 as $busInfo) {
            foreach (json_decode($busInfo['tripjson'])->coordinates as $coord) {
                if(count($coord) >= 2) {
                    echo 'var featureFix = new OpenLayers.Feature.Vector(';
                                echo 'new OpenLayers.Geometry.Point('. $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo), ';
                                echo '{description: \'<b>15m</b><br />Date: ' . $busInfo['start_date'] . '<br />VehicleID: ' . $busInfo['vehicle_id'] .'\'}';
                            echo ');';
                    echo 'vectorLayerFix.addFeatures(featureFix);';
                }
            }
        }
        echo 'map.addLayer(vectorLayerFix);';

        echo "addHover(map, vectorLayerFix);";
    }

    foreach ($allBusRoute as $ligne) {
        if(in_array($ligne['route_id'], $ligneBus)) {
            echo 'var vectorLayer = new OpenLayers.Layer.Vector("' . $ligne['route_id'] . ' (' . $ligne['direction_'] . ')",';
                echo ' {styleMap: style});';
                $first = TRUE;
                foreach (json_decode($ligne['route'])->geometries as $value) {
                    echo 'var feature = new OpenLayers.Feature.Vector(';
                        echo 'new OpenLayers.Geometry.LineString([';
                        foreach ($value->coordinates as $coord) {
                            foreach ($coord as $valCoord) {
                                if(!$first) {
                                    echo ",\n";
                                }
                                $first = FALSE;
                                echo 'new OpenLayers.Geometry.Point(' . $valCoord[0] . ', ' . $valCoord[1] . ').transform(epsg4326, projectTo)';
                            }
                        }
                        echo '])';
                        echo ",\n{description: '" . $ligne['route_id'] . " (" . $ligne['direction_'] . ")'}";
                    echo ');';
                    echo 'vectorLayer.addFeatures(feature);';
                }
                // foreach (json_decode($ligne['route'])->coordinates as $value) {
                //     if(!$first) {
                //         echo ",\n";
                //     }
                //     $first = FALSE;
                //     echo 'new OpenLayers.Geometry.Point(' . $value[0] . ', ' . $value[1] . ').transform(epsg4326, projectTo)';
                // }
                echo 'vectorLayer.setVisibility(false);';
            echo 'map.addLayer(vectorLayer);';
        }
    }

    ?>

    //Add a selector control to the vectorLayer with popup functions
    var controls = {
        selector: new OpenLayers.Control.SelectFeature(vectorLayer, { onSelect: createPopup, onUnselect: destroyPopup })
    };

    function createPopup(feature) {
        feature.popup = new OpenLayers.Popup.FramedCloud("pop",
            feature.geometry.getBounds().getCenterLonLat(),
            null,
            '<div class="markerContent">'+feature.attributes.description+'</div>',
            null,
            true,
            function() { controls['selector'].unselectAll(); }
        );
        //feature.popup.closeOnMove = true;
        map.addPopup(feature.popup);
    }

    function destroyPopup(feature) {
        feature.popup.destroy();
        feature.popup = null;
    }

    map.addControl(new OpenLayers.Control.LayerSwitcher());
    
    map.addControl(controls['selector']);
    controls['selector'].activate();



    // var feature = new OpenLayers.Feature.Vector(
    //         new OpenLayers.Geometry.Point(0, 0).transform(epsg4326, projectTo), 
    //         {description: 'ceci est un test'},
    //         {externalGraphic: '<?php echo url_image("bus.png"); ?>', graphicHeight: 25, graphicWidth: 21, graphicXOffset:-12, graphicYOffset:-25}
    //     );
    // vectorLayer.addFeatures(feature);

    // var feature = new OpenLayers.Feature.Vector(
    //         new OpenLayers.Geometry.Point(10, 10).transform(epsg4326, projectTo), 
    //         {description: 'ceci est un test'}
    //     );
    // vectorLayer.addFeatures(feature);

    // var feature = new OpenLayers.Feature.Vector(
    //         new OpenLayers.Geometry.LineString([
    //                 new OpenLayers.Geometry.Point(-74.0090484899999,40.7259834110001).transform(epsg4326, projectTo),
    //                 new OpenLayers.Geometry.Point(-74.008348558,40.725914022).transform(epsg4326, projectTo),
    //                 new OpenLayers.Geometry.Point(0,0).transform(epsg4326, projectTo)
    //             ]), 
    //         {description: 'ceci est un test'},
    //         {style: new OpenLayers.Style({
    //                     strokeColor: '#f80000',
    //                     strokeWidth: 10
    //                 })}
    //     );
    // vectorLayer.addFeatures(feature);
    
  
</script>
    
