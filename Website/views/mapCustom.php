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

        <hr/>
        <p>
            Vous pouvez personnaliser les requêtes faites par cette page. Il est possible d'afficher des lignes ou des points. L'affichage va dépendre du nom de la colonne retourné. La colonne <code>json_point</code> permet d'afficher des points et <code>json_line</code> permet d'afficher des lignes.<br />
            Vous pouvez également donner une description des points/lignes en ajoutant une colonne <code>description</code>.<br />
            Cette page permet également d'afficher n'importe que tracé de bus habituel. Tous les résultats stocké dans la colonne <code>bus_line</code> pourront être affiché (il est donc possible de l'associé avec une ou plusieurs requête(s) existante mais également faire une requête spécialement pour sélectionner les lignes à afficher).
        </p>
        <form action="" method="post" id="formRequest">
            <div class="listRequest">
            <?php 
            $compteur = 1;
            if(!empty($allRequest)) {
                foreach ($allRequest as $request) {
                    echo '<div class="form-group divRequest' . $compteur . '">';
                        echo '<label for="request' . $compteur . '">Requête</label> ';
                        echo '<input type="color" value="' . $request['color'] . '" style="margin-left: 5px;" name="reqColor' . $compteur . '">';
                        echo '<textarea class="form-control" id="request' . $compteur . '" name="request' . $compteur . '" rows="2">';
                        echo $request['query'];
                        echo '</textarea>';
                    echo '</div>';

                    $compteur += 1;
                }
            } else { ?>
                <div class="form-group divRequest1">
                    <label for="request1">Requête</label> <input type="color" style="margin-left: 5px;" name="reqColor1">
                    <textarea class="form-control" id="request1" name="request1" rows="2"></textarea>
                </div>
            <?php } ?>
            </div>
            <button type="button" class="btn btn-default" onClick="addForm()"> <span data-feather="plus-circle"></span> Ajouter</button>
            <button type="submit" class="btn btn-success">Envoyer</button>
        </form>

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
            <div class="btn btn-primary" onClick="map.setCenter(lonLat, zoom);">Centrer la carte</div><br />
            <br />
        </center>

        <div id="mapdiv" style="width: 100%; height: 600px;"></div>

        <h4>Liste des bus</h4>
        <table class="table table-hover table-bordered">
            <thead>
                <tr>
                  <th scope="col">ID</th>
                  <th scope="col">Route ID</th>
                  <th scope="col">Position</th>
                  <th scope="col">Distance</th>
                  <th scope="col">Dernière position</th>
                </tr>
            </thead>
            <tbody>
                <?php 
                if(isset($busPosition)) {
                    foreach ($busPosition as $bus) {
                        echo '<tr>';
                        echo '<td>' . $bus['vehicle_id'] . '</td>';
                        echo '<td>' . $bus['route_id'] . '</td>';
                        echo '<td>Long: ' . $bus['longitude'] . ', Lat: ' . $bus['latitude'] . '</td>';
                        echo '<td>' . $bus['fixed_distance'] . '</td>';
                        echo '<td>' . $bus['moment'] . '</td>';
                        echo '</tr>';
                    }
                } ?>
            </tbody>
        </table>
    </div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/openlayers/2.11/lib/OpenLayers.js"></script> 
<script>
var inputCounter = <?php echo $compteur-1; ?>;

function addForm() {
    var $newField = $('#formRequest .listRequest .divRequest' + inputCounter).clone();
    $newField.removeClass('divRequest' + inputCounter);
    inputCounter += 1;
    $newField.addClass('divRequest' + inputCounter);
    $newField.find('label').attr('for', 'request' + inputCounter);
    var $input = $newField.find('input');
    $input.attr('name', 'reqColor' + inputCounter);
    $input.val('#000000');
    var $textarea = $newField.find('textarea');
    $textarea.attr('name', 'request' + inputCounter);
    $textarea.attr('id', 'request' + inputCounter);
    $textarea.val('');
    $('#formRequest .listRequest').append($newField);
}


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

    function addHover(map, vectorName) {
        var controls = {
                selector: new OpenLayers.Control.SelectFeature(vectorName, { onSelect: createPopup, onUnselect: destroyPopup })
            };
        map.addControl(controls['selector']);
        controls['selector'].activate();
    }


    var style = new OpenLayers.StyleMap({
        'strokeColor':"#808080",
        'strokeWidth': 1.5
    });

    <?php
    $compteur = 1;
    foreach ($allRequest as $request) {

        
        if(in_array('Line', $request['type'])) {
            echo 'var styleLineRequest' . $compteur . ' = new OpenLayers.StyleMap({
                    \'strokeColor\':"' . $request['color'] . '",
                    \'strokeWidth\': 1.5
                });';


            foreach ($request['result'] as $result) {
                echo 'var vectorLayer' . $compteur . ' = new OpenLayers.Layer.Vector("Trip req. ' . (isset($result['description']) ? $result['description'] : '?') . '", {styleMap: styleLineRequest' . $compteur . '});';
                $first = TRUE;

                echo 'var feature = new OpenLayers.Feature.Vector(';
                echo 'new OpenLayers.Geometry.LineString([';
                foreach (json_decode($result['json_line'])->coordinates as $coord) {
                    if(count($coord) >= 2) {
                        if(!$first) {
                            echo ",\n";
                        }
                        $first = FALSE;
                        echo 'new OpenLayers.Geometry.Point(' . $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo)';
                    }
                }
                echo '])';
                echo ",\n{description: '" . (isset($result['description']) ? $result['description'] : '') . "'}";
                echo ');';
                echo 'vectorLayer' . $compteur . '.addFeatures(feature);';
                echo 'map.addLayer(vectorLayer' . $compteur . ');';
            }
        }

        if(in_array('Point', $request['type'])) {
            echo 'var stylePointRequest' . $compteur . ' = new OpenLayers.StyleMap({
                    \'fillColor\':"' . $request['color'] . '",
                    \'strokeColor\':"' . $request['color'] . '",
                    \'strokeOpacity\': .8,
                    \'strokeWidth\': 1,
                    \'fillOpacity\': .3,
                    \'pointRadius\': 6
                });';


            echo 'var vectorLayer' . $compteur . ' = new OpenLayers.Layer.Vector("Points req. ' . $compteur . '", {styleMap: stylePointRequest' . $compteur . '});';
            foreach ($request['result'] as $result) {
                foreach (json_decode($result['json_point'])->coordinates as $coord) {
                    if(count($coord) >= 2) {
                        echo 'var feature = new OpenLayers.Feature.Vector(';
                                    echo 'new OpenLayers.Geometry.Point('. $coord[1] . ', ' . $coord[0] . ').transform(epsg4326, projectTo), ';
                                    echo '{description: \'' . (isset($result['description']) ? $result['description'] : '') . '\'}';
                                echo ');';
                        echo 'vectorLayer' . $compteur . '.addFeatures(feature);';
                    }
                }
            }
            echo 'map.addLayer(vectorLayer' . $compteur . ');';
            echo "addHover(map, vectorLayer" . $compteur . ");";

        }
        $compteur += 1;

    }

    foreach ($allBusRoute as $ligne) {
        if(in_array($ligne['route_id'], $ligneBus)) {
            echo 'var vectorLayer = new OpenLayers.Layer.Vector("Bus Line: ' . $ligne['route_id'] . ' (' . $ligne['direction_'] . ')",';
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
    // var controls = {
    //     selector: new OpenLayers.Control.SelectFeature(vectorLayer, { onSelect: createPopup, onUnselect: destroyPopup })
    // };

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
    
    // map.addControl(controls['selector']);
    // controls['selector'].activate();

  
</script>
    
